require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the RoutesHelper. For example:
#
# describe RoutesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe RoutesHelper do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'search_nearby' do
    it 'returns a list of nearby matches' do
      a = {}
      a[:query]= 'supermarket'
      a[:radius]=3
      a[:center]={'lat' => 37.8696154, 'lng' => -122.25849}
      b = FuzzySearch.search_nearby(a)
      b.should have_key('results')
    end
  end
end


