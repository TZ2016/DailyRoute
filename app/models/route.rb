class Route < ActiveRecord::Base

	before_validation { self.mode = mode.downcase }

	belongs_to :user
	has_many   :steps, inverse_of: :route, dependent: :destroy
  accepts_nested_attributes_for :steps

	default_scope -> { order('created_at DESC') }

	validates :user_id, presence: true
	validates :mode, presence: true
	validates :mode, inclusion: %w(driving transit bicycling walking)

end
