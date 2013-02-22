class Domain < ActiveRecord::Base
  self.primary_key = "domain_name"
  belongs_to :customer, {:foreign_key => "debtor_code"}
  attr_accessible :debtor_code, :domain_name, :ns_hostname1, :ns1_ipv4_addr, :ns1_ipv6_addr, :ns_hostname2, :ns2_ipv4_addr, :ns2_ipv6_addr, :domain_secret

  #DOMAIN_REGX = /^[A-Z0-9][A-Z0-9-]{1,61}[A-Z0-9]\.co\.za$/i  
  DOMAIN_REGX = /^((?!xn--)(?!.*-\.))[a-z0-9][a-z-0-9]*\.test\.dnservices\.co\.za$/

  validates_presence_of :debtor_code, :domain_name, :domain_secret
  validates_uniqueness_of :domain_name
  validates_format_of :domain_name, :with => DOMAIN_REGX

  def self.search(search)
  	if search
  		where('domain_name LIKE ?', "%#{search}%")
  	else
  		scoped
  	end
  end
end
