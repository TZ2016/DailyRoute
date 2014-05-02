class Constraint
  include ActiveModel::Model

  attr_accessor :name,  :search_text, :geocode
  attr_accessor :group, :priority
  attr_accessor :arrive_after, :arrive_before
  attr_accessor :depart_after, :depart_before
  attr_accessor :min_duration, :max_duration

  def initialize(attributes={})
    super
  end

end