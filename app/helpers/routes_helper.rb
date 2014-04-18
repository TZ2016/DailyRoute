module RoutesHelper
  require 'rubygems'
  require 'json'
  require 'net/http'
  require 'pp'
  SUCCESS = 1
  ERR_REQUEST_FAIL = -1
  ERR_INVALID_INPUT_TIME = -2
  ERR_NOT_ENOUGH_TIME_FOR_TRAVEL = -3
  ERR_IN_SPECIFY_START_TIME_AND_ARRIVE_TIME = -4
  APP_KEY = "AIzaSyDjxIMvftYWM2uDN5s5GvFSODrFs2tRWEM"

  # Use information in @inp. Return a hash includes 
  # keys: errCode, (route), (durations), (mode). 
  # route, durations, mode exist if errCode == SUCCESS
  def solve(inp)
    pp '================In solve ===================='
    init(inp) 
    if @err != SUCCESS
      pp ' ========Error in classify=============== '
  		solution = {errCode: @err}
    elsif @fuzzy.empty? and @arranged.length == 2
      solution = shortest_path(@inp['locationList'])
    elsif @fuzzy.empty?
      solution = fit_schedule
    else
      solution = general_search
    end
    
    pp '===================formatted solution======================'
    format(solution)
    pp solution
    return solution
  end

  #Change the time representation in the sol from Time to DateTime.
  
  def init(inp)
    @inp = inp
    @start, @dest, @mode, @arranged, @unarranged, @fuzzy, @intervals = nil
    @year = DateTime.now.year
    @month = DateTime.now.month
    @day = DateTime.now.day
    for loc in @inp['locationList']
      loc['arrivebefore'] = read_time(loc['arrivebefore'])
      loc['arriveafter'] = read_time(loc['arriveafter'])
      loc['departbefore'] = read_time(loc['departbefore'])
      loc['departafter'] = read_time(loc['departafter'])
      loc['minduration'] = read_duration(loc['minduration'])
      loc['maxduration'] = read_duration(loc['maxduration'])
    end
    @start = @inp['locationList'].first
    @mode = @inp['travelMethod']
    @dest = @inp['locationList'].last
    classify_loc() #set @arranged @unarranged @err
  end



  # Return a hash describe the shortest route from p1 to p2
  # go through all locs in passby.
  def shortest_path(locs)
    pp '=========in shortest path========='
    
    result = JSON.parse(request_route(locs))
    if result.has_key? 'Error' or result['status'] != 'OK'
      return {errCode: ERR_REQUEST_FAIL}
    end
    legs = result['routes'][0]["legs"]
    route1 = {steps:[], mode:@mode, name:'route'}
    first_step = {}
    # pp legs
    first_step[:geocode] = geocode_to_s(legs[0]["start_location"])
    first_step[:departure] = locs[0]['departafter']
    first_step[:arrival] = first_step[:departure] + legs[0]["duration"]["value"]
    route1[:steps]<< first_step
    for leg in legs
      step = {}
      step[:geocode] = geocode_to_s(leg["end_location"])
      step[:departure] = route1[:steps].last[:arrival]
      step[:arrival] = step[:departure] + leg["duration"]["value"]
      route1[:steps] << step
    end
    # order = result['routes'][0]['waypoint_order']
    # ordered_loc = order.map{|x| locations[x]}
    # ordered_loc = (@start+ordered_loc+@dest).map{|x| x['geocode']}
    route1[:traveltime] = result['routes'][0]['legs'].map{|x| x['duration']['value']}.inject(:+)
    return {errCode: SUCCESS, routes: [route1]}
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



  

  # Get @intervals for each two consectutive locs in ARRANDED. Return ALL @intervals 
  # and ERRCODE. If ERRCODE == SUCCESS, @INTERVALS is valid in that it pass 
  # check_time_validity. 
  def get_intervals_and_check_validity
    puts '===============inside get_intervals_and_check_validity======================'
    @intervals = []
    pp @arranged
    for i in (0..@arranged.length - 2)
      if @arranged[i]['departafter'] > @arranged[i+1]['arrivebefore']
        pp @arranged[i]['departafter']
        pp @arranged[i+1]['arrivebefore']
        @err = ERR_INVALID_INPUT_TIME
        return
      else
        @intervals << @arranged[i+1]['arrivebefore'] - @arranged[i]['departafter']
      end
    end 
    @err = check_time_validity
  end

  # @INTERVALS is a list of time in second. @ARRANGED is list of locations. Return 
  # SUCCESS iff interval i is long enough to travel from loc i to loc i+1.
  def check_time_validity
    pp '============check_time_validity====================='
    for i in (0..@arranged.length - 2)
      pp @arranged[i]
      pp @arranged[i+1]
      if get_time([@arranged[i],@arranged[i+1]]) > @intervals[i]
        pp '==============interval length==========='
        pp @intervals
        pp '=========cost time============='
        pp get_time([@arranged[i],@arranged[i+1]])
        return ERR_NOT_ENOUGH_TIME_FOR_TRAVEL
      end
    end
    return SUCCESS
  end

  def get_time(locs)
    pp '============= inside get time =========================='
    result = shortest_path(locs)
    pp '    =============result==========='
    pp result
    if result[:errCode] == SUCCESS 
        return result[:routes][0][:traveltime]
    else
        return Float::INFINITY
    end
  end

  def request_route(locs)
    pp '=============inside request route========='

    addr = 'http://maps.googleapis.com/maps/api/directions/json?'
    origin = 'origin=%s&' % geocode_to_s(locs.first['geocode']) 
    dest = 'destination=%s' % geocode_to_s(locs.last['geocode'])
    waypoints = ''
    if locs.length >= 3
      waypoints = '&waypoints=optimize:true'
      for i in (2..locs.length - 2)
        waypoints += '|' + geocode_to_s(loc[i]['geocode'])
      end
    end   
    sensor = "&sensor=false"
    mode = '&mode=%s' % @mode
    addr = URI.encode(addr+origin+dest+waypoints+sensor+mode)
    pp addr
    require 'net/http'
    return Net::HTTP.get(URI.parse(addr))
  end

  ## requires @start['departafter'] and end.@startbefore
  def classify_loc
    pp '===============Classify loc==================='
    @arranged,@unarranged, @fuzzy = [],[], []
    for point in @inp['locationList']
      preprocess(point)
      if point["arrivebefore"]
        @arranged << point
      else
        @unarranged << point
      end
      if point["geocode"] == nil
        @fuzzy << point
      end
    end
    @arranged.sort_by!{|x| x["arrivebefore"]}
    pp '=====first===='
    pp @arranged.first 
    pp @start 
    pp '=====last===='
    pp @arranged.last
    pp @dest
    
    if @arranged.first != @start or @arranged.last != @dest
      @err = ERR_IN_SPECIFY_START_TIME_AND_ARRIVE_TIME
    else
      @err = SUCCESS
    end
    pp @err
  end


  def preprocess(point)
    puts '==================preprocess==========================='
    pp point
    if (point['arrivebefore'] and point['departafter']) or \
     ((not point['arrivebefore']) and (not point['departafter']))
      return
    end

    if (not point['departafter']) and point['arrivebefore']
      point['departafter'] = point['arrivebefore'] + point['minduration']
    elsif (not point['arrivebefore']) and point['departafter']
      point['arrivebefore'] = point['departafter'] - point['minduration']
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
  
  def read_time(text)
    if text == '' or text == nil
      return nil
    end
    hour, rest = text.split(':')
    minute, ap = rest[0..1], rest[2]
    hour = hour.to_i
    minute = minute.to_i
    if ap == 'p' and hour != 12
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

  def geocode_to_s(geocode)
    pp '===========inside geocode_to_s=============='
    pp geocode
    return geocode['lat'].to_s + ',' + geocode['lng'].to_s
  end 
  
  def format(sol)
    if sol[:errCode] == SUCCESS
      for route in sol[:routes]
        for step in route[:steps]
          step[:departure] = step[:departure].to_datetime
          step[:arrival] = step[:arrival].to_datetime
        end
      end
    end
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
