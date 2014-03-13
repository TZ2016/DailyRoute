class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.string :username
      t.string :travelMethod
      t.string :routeName

      t.timestamps
    end
  end
end
