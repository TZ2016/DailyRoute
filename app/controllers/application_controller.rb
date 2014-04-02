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
  ERR_NOT_ENOUGH_TIME_FOR_TRAVEL = -3

  # start and end are Location. locations is an Array of Location.
  def solve (id)
  	start, dest, locations = getLocations(id)
    mode = Route.find(id).travelMethod
  	arranged,unarranged,invalid_input = classify_loc(start,locations, dest)
    if invalid_input
  		render :json => {errCode: ERR_INVALID_INPUT_TIME}
  	elsif arranged == []
      render :json => shortest_path(start,locations, dest, mode)
  	else
  		render :json => fit_schedule(arranged, unarranged, mode)
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
  def shortest_path(start, locations, dest, mode)
  	result = JSON.parse(request_route(start,locations, dest, mode))

    if result.has_key? 'Error' or result['status'] != 'OK'
  		return {errCode: ERR_REQUEST_FAIL}
  	else
  		order = result['routes'][0]['waypoint_order']
  		ordered_loc = order.map{|x| locations[x]}
  		ordered_loc = (start+ordered_loc+dest).map{|x| x.geocode}
      totaltime = result['routes'][0]['legs'].map{|x| x['duration']['value']}.inject(:+)
  		return {errCode: SUCCESS, route: [ordered_loc] * 3, duration: [totaltime] }
    end
  end


  
  def fit_schedule(intervals, arranged, unarranged, mode)
    num = intervals.length
    result = []
    for i in (0.. intervals.length ** unarranged.length)
      parts = partition(i, num, unarranged)
      result << get_time_for_partition(parts, intervals, arranged, mode)
    end
    result.sort{|x, y| x[1] <=> y[1]}
    return {errCode: SUCCESS, route: result.map{|x| x[0]}, duration: result.map{|x| x[1]}}
  end



  def get_time_for_partition(partition, intervals, arranged, mode)
    order = []
    durations = 0
    for i in (0..length(intervals) - 1)
      time = get_time(arranged[i], partition[i], arranged[i+1], mode)
      if time > intervals[i]
        return [], []
      else
        order << arranged[i]
        order = order + partition
        order << arranged[i + 1]
        durations += time
      end
    end
    return order, durations
  end



  def get_time(start, pass, dest, mode)
    result = shortest_path(start, pass, dest, mode)
    if result['errCode'] = SUCCESS 
        return result['duration'][0]
    else
        return Float::INFINITY
    end
  end
  
  def partition(i, num, unarranged)
    indicator = i.to_s(num)
    result = [[]] * num
    for j in (0..length(unarranged) - 1)
      if j < indicator.length 
        result[indicator[j]] << unarranged[j]
      else
        result[0] << unarranged[j]
      end
    end
    return result
  end

  def getIntervals(arranged, mode)
    intervals = []
    for i in (0..arranged.length - 2)
      if arranged[i].departafter > arranged[i+1].arrivebefore
        return [], ERR_INVALID_INPUT_TIME
      else
        intervals << arranged[i+1].arrivebefore - arranged[i].departafter
      end
    end  
    return intervals, check_time_validity(intervals, arranged, mode)  
  end

  def check_time_validity(intervals, arranged, mode)
    for i in (0..arranged.length - 2)
      if get_time(arranged[i], [], arranged[i+1], mode)['duration'] > intervals[i]
        return ERR_NOT_ENOUGH_TIME_FOR_TRAVEL
      end
    end
    return SUCCESS
  end
  
  def update_db(orderd_loc)
    for i in (0..ordered_loc.length - 1)
      ordered_loc[i].positioninroute = i
    end
  end

  def geocode_to_s(geocode)
    return geocode[:lat].to_s + ',' + geocode[:lng].to_s
  end 

  def request_route(start, locations, dest, mode)
    addr = 'http://maps.googleapis.com/maps/api/directions/json?'
    origin = 'origin=%s&' % geocode_to_s(start[0].geocode) 
    dest = 'destination=%s' % geocode_to_s(dest[0].geocode)
    places = ''
    
    locations.each do |point|
      places += '|' + geocode_to_s(point.geocode)
    end
    
    passby = '&waypoints=optimize:true%s&sensor=false' % places
    mode = '&mode=%s' % mode
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

  def fuzzySearch(center, type, radius)
    address = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
    location = 'location=' + center
    sensor = 'sensor=' + 'true'
    rankby = 'rankby=' + radius.to_s
    types = 'types=' + type
    key = 'key=' + 'AIzaSyDjxIMvftYWM2uDN5s5GvFSODrFs2tRWEM'
    address = address + location + sensor + rankby + types + key
    require 'net/http'
    return Net::HTTP.get(URI.parse(address))
  end

end
  # def fit_schedule(arranged, unarranged, mode)
  #   intervals, err = getIntervals(arranged)
  #   if not err = SUCCESS
  #     return {errCode: err}
  #   end

  # end

  # def fit_schedule_helper(intervals, arranged, unarranged, mode， sofar)
  #   if intervals = []
  #     return true, []
  #   end
  #   for i in (0..arranged.length - 2)
  #     result = fit_interval(intervals[i],\
  #       arranged[i], arranged[i+1], unarranged, mode)
  #     for pass, nonpass in result
 

  # http://maps.googleapis.com/maps/api/distancematrix/json?origins=Vancouver+BC|Seattle&destinations=San+Francisco|Victoria+BC&mode=bicycling&language=fr-FR&sensor=false&key=API_KEY
  # def request_distance(locations)
  #   address = 'http://maps.googleapis.com/maps/api/distancematrix/json?'
  #   places = ''
  #   locations.each do |point|
  #     places = point.geocode+'|'
  #   end
  #   places[places.length-1]='&'
  #   origins = 'origins='+places
  #   destination = 'destinations='+places
  #   # mode = 'mode=' + @route.travelMethod
  #   address = address + origins + destination + mode
  #   require 'net/http'
  #   return Net::HTTP.get(URI.parse(address))
  # end
  
  # def fit_interval(dur, start, dest, unarranged, mode) 
  #   for i in (0..2**length(unarranged))
  #     pass, nonpass = passby(i, unarranged)
  #     time_consumed = get_time(start, pass, dest, mode)
  #     if time_consumed <= dur
  #       result << [pass, nonpass, time_consumed]
  #     end
  #   end
  #   return result
  # end
  
  
  # def passby(i, unarranged)
  #   indicator = i.to_s(2)
  #   passby = []
  #   for j in (0..length(unarranged))
  #     if j < indicator.length and i[j] == '1' 
  #       passby << unarranged[j]
  #     else
  #       nonpassby << unarranged[j]
  #   end
  #   return passby, nonpassby
  # end
