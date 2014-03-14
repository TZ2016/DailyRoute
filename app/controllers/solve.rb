# start and end are Location. locations is an Array of Location.
SUCCESS = 1
ERR_REQUEST_FAIL = -1
ERR_INVALID_INPUT_TIME = -2

def solve (start,locations, dest)
	arranged,unarranged,invalid_input = classify_loc(start,locations, dest)
	if invalid_input
		render :json => {errCode: ERR_INVALID_INPUT_TIME}
	elsif arranged == []
		shortest_path(start,locations, dest)
	else
		fit_schedule(arranged, unarranged)
	end
end

## http://maps.googleapis.com/maps/api/directions/json?origin=Adelaide,SA&destination=Adelaide,SA&waypoints=optimize:true|Barossa+Valley,SA|Clare,SA|Connawarra,SA|McLaren+Vale,SA&sensor=false&key=API_KEY
def shortest_path(start, locations, dest)
	result = request_route(start,location, dest)
	if result[:status] != 'OK':
		render :json => {errCode: ERR_REQUEST_FAIL}
	else
		order = result[:routes][0][:waypoint_order]
		ordered_loc = order.map{|x| location[x].geocode}
		ordered_loc = [start.geocode] + ordered_loc + [dest.geocode]
		render :json => {errCode: SUCCESS, route: ordered_loc}
	end
end

def fit_schedule(arranged, unarranged,info)
end

def geocode_to_s(geocode)
	return geocode[:lat].to_s + ',' + geocode[:lng].to_s
end 

def request_route(start, locations, dest)
	addr = 'http://maps.googleapis.com/maps/api/directions/json?'
	origin = 'origin=%s' % geocode_to_s(start.geocode) 
	dest = 'destination=%s&' % geocode_to_s(dest.geocode)
	places = ''
	locations.each do |point|
		places = geocode_to_s(point.geocode) + '|'
	end
	places[places.length - 1] = '&'
	passby = 'waypoints=optimize:true|%ssensor=false' % places
	addr = addr+origin+dest+passby
	require 'net/http'
	return Net::HTTP.get(URI.parse(addr))
end

## requires start.departafter and end.startbefore
def classify_loc(start, locations, dest)
	all_loc = [start]+locations+[dest]
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
	invalid_input = false
	if arranged and (arranged.first != start or arranged.last != dest)
		invalid_input = true
	end
	return arranged, unarranged, invalid_input
end

# http://maps.googleapis.com/maps/api/distancematrix/json?origins=Vancouver+BC|Seattle&destinations=San+Francisco|Victoria+BC&mode=bicycling&language=fr-FR&sensor=false&key=API_KEY
def request_distance(locations)
	address = 'http://maps.googleapis.com/maps/api/distancematrix/json?'
	places = ''
	locations.each do |point|
		places = point.geocode+'|'
	end
	places[places.length-1]='&'
	origins = 'origins='+places
	destination = 'destinations='+places
	mode = 'mode=' + @route.travelMethod
	address = address + origins + destinations + mode
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

