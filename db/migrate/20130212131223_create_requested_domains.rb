class CreateRequestedDomains < ActiveRecord::Migration
  def change
    create_table :requested_domains do |t|
      t.string "reqdomain"
      t.boolean :is_transferred, :default => false
      t.timestamps
    end
  end
end
