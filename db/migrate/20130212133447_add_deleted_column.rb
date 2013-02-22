class AddDeletedColumn < ActiveRecord::Migration
  def up
    add_column :domains, :deleted, :boolean, :default => false
  end

  def down
  end
end
