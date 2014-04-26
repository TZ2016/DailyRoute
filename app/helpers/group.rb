class Group
  def initialize(groups_text, location_list)
    @groups = groups_text.map{|g|\
      g.map{|t| location_list.find{|l|\
       l['searchtext'] == t}}}
    all_grouped = @groups.reduce(:+)
    @ungrouped = location_list.select{|x|  !all_grouped.include?(x)}


  end

  def get_groups
    combinations = @groups[0].product(*@groups.drop(1))
    combinations = combinations.map{|c|\
     [@ungrouped[0]] + c + @ungrouped[1..-1]}
  end
end