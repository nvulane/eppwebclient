class Customer < ActiveRecord::Base
   self.primary_key = "debtor_code" 
   before_save :hash_password
   has_many :domains
   attr_accessible :debtor_code, :customer_name, :customer_org, :street1, :street2, :street3, :customer_city, :customer_province, :customer_postal, 
                   :customer_country, :customer_tel, :customer_fax, :customer_email, :customer_pass
   attr_protected 

   EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i    
   TEL_REGEX = /^\+([0-9]{1,3}\.[0-9]{6,14})/

   validates_presence_of :debtor_code, :customer_name, :customer_pass, :customer_city, :customer_country, :customer_tel, :customer_fax
   validates_uniqueness_of :debtor_code,
    :message => "Customer Already Exists"
   validates_format_of :customer_email, :with => EMAIL_REGEX
   validates_format_of :customer_tel, :customer_fax, :with => TEL_REGEX
   validates_length_of :customer_tel, :customer_fax, :minimum => 7, :maximum => 16

   def self.search(search)
    if search
      where('debtor_code LIKE ?', "%#{search}%")
    else
      scoped
    end
   end

  def hash_password
    self.customer_pass = Digest::MD5.hexdigest(self.customer_pass)
  end

end
