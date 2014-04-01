class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  include SessionsHelper

  require 'rubygems'
  require 'json'
  require 'net/http'
  
  SUCCESS = 1
  ERR_REQUEST_FAIL = -1
  ERR_INVALID_INPUT_TIME = -2

  # start and end are Location. locations is an Array of Location.
  def solve (id)
  	start, dest, locations = getLocations(id)
  	arranged,unarranged,invalid_input = classify_loc(start,locations, dest)
    if invalid_input
  		render :json => {errCode: ERR_INVALID_INPUT_TIME}
  	elsif arranged == []
      shortest_path(start,locations, dest)
  	else
  		fit_schedule(arranged, unarranged)
    end
  end

  def getLocations(id)
  	currRoute = Location.where(routeid: id).to_a
  	start = currRoute.select{|loc| loc.start}
  	dest = currRoute.select{|loc| loc.dest}
  	locations = currRoute.select{|loc| (not loc.start) and (not loc.dest)}
    return start, dest, locations
  end

  ## http://maps.googleapis.com/maps/api/directions/json?origin=Adelaide,SA&destination=Adelaide,SA&waypoints=optimize:true|Barossa+Valley,SA|Clare,SA|Connawarra,SA|McLaren+Vale,SA&sensor=false&key=API_KEY
  def shortest_path(start, locations, dest)
  	result = JSON.parse(request_route(start,locations, dest))

    if result.has_key? 'Error' or result['status'] != 'OK'
  		render :json => {errCode: ERR_REQUEST_FAIL}
  	else
  		order = result['routes'][0]['waypoint_order']
  		ordered_loc = order.map{|x| locations[x]}
  		ordered_loc = (start+ordered_loc+dest).map{|x| x.geocode}
  		render :json => {errCode: SUCCESS, route: ordered_loc}
    end
  end

  def fit_schedule(arranged, unarranged,info)
  end

  def update_db(orderd_loc)
  	for i in (0..ordered_loc.length - 1)
  		ordered_loc[i].positioninroute = i
  	end
  end

  def geocode_to_s(geocode)
  	return geocode[:lat].to_s + ',' + geocode[:lng].to_s
  end 

  def request_route(start, locations, dest)
  	addr = 'http://maps.googleapis.com/maps/api/directions/json?'
  	origin = 'origin=%s&' % geocode_to_s(start[0].geocode) 
  	dest = 'destination=%s' % geocode_to_s(dest[0].geocode)
  	places = ''
  	locations.each do |point|
  		places += '|' + geocode_to_s(point.geocode)
  	end
  	passby = '&waypoints=optimize:true%s&sensor=false' % places
  	addr = URI.encode(addr+origin+dest+passby)

  	require 'net/http'
  	return Net::HTTP.get(URI.parse(addr))
  end

  ## requires start.departafter and end.startbefore
  def classify_loc(start, locations, dest)
  	all_loc = start+locations+dest
  	arranged,unarranged = [],[]

  	all_loc.each do |point|
  		preprocess(point)
      if point.arrivebefore
  			arranged << point
  		else
  			unarranged << point
  		end
  	end

  	arranged.sort_by do |a|
  		a.arrivebefore
  	end
  	invalid_input = false
  	if arranged != [] and (arranged.first != start or arranged.last != dest)
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
  	address = address + origins + destination + mode
  	require 'net/http'
  	return Net::HTTP.get(URI.parse(address))
  end

  def preprocess(point)
    if (point.arrivebefore and point.departafter) or ((not point.arrivebefore) and (not point.departafter))
  		return
    end
  	if (not point.departafter) and point.arrivebefore
  		point.departafter = point.arrivebefore + point.minduration
  	elsif (not point.arrivebefore) and point.departafter
  		point.arrivebefore = point.departbefore - point.minduration
  	end
  	point.save
  end

  def fuzzySearch(center, type)
    address = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
    location = 'location=' + center
    sensor = 'sensor=' + 'true'
    rankby = 'rankby=' + '2'
    types = 'types=' + type
    key = 'key=' + 'AIzaSyDjxIMvftYWM2uDN5s5GvFSODrFs2tRWEM'
    address = address + location + sensor + rankby + types + key
    require 'net/http'
    return Net::HTTP.get(URI.parse(address))
  end

end
