class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.text :locationname
      t.integer :routeid
      t.time :minduration
      t.time :maxduration
      t.datetime :arrivebefore
      t.datetime :arriveafter
      t.datetime :departbefore
      t.datetime :departafter
      t.integer :priority
      t.boolean :blacklisted
      t.boolean :lockedin

      t.timestamps
    end
  end
end
