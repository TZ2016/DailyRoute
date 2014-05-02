require 'ostruct'

class Request
  include ActiveModel::Model

  attr_accessor :constraints
  attr_accessor :mode, :total_groups

  def initialize(attributes={})
    super
    @mode         ||= 'walking'
    @total_groups ||= 0
  end

  def constraints_attributes=(attributes)
    @constraints ||= []
    attributes.each do |i, constraints_params|
      @constraints.push(Constraint.new(constraints_params))
    end
  end

  def self.association association, klass
    @@attributes              ||= {}
    @@attributes[association] = klass
  end

  association :constraints, Constraint

  def self.reflect_on_association(association)
    data = { klass: @@attributes[association] }
    OpenStruct.new data
  end

end