class Step < ActiveRecord::Base
	# before_save {  }

	VALID_GEOCODE_REGEX = /\A((\d+)\.(\d+))\,(\s*)((\d+)\.(\d+))\z/

	belongs_to :route

	default_scope -> { order('arrival DESC') }

	validates :route_id, presence: true
	validates :geocode, presence: true, format: { with: VALID_GEOCODE_REGEX }
	# validates for arrival time
	validates :arrival, presence: true
	validates :departure, presence: true

end
