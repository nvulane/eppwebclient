class AddTransferAway < ActiveRecord::Migration
  def up
    add_column :domains, :transfer_away, :boolean, :default => false
  end

  def down
  end
end
