class FuzzySearch
  require 'rubygems'
  require 'json'
  require 'net/http'

  APP_KEY = "AIzaSyDjxIMvftYWM2uDN5s5GvFSODrFs2tRWEM"


  def initialize(fuzzy, nonfuzzy)
    @fuzzy = fuzzy
    @center  = {}
    @center['lat'] = nonfuzzy.inject{|sum, n| sum + n['geocode']['lat']}
    @center['lng'] = nonfuzzy.inject{|sum, n| sum + n['geocode']['lng']}
  end

  def assign_geocode

    radius = 3
    params = {radius: radius, center:@center}
    temp = @fuzzy.map{|l| l['searchtext']}
    temp.map do |t|
      params[:query] = t
      matches = search_nearby(params)
      matches.map{|p| p['geometry']}
      matches(1..min(3,matches.length))
    end
    temp[0].product(temp.drop(1))





  end


  #
  def self.search_nearby(params)
    address  = 'https://maps.googleapis.com/maps/api/place/textsearch/json?'
    query    = 'query=' + params[:query]
    key      = '&key=' + APP_KEY
    sensor   = '&sensor=' + 'false'
    location = '&location=' + self.geocode_to_s(params[:center])
    radius   = '&radius=' + params[:radius].to_s
    # types = 'types=' + type
    addr = address + query + key + sensor + location + radius
    address  = URI.encode(addr)
    return JSON.parse(Net::HTTP.get(URI.parse(address)))
  end

  def self.geocode_to_s(geocode)
    geocode['lat'].to_s + ',' + geocode['lng'].to_s
  end

end