class AddChanForAdminModule < ActiveRecord::Migration
  def change
    create_table :admin_chans do |t|
      t.string :name, null: false
      t.string :server_id, null: false
      t.boolean :joined, null: false, default: false
      t.date :join_date
      t.date :part_date
    end
  end
end
