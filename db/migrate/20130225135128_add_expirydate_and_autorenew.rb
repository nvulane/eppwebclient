class AddExpirydateAndAutorenew < ActiveRecord::Migration
  def up
    add_column :domains, :expiry_date, :datetime
    add_column :domains, :autorenew, :boolean, :default => false
  end

  def down
  end
end
