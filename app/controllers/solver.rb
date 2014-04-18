module Solver
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  include SessionsHelper

  require 'rubygems'
  require 'json'
  require 'net/http'
  require 'pp'
  SUCCESS = 1
  ERR_REQUEST_FAIL = -1
  ERR_INVALID_INPUT_TIME = -2
  ERR_NOT_ENOUGH_TIME_FOR_TRAVEL = -3
  ERR_NEED_SPECIFY_START_TIME_AND_ARRIVE_TIME = -4

  # start and end are Location. locations is an Array of Location.
  def solve
    for loc in @inp.locationList
      loc['arrivebefore'] = read_time(loc['arrivebefore'])
      loc['arriveafter'] = read_time(loc['arriveafter'])
      loc['departbefore'] = read_time(loc['departbefore'])
      loc['departafter'] = read_time(loc['departafter'])
    end
    @start = @inp.locationList.first
    @mode = @inp.travelMethod
    @dest = @inp.locationList.last
  	arranged,unarranged, fuzzy, err = classify_loc(start,locations, dest)
    if err != SUCCESS
      pp ' ========HERE=============== '
  		render :json => {errCode: err}
    elsif fuzzy == []
      render :json => solve_helper(arranged, unarranged, start, dest, locations, mode)
    else
      render :json => general_search(fuzzy)
    end
  end


  def solve_helper(arranged, unarranged, start, dest, locations, mode)
    if arranged == []
      puts '============call shortest_path========='
      return shortest_path(start,locations, dest, mode)
    else
      puts '============call fit_schedule========='
      return fit_schedule(arranged, unarranged, mode)
    end
  end
   
  #
  def general_search(fuzzy)
  end

   # AIzaSyDjxIMvftYWM2uDN5s5GvFSODrFs2tRWEM
  def search_nearby(query, type, radius, center)
    address = 'https://maps.googleapis.com/maps/api/place/textsearch/json?'
    query = 'query=' + query
    key = '&key=' + 'AIzaSyDjxIMvftYWM2uDN5s5GvFSODrFs2tRWEM'
    sensor = '&sensor=' + 'false'
    location = '&location=' + geocode_to_s(center.geocode)
    radius = '&radius=' + radius.to_s
    # types = 'types=' + type
    address = URI.encode(address + query + key + sensor + location + radius)
    require 'net/http'
    return Net::HTTP.get(URI.parse(address))
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
    pp '=========in shortest path========='
    pp start
    pp dest
    pp locations
  	result = JSON.parse(request_route(start,locations, dest, mode))
    if result.has_key? 'Error' or result['status'] != 'OK'
  		return {errCode: ERR_REQUEST_FAIL}
    end
    legs = result["legs"]
  	routes = []
  	first_step = {}
    first_step[:geocode] = geocode_to_s(@start.geocode)
    fisrt_step[:departtime] = @start.departafter
    fisrt_step[:arrivetime] = fisrt_step[:departtime] + legs[0]["duration"]["value"]}
    routes << first_step
		for leg in result["legs"]
      step = {}
      step[:geocode] = geocode_to_s(leg["end_location"])
      step[:departtime] = route.last[:arrivetime]
      step[:arrivetime] = step[:departtime] + leg["duration"]["value"]
			routes << step
    end
		# order = result['routes'][0]['waypoint_order']
		# ordered_loc = order.map{|x| locations[x]}
		# ordered_loc = (start+ordered_loc+dest).map{|x| x.geocode}
    totaltime = result['routes'][0]['legs'].map{|x| x['duration']['value']}.inject(:+)
		return {errCode: SUCCESS, routes: [routes], duration: [totaltime], mode: mode}
  end


  
  def fit_schedule(arranged, unarranged, mode)
    puts '================= inside fitschd ====================='
    intervals, err = get_intervals(arranged, mode)
    if err != SUCCESS
      return {errCode: err}
    end
    num = intervals.length
    durations = []
    routes = []

    for i in (0.. intervals.length ** unarranged.length-1)
      parts = partition(i, num, unarranged)
      order, dur, ifsuccess =  get_time_for_partition(parts, intervals, arranged, mode)
      if ifsuccess
        routes << order
        durations << dur
      end
    end
    result = []
    for i in (0..routes.length-1)
      result << [routes[i], durations[i]] 
    end
    result.sort_by!{|x| x[1]}
    routes = result.map{|x| x[0]}
    durations = result.map{|x| x[1]}
    pp '============TO RETURN==============='
    pp result
    return {errCode: SUCCESS, route: routes, duration: durations, mode: mode}
  end




  def get_time_for_partition(partition, intervals, arranged, mode)
    order = []
    duration = 0
    for i in (0..intervals.length - 1)
      time = get_time(arranged[i], partition[i], arranged[i+1], mode)
      if time > intervals[i]
        return [], 0, false
      else
        order << arranged[i]
        order = order + partition[i]
        duration += time
      end
    end
    order << arranged.last
    order = order.map{|x| x.geocode}
    return order, duration, true
  end



  def get_time(start, pass, dest, mode)

    pp '============= inside get time =========================='
    result = shortest_path([start], pass, [dest], mode)
    if result[:errCode] == SUCCESS 
        pp '=============result==========='
        pp result
        return result[:duration][0]
    else
        return Float::INFINITY
    end
  end
  
  def partition(i, num, unarranged)
    if num <= 1
      indicator = ''
    else 
      indicator = i.to_s(num)
    end
    pp [i, num, indicator]
    indicator = '0' * (num - indicator.length) + indicator
    result = []
    for _ in (1..num)
      result << []
    end
    pp '============PARTITION================'
    pp unarranged.length
    pp indicator
    pp result
    for j in (0..unarranged.length - 1)
        puts '========= Indicator ==================='
        result[indicator[j].to_i] << unarranged[j]
    end
    pp result
    return result
  end

  def get_intervals(arranged, mode)
    intervals = []
    pp arranged
    for i in (0..arranged.length - 2)
      if arranged[i].departafter > arranged[i+1].arrivebefore
        puts '===============HAHA======================'
        pp arranged[i].departafter
        pp arranged[i+1].arrivebefore
        return [], ERR_INVALID_INPUT_TIME
      else
        intervals << arranged[i+1].arrivebefore - arranged[i].departafter
      end
    end 
    return intervals, check_time_validity(intervals, arranged, mode)  
  end

  def check_time_validity(intervals, arranged, mode)
    pp '============check_time_validity====================='
    for i in (0..arranged.length - 2)
      pp arranged[i]
      pp arranged[i+1]
      if get_time(arranged[i], [], arranged[i+1], mode) > intervals[i]
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
    pp '=============inside request route========='
    pp start
    pp  dest
    addr = 'http://maps.googleapis.com/maps/api/directions/json?'
    
    origin = 'origin=%s&' % geocode_to_s(start[0].geocode) 
    dest = 'destination=%s' % geocode_to_s(dest[0].geocode)
    places = ''
    pp locations
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
    pp '===============Classify loc==================='
    all_loc = start+locations+dest
    arranged,unarranged, fuzzy = [],[], []

    all_loc.each do |point|
      preprocess(point)
      if point.arrivebefore
        arranged << point
      else
        unarranged << point
      end
      if point.geocode == nil
        fuzzy << point
      end
    end
    arranged.sort_by!{|x| x.arrivebefore}
    pp arranged
    if arranged != [] and (arranged.first != start[0] or arranged.last != dest[0])
    return [], [], [], ERR_NEED_SPECIFY_START_TIME_AND_ARRIVE_TIME
    end
    return arranged, unarranged, fuzzy, SUCCESS
  end


  def preprocess(point)
    puts '============================================='
    pp point
    if (point.arrivebefore and point.departafter) or ((not point.arrivebefore) and (not point.departafter))
      return
    end
    if (not point.departafter) and point.arrivebefore
      point.departafter = point.arrivebefore + point.minduration
    elsif (not point.arrivebefore) and point.departafter
      point.arrivebefore = point.departafter - point.minduration
    end
    point.save
  end

  private
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



end
end
