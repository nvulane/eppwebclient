class CreateNameServers < ActiveRecord::Migration
  def change
    create_table :name_servers do |t|
      t.string "name_server1"
      t.string "name_server2"
      t.string "name_server3" 
      t.timestamps
    end
  end
end
