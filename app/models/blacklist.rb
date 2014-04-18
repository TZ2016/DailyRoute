class Blacklist < ActiveRecord::Base
  belongs_to :route
  validates :route_id, presence: true
end
