class FuzzySearch
  require 'rubygems'
  require 'json'
  require 'net/http'
  APP_KEY = "AIzaSyDIIUsYWs7hvODWPqRCaUpIcjn7dGsXSkg"


  APP_KEY_OLD = "AIzaSyDjxIMvftYWM2uDN5s5GvFSODrFs2tRWEM"
  attr_accessor :center, :fuzzy


  def initialize(fuzzy, nonfuzzy)
    @fuzzy = fuzzy
    @center  = {}
    @center['lat'] = nonfuzzy.map{|n| n['geocode']['lat']}.reduce(:+)/nonfuzzy.length
    @center['lng'] = nonfuzzy.map{|n| n['geocode']['lng']}.reduce(:+)/nonfuzzy.length
  end

  def assign_geocode

    radius = 5
    params = {radius: radius, center:@center}
    temp = @fuzzy.map{|l| l['searchtext']}
    locations = []
    temp.each do |t|
      params[:query] = t
      matches = FuzzySearch.search_nearby(params)
      matches = matches['results']
      matches = matches.map{|p| p['geometry']['location']}
      locations << matches[1..[3,matches.length].min]
    end
    locations[0].product(*locations.drop(1))
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