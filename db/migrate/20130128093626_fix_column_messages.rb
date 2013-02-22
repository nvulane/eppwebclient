class FixColumnMessages < ActiveRecord::Migration
  def up
    remove_column :messages, :read? 
    add_column :messages, :read, :boolean, :default => false
  end

  def down
  end
end
