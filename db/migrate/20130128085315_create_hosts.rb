class CreateHosts < ActiveRecord::Migration
  def up
    create_table :hosts do |t|
      t.string "hostname"
      t.string "ipv4_addr"
      t.string "ipv6_addr"
      t.timestamps
    end
  end

  def down
     drop_table :hosts
  end
end
