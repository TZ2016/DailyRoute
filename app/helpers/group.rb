class Group
  def initialize(groups_text, location_list)
    @groups = groups_text.map{|g|\
      g.map{|t| location_list.find{|l|\
       l['searchtext'] == t}}}
    all_grouped = @groups.reduce(:+)
    @ungrouped = location_list.select{|x|  !all_grouped.include?(x)}
    @groups = groups
  end

  def group_iter()
    combinations = @groups[0].product(*@groups.drop(1))
    combinations.sort_by!{|x| x.inject{|sum ,loc| sum + loc['priority']}}
    for c in combinations
      yield [@ungrouped[0] + c + @ungrouped[1..-1]]
    end

  end

end