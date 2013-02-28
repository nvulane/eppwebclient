class AddForCustomer < ActiveRecord::Migration
  def up
    add_column :requested_domains, :debtor_code, :string
  end

  def down
  end
end
