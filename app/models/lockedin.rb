class Lockedin < ActiveRecord::Base
  belongs_to :step
  validates :step_id, presence: true
end
