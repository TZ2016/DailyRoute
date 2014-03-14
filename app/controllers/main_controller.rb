class MainController < ApplicationController

	def index
	end

	def aboutUs
	end

	def tutorial
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
	
	def exportRoute
 		outputFile = Prawn::Document.new
 		outputFile.image(getMap())
 		route = getRoute()
 		for loc in route do
 			outputFile.text("#{loc.locationname}")
 			outputFile.text("#{loc.address}")
 		end
 		outputFile.render_file "output.pdf"
 		send_file outputFile.path
 	end
 	
 	def getMap ()
 		#should return path to map image
 	end
 	
	#returns array of location object in correct route order
 	def getRoute ()
		id = @route.id
		currRoute = Location.where(routeid: id).to_a
		tempLoc = Array.new
		tempOrder = Array.new
		count = 0
		for entry in currRoute do
			pos = entry.positioninroute
			if pos > 0
				@tempOrder << entry
				@tempLoc << pos
				count += 1
			end
		end
		routeArray = Array.new(count)
		arrPos = 0
		for num in tempOrder do
			routeArray[num] = tempLoc[arrPos]
			arrPos += 1
		end
		return routeArray
 	end
end
