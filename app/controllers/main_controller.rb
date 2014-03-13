class MainController < ApplicationController

	def index
	end
	def parseRoute
		@route = Route.new
		@route.travelMethod = params[:travelMethod]
		@route.save
		params[:locationList].each do |point|
			@location = Location.new
			@location.routeid = @route.id
			@location.searchtext = point.searchtext
			@location.minduration = point.minduration
			@location.maxduration = point.maxduration
			@location.arrivebefore = point.arrivebefore
			@location.arriveafter = point.arriveafter
			@location.departbefore = point.departbefore
			@location.departafter = point.departafter
			@location.priority = point.priority
			@location.blacklist = false
			@location.lockedin = false
			@location.save
		end
	end
	def updateRoute
		params[:locationList].each do |point|
			if point.blacklist == true
				@location = Location.new
				@location.routeid = @route.id
				@location.searchtext = point.searchtext
				@location.minduration = point.minduration
				@location.maxduration = point.maxduration
				@location.arrivebefore = point.arrivebefore
				@location.arriveafter = point.arriveafter
				@location.departbefore = point.departbefore
				@location.departafter = point.departafter
				@location.priority = point.priority
				@location.positioninroute = -1
				@location.blacklist = true
				@location.lockedin = false
				@location.save
			end
			if point.lockedin = true
				Location.update(params[:locationid], :locationname => point.locationname)
			end
		end

    end
end
