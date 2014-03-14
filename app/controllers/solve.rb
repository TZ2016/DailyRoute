# start and end are Location. locations is an Array of Location.
ERR_REQUEST_FAIL = -1
def solve (start,locations, dest)
	all_loc = [start]+locations+[dest]
	# result = request_distance(all_loc)
	# if result[:status] != 'ok'
	# 	render _____________
	# 	return
	# end
	info = result.rows
	arranged,unarranged = classify_loc(all_loc)
	if arranged == []
		return shortest_path(all_loc)
	else
		return fit_schedule(arranged, unarranged)
	end
end
## http://maps.googleapis.com/maps/api/directions/json?origin=Adelaide,SA&destination=Adelaide,SA&waypoints=optimize:true|Barossa+Valley,SA|Clare,SA|Connawarra,SA|McLaren+Vale,SA&sensor=false&key=API_KEY
def shortest_path(start, locations, dest)
	result = request_route(start,location, dest)
	if result[:status] != 'OK':
		render :json => {errCode: ERR_REQUEST_FAIL}
	ren
end

def fit_schedule(arranged, unarranged,info)
	pass
end

def request_route(start, locations, dest)
	addr = 'http://maps.googleapis.com/maps/api/directions/json?'
	origin= 'origin=%s' % start.gecode
	dest = 'destination=%s&' % dest.gecode
	places = ''
	locations.each do |point|
		places = point.gecode+'|'
	end
	places[places.length-1]='&'
	passby ='waypoints=optimize:true|%ssensor=false'%places
	addr = addr+origin+dest+passby
	require 'net/http'
	return Net::HTTP.get(URI.parse(addr))
	
end
## requires start.departafter and end.startbefore
def classify_loc(locations)
	arranged,unarranged = [],[]
	all_loc.each do |point|
		if preprocess(point).arrivebefore
			arranged << point
		else
			unarranged << point
		end
	end
	arranged.sort_by do |a|
		a.arrivebefore
	end
	_______!!!validity____________
	return arranged, unarranged
end
def request_distance(locations)
	address = 'http://maps.googleapis.com/maps/api/distancematrix/json?'
	places = ''
	locations.each do |point|
		places = point.gecode+'|'
	end
	places[places.length-1]='&'
	origins = 'origins='+places
	destination = 'destinations='+places
	mode = 'mode=' + @route.travelMethod
	address = address + origins + destinations + mode
	# http://maps.googleapis.com/maps/api/distancematrix/json?origins=Vancouver+BC|Seattle&destinations=San+Francisco|Victoria+BC&mode=bicycling&language=fr-FR&sensor=false&key=API_KEY
	require 'net/http'
	return Net::HTTP.get(URI.parse(address))
end
def preprocess(point)
	if point.arrivebefore and point.departafter:
		return
	if (not point.departafter) and arrivebefore
		point.departafter = point.arrivebefore +point.minduration

	elsif (not point.arrivebefore) and point.departbefore
		point.arrivebefore = point.departbefore - point.minduration
	end
	point.save
end

