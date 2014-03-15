class Route < ActiveRecord::Base
	validates :travelMethod, presence: true

end
