class Route < ActiveRecord::Base

	before_validation { self.mode = mode.downcase }

	belongs_to :user
	has_many   :steps, dependent: :destroy

	default_scope -> { order('created_at DESC') }

	validates :user_id, presence: true
	validates :mode, presence: true
	validates :mode, inclusion: %w(driving transit bicycling walking)


	def Route.check_route(input)
		rtn = {}
		rtn[:errCode] = 1
		step = {name: "step", geocode: "[88.88, 99.99]", departure: DateTime.new, arrival: DateTime.new}
		route = {steps: [step, step], name: "route", mode: "waLking"}
		rtn[:routes] = [route, route]
		return rtn
	end
end
