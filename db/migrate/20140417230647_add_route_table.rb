class AddRouteTable < ActiveRecord::Migration
	def change
		create_table :routes do |t|
			t.integer  :user_id
			t.string   :name
			t.string   :location
			t.string   :mode

			t.timestamps
		end
		
		add_index :routes, [:user_id, :created_at]
	end
end