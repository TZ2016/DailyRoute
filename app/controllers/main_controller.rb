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
			@location.locationname = point.locationname
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
				@location.locationname = point.locationname
				@location.minduration = point.minduration
				@location.maxduration = point.maxduration
				@location.arrivebefore = point.arrivebefore
				@location.arriveafter = point.arriveafter
				@location.departbefore = point.departbefore
				@location.departafter = point.departafter
				@location.priority = point.priority
				@location.blacklist = true
				@location.lockedin = false
				@location.save
			end
			if point.lockedin = true
				Location.update(params[:locationid], :locationname => point.locationname)
			end
		end

    end
	
	def exportRoute
		outputFile = Prawn::Document.new
		outputFile.image(getMap())
		route = getRoute()
		route.each do |loc|
			outputFile.text("#{loc[locationname]}")
			outputFile.text("#{loc[address]}")
		end
		outputFile.render_file "output.pdf"
		send_file outputFile.path
	end
	
	def getMap ()
		#should return path to map image
	end
	
	def getRoute ()
		#should return array of dictionaries with location mame and adress in correct route order
	end
	
end
