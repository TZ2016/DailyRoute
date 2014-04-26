class AddStepTable < ActiveRecord::Migration
	def change
		create_table :steps do |t|
			t.integer  :route_id
			t.string   :name, default: 'unnamed_location'
			t.string   :geocode
			t.datetime :arrival
			t.datetime :departure
			t.boolean :lockedin

			t.timestamps
		end
		
		add_index :steps, [:route_id, :arrival]
	end
end