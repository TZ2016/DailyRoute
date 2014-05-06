module RoutesHelper
  require 'rubygems'
  require 'json'
  require 'net/http'
  require 'group'
  require 'fuzzy_search'
  SUCCESS                                   = 1
  ERR_REQUEST_FAIL                          = { errCode: -1, messages: 'Request message.' }
  ERR_INVALID_INPUT_TIME                    = { errCode: -2, messages: 'Invalid input time.' }
  ERR_NOT_ENOUGH_TIME_FOR_TRAVEL            = { errCode: -3, messages: 'Not enough time to travel.' }
  ERR_IN_SPECIFY_START_TIME_AND_ARRIVE_TIME = { errCode: -4, messages: 'Start and ending should e the first and last locations.' }
  ERR_NO_ROUTE_FOUND_TO_FIT_SCHEDULE        = { errCode: -5, messages: 'No route found to fit schedule' }
  ERR_IN_CHECK_INPUT                        = { errCode: -6, messages: 'Invalid user input' }
  APP_KEY                                   = "AIzaSyDIIUsYWs7hvODWPqRCaUpIcjn7dGsXSkg"
  APP_KEY_OLD                               = "AIzaSyDjxIMvftYWM2uDN5s5GvFSODrFs2tRWEM"


  def solve(inp)
    unless check_input(inp)
      return ERR_IN_CHECK_INPUT
    end
    parse_format(inp)
    inp['groups'] ? solve_group(inp) : solve_priority(inp)
  end

  def solve_group(inp)
    all_routes = []
    g          = Group.new(inp['groups'], inp['locationList'])
    g.get_groups.each do |comb|
      result = solve_no_priority({ 'locationList' => comb, 'travelMethod' => inp['travelMethod'] })
      if result[:errCode] == SUCCESS
        all_routes += result[:routes]
      end
    end
    if all_routes.empty?
      return ERR_NO_ROUTE_FOUND_TO_FIT_SCHEDULE
    end
    sort_route(all_routes)
    return { errCode: SUCCESS, routes: all_routes }

  end

  def solve_priority(inp)
    deleted = []
    for _ in 0..inp['locationList'].length - 2
      solution = solve_no_priority(inp)
      if solution[:errCode] == SUCCESS
        sort_route(solution[:routes])
        solution[:routes].each { |r| r[:delated] = deleted }
        return solution
      end
      inp['locationList'].first['priority']=-1.0/0.0
      inp['locationList'].last['priority'] =-1.0/0.0
      deleted << remove_min_priority(inp)['searchtext']
    end
    return ERR_NO_ROUTE_FOUND_TO_FIT_SCHEDULE
  end

  def remove_min_priority(inp)
    p = inp['locationList'].map { |x| x['priority'] }
    inp['locationList'].delete_at(p.index(p.max))
  end

  # Use information in INP. Return a hash includes 
  # keys: errCode, (route), (durations), (mode). 
  # route, durations, mode exist if errCode == SUCCESS
  def solve_no_priority(inp)
    init(inp)
    if @err != SUCCESS
      solution = { errCode: @err }
    elsif @fuzzy.empty? and @arranged.length <= 2
      solution = shortest_path(@inp['locationList'])
    elsif @fuzzy.empty?
      solution = fit_schedule
    else
      solution = general_search
    end
    format(solution)
    return solution
  end

  def parse_format(inp)
    @year  = Time.now.year
    @month = Time.now.month
    @day   = Time.now.day
    for loc in inp['locationList']
      loc['arrivebefore'] = read_time(loc['arrivebefore'])
      loc['arriveafter']  = read_time(loc['arriveafter'])
      loc['departbefore'] = read_time(loc['departbefore'])
      loc['departafter']  = read_time(loc['departafter'])
      loc['minduration']  = read_duration(loc['minduration'])
      loc['maxduration']  = read_duration(loc['maxduration'])
      loc['priority']     = loc['priority'].to_i
    end
  end

  #Change the time representation in the sol from Time to DateTime.
  def init(inp)
    @inp                                  = inp
    @err                                  = nil
    @start, @dest, @arranged, @unarranged = nil
    @nonfuzzy, @fuzzy, @intervals, @mode  = nil
    @start                                = @inp['locationList'].first
    @mode                                 = @inp['travelMethod']
    @dest                                 = @inp['locationList'].last
    classify_loc() #set @arranged @unarranged @err
  end


  # Return a hash describe the shortest route from p1 to p2
  # go through all locs in passby.
  def shortest_path(locs)
    result = JSON.parse(request_route(locs))
    if result.has_key? 'Error' or result['status'] != 'OK'
      return ERR_REQUEST_FAIL
    end
    legs  = result['routes'][0]["legs"]
    order = result['routes'][0]['waypoint_order']
    order.map! { |x| x+1 }
    order << locs.length-1
    route1                 = { steps: [], mode: @mode, name: 'route' }
    first_step             = {}
    first_step[:geocode]   = geocode_to_s(legs[0]["start_location"])
    first_step[:name]      = locs[0]['searchtext']
    first_step[:departure] = locs[0]['departafter']
    first_step[:arrival]   = locs[0]['departafter']
    route1[:steps]<< first_step
    legs.each_with_index do |leg, i|
      step             = {}
      step[:geocode]   = geocode_to_s(leg["end_location"])
      step[:name]      = locs[order[i]]['searchtext']
      step[:arrival]   = route1[:steps].last[:departure] + leg["duration"]["value"]
      step[:departure] = step[:arrival] + locs[order[i]]['minduration']
      route1[:steps] << step
    end
    route1[:traveltime] = route1[:steps].last[:arrival] - route1[:steps].first[:departure]
    if route1[:steps].last[:arrival] > locs.last['arrivebefore']
      return ERR_NO_ROUTE_FOUND_TO_FIT_SCHEDULE
    end
    return { errCode: SUCCESS, routes: [route1] }
  end


  def fit_schedule
    get_intervals_and_check_validity #set @interval, @err
    if @err != SUCCESS
      return { errCode: @err }
    end
    num    = @intervals.length
    routes = []

    for i in (0.. @intervals.length ** @unarranged.length-1)
      parts = partition(i, num)
      route = get_route_for_partition(parts)
      if route != {}
        routes << route
      end
    end
    if routes.empty?
      return ERR_NO_ROUTE_FOUND_TO_FIT_SCHEDULE
    else
      routes.sort_by! { |x| x[:traveltime] }
      return { errCode: SUCCESS, routes: routes }
    end
  end


  #Return the shortest route for this PARTITION.
  #Return {} if there is no legal route for this PARTITION
  def get_route_for_partition(partition)
    traveltime             = 0
    all_steps              = []
    first_step             = {}
    first_step[:geocode]   = geocode_to_s(@start['geocode'])
    first_step[:departure] = @start['departafter']
    first_step[:arrival]   = first_step[:departure]
    all_steps << first_step

    for i in (0..@intervals.length - 1)
      locs                = [@arranged[i]]+partition[i]+[@arranged[i+1]]
      time, partial_steps = get_time_and_steps(locs)
      if time > @intervals[i]
        return {}
      else
        all_steps  += partial_steps[1..-1]
        traveltime += time
      end
    end
    return { mode: @mode, name: 'route', \
      traveltime: traveltime, steps: all_steps }
  end


  # Get @intervals for each two consectutive locs in ARRANDED. Return ALL @intervals
  # and ERRCODE. If ERRCODE == SUCCESS, @INTERVALS is valid in that it pass 
  # check_time_validity. 
  def get_intervals_and_check_validity
    @intervals = []
    for i in (0..@arranged.length - 2)
      if @arranged[i]['departafter'] > @arranged[i+1]['arrivebefore']
        @err = ERR_INVALID_INPUT_TIM
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
    for i in (0..@arranged.length - 2)
      if get_time([@arranged[i], @arranged[i+1]]) > @intervals[i]
        return ERR_NOT_ENOUGH_TIME_FOR_TRAVE
      end
    end
    return SUCCESS
  end

  def get_time(locs)
    result = shortest_path(locs)
    return wrap_time(result)
  end

  def wrap_time(result)
    if result[:errCode] == SUCCESS
      return result[:routes][0][:traveltime]
    else
      return Float::INFINITY
    end
  end

  def get_time_and_steps(locs)
    result = shortest_path(locs)
    time   = wrap_time(result)
    if time < Float::INFINITY
      return time, result[:routes][0][:steps]
    else
      return time, []
    end
  end

  def request_route(locs)

    addr      = 'http://maps.googleapis.com/maps/api/directions/json?'
    origin    = 'origin=%s&' % geocode_to_s(locs.first['geocode'])
    dest      = 'destination=%s' % geocode_to_s(locs.last['geocode'])
    waypoints = ''
    if locs.length >= 3
      waypoints = '&waypoints=optimize:true'
      for i in (1..locs.length - 2)
        waypoints += '|' + geocode_to_s(locs[i]['geocode'])
      end
    end
    sensor = "&sensor=false"
    mode   = '&mode=%s' % @mode
    addr   = URI.encode(addr+origin+dest+waypoints+sensor+mode)
    return Net::HTTP.get(URI.parse(addr))
  end

  ## requires @start['departafter'] and end.@startbefore
  def classify_loc
    @arranged, @unarranged = [], []
    @nonfuzzy, @fuzzy      = [], []
    add_time(@inp['locationList'])
    for point in @inp['locationList']
      preprocess(point)
      if point["arrivebefore"]
        @arranged << point
      else
        @unarranged << point
      end
      if point["geocode"] == nil
        @fuzzy << point
      else
        @nonfuzzy << point
      end
    end
    @arranged.sort_by! { |x| x["arrivebefore"] }

    if @arranged.first != @start or @arranged.last != @dest
      @err = ERR_IN_SPECIFY_START_TIME_AND_ARRIVE_TIM
    else
      @err = SUCCESS
    end
  end

  def add_time(locationList)

    if not locationList.first['departafter']
      locationList.first['departafter'] = Time.now
    end
    if not locationList.last['arrivebefore']
      locationList.last['arrivebefore'] = Time.now.end_of_day
    end
  end


  def preprocess(point)
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
    indicator = '0' * (num - indicator.length) + indicator
    result    = []
    for _ in (1..num)
      result << []
    end
    for j in (0..@unarranged.length - 1)
      result[indicator[j].to_i] << @unarranged[j]
    end
    return result
  end

  def read_time(text)
    if text == '' or text == nil
      return nil
    end
    hour, rest = text.split(':')
    minute, ap = rest[0..1], rest[2]
    hour       = hour.to_i
    minute     = minute.to_i
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
    return geocode['lat'].to_s + ',' + geocode['lng'].to_s
  end

  def format(sol)
    priority = @inp['locationList'].map { |x| x['priority'] }.reduce(:+)
    if sol[:errCode] == SUCCESS
      for route in sol[:routes]
        for step in route[:steps]
          step[:departure] = step[:departure].to_datetime
          step[:arrival]   = step[:arrival].to_datetime
        end
        route[:priority] = priority
      end

    end
  end

  def general_search
    routes = []
    for a in FuzzySearch.new(@fuzzy, @nonfuzzy).assign_geocode
      @fuzzy.each_with_index do |l, i|
        l['geocode'] = a[i]
      end
      if @arranged.length <= 2
        solution = shortest_path(@inp['locationList'])
      else
        solution = fit_schedule
      end
      if solution[:errCode] == SUCCESS
        routes = routes + solution[:routes]
      end

    end

    if routes
      return { errCode: SUCCESS, routes: routes }
    else
      return ERR_NO_ROUTE_FOUND_TO_FIT_SCHEDULE
    end

  end


  def sort_route(routes)
    routes.sort_by! { |r| r[:traveltime] + r[:priority] * 1e10 }
  end

  def check_input(inp)
    if inp['locationList'].length < 2
      false
    else
      true
    end
  end

end
