class AddStepTable < ActiveRecord::Migration
	def change
		create_table :steps do |t|
			t.integer  :route_id
			t.string   :name
			t.string   :geocode
			t.datetime :arrival
			t.datetime :departure

			t.timestamps
		end
		
		add_index :steps, [:route_id, :arrival]
	end
end