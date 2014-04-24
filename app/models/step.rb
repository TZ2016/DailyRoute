class Step < ActiveRecord::Base
	# before_save {  }

	VALID_GEOCODE_REGEX = /\A((-?)(\d+)\.(\d+))\,(\s*)(-?)((\d+)\.(\d+))\z/

	belongs_to :route, inverse_of: :steps

	default_scope -> { order('arrival DESC') }

  validates :route, presence: true
	validates :geocode, presence: true, format: { with: VALID_GEOCODE_REGEX }
	# validates for arrival time
	validates :arrival, presence: true
	validates :departure, presence: true

end
