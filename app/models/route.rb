class Route < ActiveRecord::Base

	before_save { self.mode = mode.downcase }

	belongs_to :user
	has_many   :steps, dependent: :destroy

	default_scope -> { order('created_at DESC') }

	validates :user_id, presence: true
	validates :mode, presence: true
	validates :mode, inclusion: %w(driving transit bicycling walking)

end
