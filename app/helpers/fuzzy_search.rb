class FuzzySearch
  APP_KEY = "AIzaSyDjxIMvftYWM2uDN5s5GvFSODrFs2tRWEM"
  def initialize(fuzzy)
    @fuzzy = fuzzy
  end

  def assign_geocode


  end

  #
  def search_nearby(query, type, radius, center)
    address  = 'https://maps.googleapis.com/maps/api/place/textsearch/json?'
    query    = 'query=' + query
    key      = '&key=' + APP_KEY
    sensor   = '&sensor=' + 'false'
    location = '&location=' + geocode_to_s(center['geocode'])
    radius   = '&radius=' + radius.to_s
    # types = 'types=' + type
    address  = URI.encode(address + query + key + sensor + location + radius + key)
    require 'net/http'
    return Net::HTTP.get(URI.parse(address))
  end

end