class MainController < ApplicationController

	def index
	end

	def aboutUs
	end

	def tutorial
	end

	def master
		parseRoute
		puts "================route saved=================="
		require 'pp'
		pp @route
		pp Location.all
		solve(@route.id)
		# exportRoute
	end



	def parseRoute
		puts "I Got It"
		puts params
		@route = Route.new
		@route.travelMethod = params[:travelMethod]
		@route.save
		counter = 0
		params[:locationList].each do |point|
			@location = Location.new
			@location.routeid = @route.id
			@location.searchtext = point[:searchtext]
			@location.minduration = point[:minduration]
			@location.maxduration = point[:maxduration]
			@location.arrivebefore = point[:arrivebefore]
			@location.arriveafter = point[:arriveafter]
			@location.departbefore = point[:departbefore]
			@location.departafter = point[:departafter]
			@location.priority = point[:priority]
			@location.geocode = point[:geocode]
			@location.blacklisted = false
			@location.lockedin = false
			if counter == 0
				@location.start = true
			else
				@location.start = false
			end
			if counter == (params[:locationList].length - 1)
				@location.dest = true
			else
				@location.dest = false
			end
			counter+=1
			@location.save
		end
	end
	
	def updateRoute
		params[:locationList].each do |point|
			if point.blacklisted == true
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
				@location.blacklisted = true
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
