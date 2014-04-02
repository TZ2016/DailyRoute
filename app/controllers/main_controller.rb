class MainController < ApplicationController

	# frontend interface

	def master
		parseRoute
		solve(@route.id)
		# exportRoute
	end

	# core functionalities

	def parseRoute
		@route = Route.new
		@route.travelMethod = params[:travelMethod]
		@route.save
		counter = 0
		params[:locationList].each do |point|
			t = Time.now
			@year, @month, @day = t.year, t.month, t.day
			@location = Location.new
			@location.routeid = @route.id
			@location.searchtext = point[:searchtext]
			@location.minduration = read_duration(point[:minduration])
			@location.maxduration = read_duration(point[:maxduration])
			@location.arrivebefore = read_time(point[:arrivebefore])
			@location.arriveafter = read_time(point[:arriveafter])
			@location.departbefore = read_time(point[:departbefore])
			@location.departafter = read_time(point[:departafter])
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

	def read_time(text)
		if text == '' or text == nil
			return nil
		end
		hour, rest = text.split(':')
		minute, ap = rest[0..1], rest[2]
		hour = hour.to_i
		minute = minute.to_i
		if ap == 'p'
			hour += 12
		elsif ap == 'a' and hour == 12
			hour = 0
	    end
		return Time.new(@year, @month, @day, hour, minute)
	end

	def read_duration(text)
		if text == '' or text == nil
			return 0
		end
		hour, minute = text.split(':')
		hour, minute = hour.to_i, minute.to_i
		return hour * 3600 + minute * 60
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
 	
	#return path to image of map
	require 'open-uri'
 	def getMap ()
		route = getRoute()
		coordseq = ""
		pathseq = ""
		for loc in route
			cordseq = cordseq + "%7C"
			pathseq = pathseq + "|"
			latlng = loc[:geocode]
			lat = latlng[:lat].to_s
			lng = latlng[:lng].to_s
			coordseq = coordseq + lat + "," + lng
			pathseq = pathseq + lat + "," + lng
		end
		url = "http://maps.googleapis.com/maps/api/staticmap?size=400x400\&markers=color:blue" + coordseq + "path=color:0xff0000ff|weight:5" + pathseq + "&sensor=false"
		open('map.jpg', 'wb') do |file|
			file << open(url).read
			return file.path
		end
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

 	# test structure

	def reset
		User.destroy_all()
		Route.destroy_all()
		Location.destroy_all()
		render :json => { errCode: 1 }
	end

	def tests
		result = `rspec spec/requests/unit_tests_spec.rb --format documentation > output.txt`
		result = `cat output.txt`
		words  = result.split(" ")
		total_test = words[words.index("examples,") - 1]
		failures   = words[words.index("failures") - 1]

		render :json => { nrFailed: failures.to_i,
						  output: result,
						  totalTests: total_test.to_i }
	end

end
