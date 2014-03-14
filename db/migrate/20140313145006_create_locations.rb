class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.text :searchtext
      t.text :address
      t.integer :routeid
      t.integer :positioninroute
      t.time :minduration
      t.time :maxduration
      t.datetime :arrivebefore
      t.datetime :arriveafter
      t.datetime :departbefore
      t.datetime :departafter
      t.integer :priority
      t.boolean :blacklisted
      t.boolean :lockedin
      t.boolean :start
      t.boolean :dest
      t.text :geocode

      t.timestamps
    end
  end
end
