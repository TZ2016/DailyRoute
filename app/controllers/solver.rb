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
  ERR_NEED_SPECIFY_@START_TIME_AND_ARRIVE_TIME = -4
  APP_KEY = "AIzaSyDjxIMvftYWM2uDN5s5GvFSODrFs2tRWEM"

  # Use information in @inp. Return a hash includes 
  # keys: errCode, (route), (durations), (mode). 
  # route, durations, mode exist if errCode == SUCCESS
  def solve(inp)
    initialize() 
    if @err != SUCCESS
      pp ' ========HERE=============== '
  		return {errCode: @err}
    elsif @fuzzy.empty? and @arranged.empty?
      return shortest_path(@inp['locationList'])
    elsif @fuzzy.empty?
      return fit_schedule
    else
      return general_search
    end
  end

  # Clear all instance variables. Called in the beginning of any solve.
  def initialize(inp)
    @inp = inp
    @start, @dest, @mode, @arranged, @unarranged, @intervals = nil
    @year = DateTime.now.year
    @month = DateTime.now.month
    @day = DateTime.now.day
    for loc in @inp['locationList']
      loc['arrivebefore'] = read_time(loc['arrivebefore'])
      loc['arriveafter'] = read_time(loc['arriveafter'])
      loc['departbefore'] = read_time(loc['departbefore'])
      loc['departafter'] = read_time(loc['departafter'])
      loc['minduration'] = read_time(loc['minduration'])
      loc['maxduration'] = read_time(loc['maxduration'])
    end
    @start = @inp['locationList'].first
    @mode = @inp['travelMethod']
    @dest = @inp['locationList'].last
    classify_loc() #set @arranged @unarranged @err
  end



  # Return a hash describe the shortest route from p1 to p2
  # go through all locs in passby.
  def shortest_path(locs)
    # pp '=========in shortest path========='
    # pp @start
    # pp @dest
    # pp locations
    result = JSON.parse(request_route(locs))
    if result.has_key? 'Error' or result['status'] != 'OK'
      return {errCode: ERR_REQUEST_FAIL}
    end
    legs = result["legs"]
    routes = []
    first_step = {}
    first_step[:geocode] = geocode_to_s(p1['geocode'])
    fisrt_step[:departtime] = p1['departafter']
    fisrt_step[:arrivetime] = fisrt_step[:departtime] + legs[0]["duration"]["value"]
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
    # ordered_loc = (@start+ordered_loc+@dest).map{|x| x['geocode']}
    totaltime = result['routes'][0]['legs'].map{|x| x['duration']['value']}.inject(:+)
    return {errCode: SUCCESS, route: [routes], duration: [totaltime], mode: @mode}
  end


  
  def fit_schedule
    # puts '================= inside fitschd ====================='
    get_intervals_and_check_validity  #set @interval, @err
    if @err != SUCCESS
      return {errCode: @err}
    end
    num = @intervals.length
    durations = []
    routes = []

    for i in (0.. @intervals.length ** @unarranged.length-1)
      parts = partition(i, num, @unarranged)
      order, dur, ifsuccess =  get_time_for_partition(parts, @intervals, @arranged, @mode)
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
    # pp '============TO RETURN==============='
    # pp result
    return {errCode: SUCCESS, route: routes, duration: durations, mode: @mode}
  end




  def get_time_for_partition(partition)
    order = []
    duration = 0
    for i in (0..@intervals.length - 1)
      time = get_time([@arranged[i]]+partition[i]+[@arranged[i+1]])
      if time > @intervals[i]
        return [], 0, false
      else
        order << @arranged[i]
        order = order + partition[i]
        duration += time
      end
    end
    order << @arranged.last
    order = order.map{|x| x['geocode']}
    return order, duration, true
  end



  def get_time(locs)
    pp '============= inside get time =========================='
    result = shortest_path(locs)
    if result[:errCode] == SUCCESS 
        pp '=============result==========='
        pp result
        return result[:duration][0]
    else
        return Float::INFINITY
    end
  end
  
  def partition(i, num)
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
    pp @unarranged.length
    pp indicator
    pp result
    for j in (0..@unarranged.length - 1)
        puts '========= Indicator ==================='
        result[indicator[j].to_i] << @unarranged[j]
    end
    pp result
    return result
  end

  # Get @intervals for each two consectutive locs in ARRANDED. Return ALL @intervals 
  # and ERRCODE. If ERRCODE == SUCCESS, @INTERVALS is valid in that it pass 
  # check_time_validity. 
  def get_intervals_and_check_validity
    @intervals = []
    pp @arranged
    for i in (0..@arranged.length - 2)
      if @arranged[i]['departafter'] > @arranged[i+1]['arrivebefore']
        puts '===============HAHA======================'
        pp @arranged[i]['departafter']
        pp @arranged[i+1]['arrivebefore']
        @err = ERR_INVALID_INPUT_TIME
        return
      else
        @intervals << @arranged[i+1]['arrivebefore'] - @arranged[i]['departafter']
      end
    end 
    @err = check_time_validity(@intervals, @arranged)
  end

  # @INTERVALS are a list of Time. @ARRANGED is list of locations. Return 
  # SUCCESS iff interval i is long enough to travel from loc i to loc i+1.
  def check_time_validity
    pp '============check_time_validity====================='
    for i in (0..@arranged.length - 2)
      pp @arranged[i]
      pp @arranged[i+1]
      if get_time(@arranged[i], [], @arranged[i+1]) > @intervals[i]
        return ERR_NOT_ENOUGH_TIME_FOR_TRAVEL
      end
    end
    return SUCCESS
  end


  def request_route(locs)
    pp '=============inside request route========='

    addr = 'http://maps.googleapis.com/maps/api/directions/json?'
    origin = 'origin=%s&' % geocode_to_s(locs.first['geocode']) 
    dest = 'destination=%s' % geocode_to_s(locs.last['geocode'])
    places = ''
    locations.each do |point|
      places += '|' + geocode_to_s(point['geocode'])
    end   
    waypoints = '&waypoints=optimize:true%s&sensor=false' % places
    mode = '&mode=%s' % @mode
    addr = URI.encode(addr+origin+dest+waypoints+mode)

    require 'net/http'
    return Net::HTTP.get(URI.parse(addr))
  end

  ## requires @start['departafter'] and end.@startbefore
  def classify_loc
    pp '===============Classify loc==================='
    @arranged,@unarranged, fuzzy = [],[], []
    @inp.locationList.each do |point|
      preprocess(point)
      if point["arrivebefore"]
        @arranged << point
      else
        @unarranged << point
      end
      if point["geocode"] == nil
        fuzzy << point
      end
    end
    @arranged.sort_by!{|x| x["arrivebefore"]}
    pp @arranged
    
    if @arranged != [] and (@arranged.first != @start or @arranged.last != @dest)
      return [], [], [], ERR_NEED_SPECIFY_START_TIME_AND_ARRIVE_TIME
    end

    return @arranged, @unarranged, fuzzy, SUCCESS
  end


  def preprocess(point)
    puts '============================================='
    pp point
    if (point['arrivebefore'] and point['departafter']) or \
     ((not point['arrivebefore']) and (not point['departafter']))
      return
    end

    if (not point['departafter']) and point['arrivebefore']
      point['departafter'] = point['arrivebefore'] + point.minduration
    elsif (not point['arrivebefore']) and point['departafter']
      point['arrivebefore'] = point['departafter'] - point.minduration
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
    return DateTime.new(@year, @month, @day, hour, minute)
  end

  def read_duration(text)
    if text == '' or text == nil
      return 0
    end
    hour, minute = text.split(':')
    hour, minute = hour.to_i, minute.to_i
    return hour * 3600 + minute * 60
  end

  def geocode_to_s(geocode)
    return geocode[:lat].to_s + ',' + geocode[:lng].to_s
  end 

  def general_search
  end

   # 
  def search_nearby(query, type, radius, center)
    address = 'https://maps.googleapis.com/maps/api/place/textsearch/json?'
    query = 'query=' + query
    key = '&key=' + APP_KEY
    sensor = '&sensor=' + 'false'
    location = '&location=' + geocode_to_s(center['geocode'])
    radius = '&radius=' + radius.to_s
    # types = 'types=' + type
    address = URI.encode(address + query + key + sensor + location + radius)
    require 'net/http'
    return Net::HTTP.get(URI.parse(address))
  end

end
