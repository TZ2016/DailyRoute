class AddBlacklistTable < ActiveRecord::Migration
    def change
		create_table :blacklist do |t|
			t.integer  :route_id
			t.string   :name
			t.string   :geocode

			t.timestamps
		end
		
  	end
end
