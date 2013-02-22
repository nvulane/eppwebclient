class CreateAdminUsers < ActiveRecord::Migration
  def up
    create_table :admin_users, :id => false do |t|
      t.string "username"
      t.string "role"
      t.timestamps
    end
  end
  def down
  end
end
