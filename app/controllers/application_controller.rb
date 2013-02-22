class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  before_filter :set_vars
  before_filter :set_cache_buster 
  before_filter :initialise

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  protected
  def set_vars
    @epp = CozaEPP::Client.new(AppConfig[:epp_server],AppConfig[:epp_username],AppConfig[:epp_password])
    @epp.login
  end
  def initialise
    @count = Message.where(:read => "false").size
    @autocomplete_customer = Customer.find(:all,:select=>'debtor_code').map(&:debtor_code)
    @dom_conversion = {"domainName" => "Domain Name",
                  "domainNs" => "Name Serve",
                  "domainUpDate" => "Last Update",
                  "domainExDate" => "Expiry Date",
                  "domainCrDate" => "Created",
                  "domainClID" => "Registrar",
                  "domainCrID" => "Old Registrar ",
                  "domainRoid" => "Repository Object ID",
                  "domainUpID" => "Updated by"}

    @cus_conversion = {
                  "contactUpID" => "Updated By",
                  "contactCc" => "Country Code",
                  "contactUpDate" => "Last Update",
                  "contactVoice" => "Phone Number",
                  "contactFax" => "Fax Number",
                  "contactStatus" => "Contact Status",
                  "contactClID" => "Registrar",
                  "contactCity" => "City",
                  "contactEmail" => "Email Address",
                  "contactStreet" => "Street",
                  "contactName" => "Customer Name",
                  "contactCrID" => "Registrar",
                  "contactSp" => "Province",
                  "contactOrg" => "Organisation",
                  "contactPc" => "Postal code",
                  "contactCrDate" => "Create Date"}
  end
end
