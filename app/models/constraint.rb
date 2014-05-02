class Constraint < ActiveRecord::Base

  VALID_GEOCODE_REGEX = /\A((-?)(\d+)\.(\d+))\,(\s*)(-?)((\d+)\.(\d+))\z/

  belongs_to :request, inverse_of: :constraints

  default_scope -> { order('priority') }

  validates_presence_of :request_id
  validates :name, presence: true
  validates :search_text, presence: true
  validates :geocode, presence: true, format: { with: VALID_GEOCODE_REGEX }
  # validates for arrival time

  validates :arrive_after, presence: true
  validates :arrive_before, presence: true
  validates :depart_after, presence: true
  validates :depart_before, presence: true
  validates :min_duration, presence: true
  validates :max_duration, presence: true

  validates_numericality_of :priority, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 5

  validates_numericality_of :group, only_integer: true, greater_than_or_equal_to: 0

end
