class AddLink < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :name, null: false
      t.string :server_id, null: false
      t.string :definition, null:false
    end
  end
end
