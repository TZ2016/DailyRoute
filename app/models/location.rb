class Location < ActiveRecord::Base
	serialize :geocode, Hash
end
