class Group
  def initialize(groups_text, location_list)
    @groups     = groups_text.map do |g|
      g.map do |t|
        location_list.find { |l| l['searchtext'] == t }
      end
    end
    all_grouped = @groups.reduce(:+)
    @ungrouped  = location_list.select { |x| !all_grouped.include?(x) }
  end

  def get_groups
    @groups[0].product(*@groups.drop(1)).map do |c|
      [@ungrouped.first] + c + @ungrouped.drop(1)
    end
  end
end