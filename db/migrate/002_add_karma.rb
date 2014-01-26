class AddKarma < ActiveRecord::Migration
  def change
    create_table :karmas do |t|
      t.string :name, null: false
      t.string :server_id, null: false
      t.integer :karma, null: false, default: 0
    end
  end
end
