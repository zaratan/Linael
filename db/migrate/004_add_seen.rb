class AddSeen < ActiveRecord::Migration
  def change
    create_table :seen_users do |t|
      t.string :server_id, null: false
      t.string :user, null: false
      t.string :ident, null: false
      t.string :last_seen, null: false
      t.datetime :last_seen_time, null: false, default: -> {Time.now}
      t.string :previous_last_seen
      t.datetime :previous_last_seen_time
      t.string :first_seen, null: false
      t.datetime :first_seen_time, null: false, default: -> {Time.now}
    end
  end
end
