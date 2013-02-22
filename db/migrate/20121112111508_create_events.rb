class CreateEvents < ActiveRecord::Migration
  def up
    create_table :events do |t|
      t.string "username"
      t.string "action"
      t.text "params"
      t.string "cltrid"
      t.string "svtrid"
      t.timestamps
    end
  end
   def down
    drop_table :events
   end
end
