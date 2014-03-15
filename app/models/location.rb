class Location < ActiveRecord::Base
	serialize :geocode, Hash
	validates :geocode, presence: true
	validates :routeid, presence: true

end
