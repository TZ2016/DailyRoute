class Request < ActiveRecord::Base

  before_validation { self.mode = mode.downcase }

  belongs_to :user
  has_many :routes, dependent: :destroy

  has_many :constraints, inverse_of: :request, dependent: :destroy
  accepts_nested_attributes_for :constraints

  default_scope -> { order('created_at') }

  # validates_presence_of :constraints
  validates :user_id, presence: true
  validates_numericality_of :num_groups, greater_than_or_equal_to: 0, only_integer: true
  validates :mode, inclusion: %w(driving transit bicycling walking)

end
