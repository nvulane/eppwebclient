class FixColumnName < ActiveRecord::Migration
  def up
     rename_column :contacts, :contactId, :debtor_code
     rename_column :contacts, :contactName, :customer_name
     rename_column :contacts, :contactOrg, :customer_org
     rename_column :contacts, :contactStreet1, :street1
     rename_column :contacts, :contactStreet2, :street2
     rename_column :contacts, :contactStreet3, :street3
     rename_column :contacts, :contactCity, :customer_city
     rename_column :contacts, :contactProvince, :customer_province
     rename_column :contacts, :contactPostal, :customer_postal
     rename_column :contacts, :contactCountry, :customer_country
     rename_column :contacts, :contactTel, :customer_tel
     rename_column :contacts, :contactFax, :customer_fax
     rename_column :contacts, :contactEmail, :customer_email
     rename_column :contacts, :contactPassword, :customer_pass
     rename_table :contacts, :customers

     rename_column :domains, :contactId, :debtor_code
     rename_column :domains, :domainName, :domain_name
     rename_column :domains, :nshostName1, :ns_hostname1
     rename_column :domains, :ns1Ipv4_addr, :ns1_ipv4_addr
     rename_column :domains, :ns1Ipv6_addr, :ns1_ipv6_addr
     rename_column :domains, :nshostName2, :ns_hostname2
     rename_column :domains, :ns2Ipv4_addr, :ns2_ipv4_addr
     rename_column :domains, :ns2Ipv6_addr, :ns2_ipv6_addr
     rename_column :domains, :domainSecret, :domain_secret

  end

  def down
  end
end
