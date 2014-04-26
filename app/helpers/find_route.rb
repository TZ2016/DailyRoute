class FindRoute
  def initialize(inp)
    @inp = inp
    @err = nil
    @start, @dest, @mode, @arranged, @unarranged, @fuzzy, @intervals = nil
    @start = @inp['locationList'].first
    @mode = @inp['travelMethod']
    @dest = @inp['locationList'].last
    classify_loc() #set @arranged @unarranged @err
  end
end