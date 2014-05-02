class CreateConstraints < ActiveRecord::Migration
  def change
    create_table :constraints do |t|
      t.integer   :request_id
      t.string    :name
      t.string    :search_text
      t.string    :geocode
      t.datetime  :arrive_after
      t.datetime  :arrive_before
      t.datetime  :depart_after
      t.datetime  :depart_before
      t.integer   :min_duration
      t.integer   :max_duration
      t.integer   :group
      t.integer   :priority

      t.timestamps
    end

    add_index :constraints, [:request_id, :group]
  end
end
