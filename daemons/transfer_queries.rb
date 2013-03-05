require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
def logger
    @@logger ||= ActiveSupport::BufferedLogger.new("#{Rails.root}/log/transfer_queries.log")
end
loop do 
  begin
    @epp = CozaEPP::Client.new(AppConfig[:epp_server],AppConfig[:epp_username],AppConfig[:epp_password])
    @epp.login
  rescue Exception
    
  end

  pendings = RequestedDomain.all
  pendings.each do |domain|
    nowtime = DateTime.now()
    if ((domain.vote).to_datetime).future?
      @querying = @epp.transfer_query(domain.reqdomain)
      if @querying[:status].to_s == '1000'
        if domain.status =! @querying[:trnData][:domaintrStatus].to_s
          domain.update_attributes(:status => @querying[:trnData][:domaintrStatus].to_s)
        end
      end
    elsif domain.status == 'clientApproved'
      @info = @epp.info_domain(domain.reqdomain)
      if @info[:status].to_s == '1000'
        exp = @info[:resdata][:domainExDate].to_s
        xpd = exp.to_datetime
        Domain.create(:debtor_code => domain.debtor_code ,:domain_name => @info[:resdata][:domainName].to_s, :ns_hostname1 => @info[:resdata][:domainNs][0].to_s,
                            :ns_hostname2 => @info[:resdata][:domainNs][1].to_s, :expiry_date => xpd, :domain_secret => "coza")
        domain.destroy
       end
    elsif domain.status == 'clientApproved' || domain.status == 'pending'
      domain.destroy
    end
  end 
  requested = Domain.find(:all,:conditions => ["transfer_away = true"])
  requested.each do |domain|
    @querying = @epp.transfer_query(domain.domain_name)
    if @querying[:status].to_s == '2301'
      domain.update_attributes(:transfer_away => "false")
    end
  end
  sleep(5)
end
