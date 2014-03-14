# start and end are Location. locations is an Array of Location.
def solve (start,locations,end)
	all_loc = [start]+locations+[end]
	result = request_distance(all_loc)
	if result[:status] != 'ok'
		render _____________
		return
	end
	info = result.rows
	arranged,unarranged = classify_loc(all_loc)
	if arranged == []
		return shortest_path(all_loc)
	else
		return fit_schedule(arranged, unarranged)
	end

def shortest_path(location,info)
	pass


def fit_schedule(arranged, unarranged,info)
	pass

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
def request_distance(locations)
	address = 'http://maps.googleapis.com/maps/api/distancematrix/json?'
	place = ''
	locations.each do |point|
		places = point.gecode+'|'
	places[places.length]='&'
	origins = 'origins='+places
	destination = 'destinations='+places
	mode = 'mode=' + @route.travelMethod
	address = address + origins + destinations + mode
	# http://maps.googleapis.com/maps/api/distancematrix/json?origins=Vancouver+BC|Seattle&destinations=San+Francisco|Victoria+BC&mode=bicycling&language=fr-FR&sensor=false&key=API_KEY
	require 'net/http'
	return Net::HTTP.get(URI.parse(address))
def preprocess(point)
	if point.arrivebefore and point.departafter:
		return
	if (not point.departafter) and arrivebefore
		point.departafter = point.arrivebefore +point.minduration

	elsif (not point.arrivebefore) and point.departbefore
		point.arrivebefore = point.departbefore - point.minduration
	end
	point.save

