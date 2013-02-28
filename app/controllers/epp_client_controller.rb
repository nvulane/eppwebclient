class EppClientController < ApplicationController
  
  before_filter :loggedin?
  before_filter :list_cus, :only =>[:edit_customer, :delete_customer, :update_customer, :destroy_customer]
  before_filter :list_dom, :only =>[:edit_domain, :update_domain, :delete_domain, :destroy_domain, :approving_transfer, :date_renew, 
                                    :date_renewing, :set_false, :set_true]
  
  def loggedin?
    if session[:username] 
      if session[:last_seen] < 10.minutes.ago
        reset_session
        redirect_to(:controller => 'WelcomeWhois', :action => 'welcome')
      else
        session[:last_seen] = Time.now
      end
    else
      redirect_to(:controller => 'WelcomeWhois', :action => 'welcome')
    end
  end

  def _subregion_select
    respond_to do |format|
      format.html { render :layout => !request.xhr? }
    end
  end

  def index
      @result = @epp.poll()
      if @result[:status].to_s != "1300"
        while @result[:msgcount].to_i > 0
          line = @result[:msgtext].to_s
          new_message(line)
          @epp.ack(@result[:svtrid].to_s)
          if line =~ /transfer rejected/
            dom = line.scan(/'([^"]*)'/)
            @reqdomains = RequestedDomain.find_by_reqdomain(dom[0])
            @reqdomains.destroy
          elsif line =~ /transfer successful/
            dom = line.scan(/'([^"]*)'/)
            @reqdomains = RequestedDomain.find_by_reqdomain(dom[0])
            @reqdomains.update_attributes(:is_transferred => "true")
            @result = @epp.info_domain(dom)
            if @result[:status].to_s == '1000'
              exp = @result[:domainExDate].to_s
              Domain.create(:debtor_code => @reqdomains["debtor_code"],:domain_name => @result[:resdata][:domainName].to_s, :ns_hostname1 => @result[:resdata][:domainNs][0].to_s, 
                            :ns_hostname2 => @result[:resdata][:domainNs][1].to_s, :expiry_date => (exp[/\d+-\d+-\d+/]).to_datetime, :domain_secret => "coza")
            end
          elsif line =~ /transfer requested/
            dom = line.scan(/'([^"]\S*)'/)
            @domain = Domain.find_by_domain_name(dom[0])
            @domain.update_attributes(:transfer_away => "true")
          end
          @result = @epp.poll()
        end
      end
      @messages = Message.paginate :per_page => 15, :page => params[:page],:conditions => ["read = false"], :order => 'id DESC'
      respond_to do |format|
        format.html { render :layout => !request.xhr? }
      end
  end
  def read_it
    @message = Message.find_by_id(params[:msgid])
    @message.update_attributes(:readby => session[:username], :read => "true")
    respond_to do |format|
      format.text { render :text => "Yes" }
    end
  end
  def read_messages
    @messages = Message.paginate :per_page => 15, :page => params[:page],:conditions => ["read = true"], :order => 'id DESC'
  end
  def deleted_domains
    @domains = Domain.search(params[:search]).paginate :per_page => 15, :page => params[:page],:conditions => ["deleted = true"]
    @autocomplete_items = Domain.find(:all,:conditions => ["deleted = true"],:select=>'domain_name').map(&:domain_name)
  end
  def requested_domains
    @reqdomains = RequestedDomain.search(params[:search]).paginate :per_page => 15, :page => params[:page],:order => 'updated_at DESC'
    @autocomplete_items = RequestedDomain.find(:all,:select=>'reqdomain').map(&:reqdomain)
  end
  def domains
    @domains = Domain.search(params[:search]).paginate :per_page => 15, :page => params[:page],:conditions => ["deleted = false"],:order => 'updated_at DESC'
    @autocomplete_items = Domain.find(:all,:conditions => ["deleted = false"],:select=>'domain_name').map(&:domain_name)
  end
  def customers
    @customers = Customer.search(params[:search]).paginate :per_page => 15, :page => params[:page],:order => 'updated_at DESC'
    @autocomplete_items = Customer.find(:all,:select=>'debtor_code').map(&:debtor_code)
  end
  def hosts
    @hosts = Host.search(params[:search]).paginate :per_page => 15, :page => params[:page],:order => 'updated_at DESC'
    @autocomplete_items = Host.find(:all,:select=>'hostname').map(&:hostname)
  end

  def create_customer
    @customer = Customer.new(params[:customer])
      @result = @epp.create_contact(params[:customer][:debtor_code], params[:customer][:customer_name], params[:customer][:customer_org], 
                                    params[:customer][:street1], params[:customer][:street2],params[:customer][:street3], params[:customer][:customer_city],
                                    params[:customer][:customer_province],params[:customer][:customer_postal],params[:customer][:customer_country],
                                    params[:customer][:customer_tel],params[:customer][:customer_fax],params[:customer][:customer_email],params[:customer][:customer_pass])
      message = @result[:text].to_s
      new_message(message)
      create_event("create_customer", params[:customer].except(:customer_pass), @result[:cltrid].to_s, @result[:svtrid].to_s)
      if @result[:status].to_s == '1000'
         @customer.save
         flash[:success] = @result[:text].to_s
         redirect_to :action => 'index'
      else
         flash[:error] = @result[:text].to_s
         render('new_customer')
      end
    @epp.ack(@result[:svtrid].to_s)
  end
  def update_customer
    @customer = Customer.find_by_debtor_code(params[:customer][:debtor_code])
       @result = @epp.update_contact(@customer["debtor_code"], params[:customer][:customer_name], params[:customer][:customer_org], 
                                    params[:customer][:street1], params[:customer][:street2],params[:customer][:street3], params[:customer][:customer_city],
                                    params[:customer][:customer_province],params[:customer][:customer_postal],params[:customer][:customer_country],
                                    params[:customer][:customer_tel],params[:customer][:customer_fax],params[:customer][:customer_email],params[:customer][:customer_pass])
       new_message(@result[:text].to_s)
       create_event("update_customer", params[:customer].except(:customer_pass), @result[:cltrid].to_s, @result[:svtrid].to_s)
       if @result[:status].to_s == '1001'
        @customer.update_attributes(params[:customer])
        flash[:success] = @result[:text].to_s
        redirect_to :action => 'index'
       else
         flash[:error] = @result[:text].to_s
         render('edit_customer')
       end
       @epp.ack(@result[:svtrid].to_s)
  end
  def destroy_customer
      @result = @epp.delete_contact(params[:debtor_code])
      new_message(@result[:text].to_s)
      create_event("delete_customer", params[:customer], @result[:cltrid].to_s, @result[:svtrid].to_s)
      if @result[:status].to_s == '1000'
        @customer.destroy
        flash[:success] = @result[:text].to_s
        redirect_to :action => 'index'
      else
        flash[:error] = @result[:text].to_s
        redirect_to :action => 'index'
      end
      @epp.ack(@result[:svtrid].to_s)
  end
  def create_host
    @host = Host.new(params[:host])
    @result = @epp.create_host(params[:host][:hostname],params[:host][:ipv4_addr],params[:host][:ipv6_addr])
    new_message(@result[:text].to_s)
    create_event("create_host", params[:host], @result[:cltrid].to_s, @result[:svtrid].to_s)
    if @result[:status].to_s == '1000'
      @host.save
      flash[:success] = @result[:text].to_s
      redirect_to :action => 'index'
    else
      flash[:error] = @result[:text].to_s
      redirect_to :action => 'index'
    end
    @epp.ack(@result[:svtrid].to_s)
  end

  def create_domain
    expiry = Date.today.advance(:months => 12)
    if params[:with_host_with_host]
      @result = @epp.create_domain(params[:domain][:domain_name], params[:domain][:debtor_code],
                                             [{ "hostname" => params[:domain][:ns_hostname1],"ip_v4_address" => params[:domain][:ns1_ipv4_addr], "ip_v6_address" => params[:domain][:ns1_ipv6_addr]},
                                              { "hostname" => params[:domain][:ns_hostname2],"ip_v4_address" => params[:domain][:ns2_ipv4_addr], "ip_v6_address" => params[:domain][:ns2_ipv6_addr]}],
                                             params[:domain][:domain_secret])
      @domain = Domain.new(params[:domain].merge(:expiry_date => expiry.to_datetime))
    else
      @result = @epp.create_domain(params[:domain][:domain_name], params[:domain][:debtor_code],[{"hostname" => params[:hostname1]},
                                                                                           {"hostname" => params[:hostname2]}],
                                                                  params[:domain][:domain_secret])
      @domain = Domain.new(params[:domain].merge(:ns_hostname1 => params[:hostname1],:ns_hostname2 => params[:hostname2],:expiry_date => expiry.to_datetime))
    end
    new_message(@result[:text].to_s)
    create_event("create_domain", params[:domain], @result[:cltrid].to_s, @result[:svtrid].to_s)
    if @result[:status].to_s == '1000'
      @domain.save
      flash[:success] = @result[:text].to_s
      redirect_to :action => 'index'
    else
      flash[:error] = @result[:text].to_s
      redirect_to :action => 'index'
    end
    @epp.ack(@result[:svtrid].to_s)
  end
  def edit_domain
    @domain = Domain.find_by_domain_name(params[:domain_name])
  end
  def update_domain
    @domain = Domain.find_by_domain_name(params[:domain][:domain_name])
     if params[:with_host].to_s == "with_host"
        if params[:domain][:ns_hostname1] != @domain["ns_hostname1"] || params[:domain][:ns1_ipv4_addr] != @domain["ns1_ipv4_addr"] || params[:domain][:ns1_ipv6_addr] != @domain["ns1_ipv6_addr"]
           @result = @epp.update_domain_ns(@domain["domain_name"],params[:domain][:ns_hostname1],params[:domain][:ns1_ipv4_addr],params[:domain][:ns1_ipv6_addr])
        end
        if params[:domain][:ns_hostname2] != @domain["ns_hostname2"] || params[:domain][:ns2_ipv4_addr] != @domain["ns2_ipv4_addr"] || params[:domain][:ns2_ipv6_addr] != @domain["ns2_ipv6_addr"]
           @result = @epp.update_domain_ns(@domain["domain_name"],params[:domain][:ns_hostname2],params[:domain][:ns2_ipv4_addr],params[:domain][:ns2_ipv6_addr])
        end
        if @result
          if @result[:status].to_s == '1001'
             @domain.update_attributes(params[:domain])
             flash[:success] = @result[:text].to_s
             redirect_to :action => 'index'
          else
            flash[:error] = @result[:text].to_s
            render('edit_domain')
          end
        else
          flash[:error] = "No Changes made."
          render('edit_domain')
        end
     else
        @result = @epp.update_domain_registrant(params[:domain][:domain_name],params[:domain][:debtor_code])
         if @result[:status].to_s == '1001'
            @domain.update_attributes(params[:domain])
            flash[:success] = @result[:text].to_s
            redirect_to :action => 'index'
         else
            flash[:error] = @result[:text].to_s
            render('edit_domain')
         end
     end
    if @result
      new_message(@result[:text].to_s)
      create_event("update_domain", params[:domain], @result[:cltrid].to_s, @result[:svtrid].to_s)
      @epp.ack(@result[:svtrid].to_s)
    end
  end
  def destroy_domain
      @result = @epp.delete_domain(params[:domain_name])
      if @result[:status].to_s == '1001'
        @domain = Domain.find_by_domain_name(params[:domain_name])
        @domain.update_attributes(:deleted => "true")
        #@domain.destroy
        flash[:success] = @result[:text].to_s
        redirect_to :action => 'index'
      else
        flash[:error] = @result[:text].to_s
        redirect_to :action => 'index'
      end
      new_message(@result[:text].to_s)
      create_event("delete_domain", params[:domain_name], @result[:cltrid].to_s, @result[:svtrid].to_s)
      @epp.ack(@result[:svtrid].to_s)
  end
  def requesting_transfer
     @result = @epp.transfer_domain(params[:requested_domain][:reqdomain])
     new_message(@result[:text].to_s)
     create_event("transfer_domain", params[:domain], @result[:cltrid].to_s, @result[:svtrid].to_s)
     if @result[:status].to_s == '1001'
        RequestedDomain.create(params[:requested_domain])
        flash[:success] = @result[:text].to_s
        redirect_to :action => 'index'
     else
        flash[:error] = @result[:text].to_s
        redirect_to :action => 'index'
     end
     @epp.ack(@result[:svtrid].to_s)
  end
  def approving_transfer
    @result = @epp.transfer_approve(params[:domain_name])
    new_message(@result[:text].to_s)
    create_event("transfer_approval", params[:domain_name], @result[:cltrid].to_s, @result[:svtrid].to_s)
    if @result[:status].to_s == '1000'
       @domain.update_attributes(:deleted => "true")
       flash[:success] = @result[:text].to_s
       redirect_to :action => 'index'
    else
       flash[:error] = @result[:text].to_s
       redirect_to :action => 'index'
    end
    @epp.ack(@result[:svtrid].to_s)
  end
  def date_renewing
    @domain = Domain.find_by_domain_name(params[:domain][:domain_name])
    @result = @epp.renew_domain(params[:domain][:domain_name],params[:expriry_date])
    new_message(@result[:text].to_s)
    create_event("date_renew", params[:domain], @result[:cltrid].to_s, @result[:svtrid].to_s)
    if @result[:status].to_s == '1000'
        @domain.update_attributes(:expiry_date => (params[:expriry_date].to_date).advance(:months => 12))
        flash[:success] = @result[:text].to_s
        redirect_to :action => 'index'
    else
        flash[:error] = @result[:text].to_s
        redirect_to :action => 'index'
    end
    @epp.ack(@result[:svtrid].to_s)
  end
  def set_true
    @result = @epp.set_autorenew(params[:domain_name],"true")
    new_message(@result[:text].to_s)
    create_event("auto_renew", params[:domain_name], @result[:cltrid].to_s, @result[:svtrid].to_s)
    if @result[:status].to_s == '1001'
        @domain.update_attributes(:autorenew => "true")
        flash[:success] = @result[:text].to_s
        redirect_to :action => 'index'
    else
        flash[:error] = @result[:text].to_s
        redirect_to :action => 'index'
    end
  end
  def set_false
    @result = @epp.set_autorenew(params[:domain_name],"false")
    new_message(@result[:text].to_s)
    create_event("auto_renew", params[:domain_name], @result[:cltrid].to_s, @result[:svtrid].to_s)
    if @result[:status].to_s == '1001'
        @domain.update_attributes(:autorenew => "false")
        flash[:success] = @result[:text].to_s
        redirect_to :action => 'index'
    else
        flash[:error] = @result[:text].to_s
        redirect_to :action => 'index'
    end
  end
  def available_domain
    @result = @epp.check_domain(params[:domain_name])
    if @result[:status].to_s == '1000'
        answer = @result[:availcode].to_s
        if answer == "1"
          avail = "available"
        else
          avail = "not-vailable"
        end
    else
        avail = "Invalid"
    end
    respond_to do |format|
      format.text { render :text => avail }
    end
  end
  def customer_info
    @result = @epp.info_contact(params[:debtor_code],"pass")
    answer=""
    if @result[:status].to_s == '1000'
      @result[:infocontact].each do |key, data|
        if key.to_s == "contactStreet"
          @result[:infocontact][:contactStreet].each do |str|
            answer = answer + "Street = \"#{str}\"<br>"
          end
        else
          answer = answer + "#{@cus_conversion[key.to_s]} = \"#{data}\"<br> "
        end
      end
      answer = (answer.to_s).chop
    else
      answer = @result[:text].to_s
    end
    respond_to do |format|
      format.text { render :text => answer }
    end
  end
  def domain_info
    @result = @epp.info_domain(params[:domain_name])
    answer=""
    if @result[:status].to_s == '1000'
       @result[:resdata].each do |key, data|
        if key.to_s == "domainNs"
          @result[:resdata][:domainNs].each do |ns|
            answer = answer + "Name Server = \"#{ns}\"<br>"
          end
        else
          answer = answer + "#{@dom_conversion[key.to_s]} = \"#{data}\"<br> "
        end
      end
      answer = (answer.to_s).chop
    else
      answer = @result[:text].to_s
    end
    respond_to do |format|
      format.text { render :text => answer }
    end
  end
  
  def new_message(msg)
    Message.create(:message => msg)
  end
  def create_event(action, parames, cltrid, svtrid)
    Event.create(:username => session[:username], :action => action, :params => parames, :cltrid => cltrid, :svtrid => svtrid)
  end
  def events
    @events = Event.search(params[:search]).paginate :per_page => 15, :page => params[:page],:order => 'id DESC'
    @svtrid_items = Event.find(:all,:select=>'svtrid').map(&:svtrid)
    @cltrid_items = Event.find(:all,:select=>'cltrid').map(&:cltrid)
    @autocomplete_items = @svtrid_items.concat(@cltrid_items)
  end

  protected
  def list_cus
    @customer = Customer.find_by_debtor_code(params[:debtor_code])
  end
  def list_dom
    @domain = Domain.find_by_domain_name(params[:domain_name])
  end
end
