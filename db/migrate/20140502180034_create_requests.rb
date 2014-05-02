class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer    :user_id
      t.string     :mode
      t.integer    :num_groups

      t.timestamps
    end

    add_index :requests, [:user_id, :created_at]
  end
end
