class AddReadInMassages < ActiveRecord::Migration
  def up
    add_column :messages, :readby, :string
    add_column :messages, :read?, :boolean, :default => false
  end

  def down
  end
end
