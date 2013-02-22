class WelcomeWhoisController < ApplicationController
  layout 'welcome'
  def welcome
    if session[:username]
      redirect_to(:controller => 'EppClient', :action => 'index')
    end
  end

  def domain_whois
    @result = @epp.info_domain(params[:domain_name])
    answer=""
    if @result[:status].to_s == '1000'
       @result[:resdata].each do |key, data|
        if key.to_s == "domainNs"
          @result[:resdata][:domainNs].each do |ns|
            answer = answer + "Name Server = \"#{ns}\","
          end
        else
          answer = answer + "#{@dom_conversion[key.to_s]} = \"#{data}\", "
        end
      end
      flash[:info] = (answer.to_s).chop
    else
      answer = @result[:text].to_s
      flash[:error] = answer
    end
    redirect_to :action => 'welcome'
  end
  
  def login
    username = params[:username]
    password = params[:password]
    user = params[:username] 
    
    @usernm = AdminUser.find_by_username(user)
    if !@usernm
      flash[:error] = "Invalid Username/Password, Try Again."
      redirect_to(:action => 'welcome')
    else  
      name = username + AppConfig[:acc_suffix]
      ldap = Net::LDAP.new(
         :host => AppConfig[:ldap_server],   
         :auth => { :method => :simple, :username => name, :password => params[:password] }
      )
      if ldap.bind && params[:password] != ""
         session[:username] = username
         session[:last_seen] = Time.now
         redirect_to(:controller => 'EppClient', :action => 'index')
      else
         flash[:error] = "Invalid Username/Password, Try Again."
         redirect_to(:action => 'welcome')
      end
    end
  end

  def logout
    session[:username] = nil
    @epp.logout()
    redirect_to(:controller => 'WelcomeWhois', :action => 'welcome')
  end
end
