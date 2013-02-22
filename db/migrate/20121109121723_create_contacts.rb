class CreateContacts < ActiveRecord::Migration
  def up
    create_table :contacts, :id => false do |t|
      t.string "contactId"
      t.string "contactName"
      t.string "contactOrg"
      t.string "contactStreet1"
      t.string "contactStreet2"
      t.string "contactStreet3"
      t.string "contactCity"
      t.string "contactProvince"
      t.string "contactPostal"
      t.string "contactCountry"
      t.string "contactTel"
      t.string "contactFax"
      t.string "contactEmail"
      t.string "contactPassword"
      t.timestamps
    end
  end

  def down
    drop_table :contacts
  end
end
