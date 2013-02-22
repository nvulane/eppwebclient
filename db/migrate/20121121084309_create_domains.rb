class CreateDomains < ActiveRecord::Migration
  def  up
    create_table :domains, :id => false do |t|
      t.string "contactId", :null => false
      t.string "domainName"
      t.string "nshostName1"
      t.string "ns1Ipv4_addr"
      t.string "ns1Ipv6_addr"
      t.string "nshostName2"
      t.string "ns2Ipv4_addr"
      t.string "ns2Ipv6_addr"
      t.string "domainSecret"
      t.timestamps
    end
  end
  def down
  end
end
