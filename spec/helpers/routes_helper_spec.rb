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


  describe FuzzySearch do
    before do
      @supermarket               = {}
      @supermarket['searchtext'] = 'supermarket'
      @restaurant                = {}
      @restaurant['searchtext']  = 'restaurant'
      @home                      = {}
      @school                    = {}
      @home['geocode']           = { 'lat' => -122.2564121, 'lng' => 37.8644885 }
      @school['geocode']         = { 'lat' => -122.2584081, 'lng' => 37.8757857 }
      @nonfuzzy                  = [@home, @school]
    end


    describe @search do
      before do
        @fuzzy  = [@supermarket, @restaurant]
        @search = FuzzySearch.new(@fuzzy, @nonfuzzy)
      end
      it 'has center' do
        @search.center.should_not be_nil
      end
      it 'center is represent geocode' do
        @search.center.should have_key('lat')
        @search.center.should have_key('lng')
      end

      it 'center\'s latitude is correct calculated' do
        @search.center['lat'].should equal((-122.2564121+-122.2584081)/2)
      end

      it 'center\'s longitude is correct calculated' do
        @search.center['lng'].should equal((37.8644885+37.8757857)/2)
      end

      it 'has fuzzy' do
        @search.fuzzy.should_not be_nil
      end


    end


    describe 'search_nearby' do
      before do
        a         = {}
        a[:query] = 'supermarket'
        a[:radius]=3
        a[:center]={ 'lat' => 37.8696154, 'lng' => -122.25849 }
        @result   = FuzzySearch.search_nearby(a)
      end
      it 'returns a list of nearby matches' do
        @result.should have_key('results')
      end
      it 'has geometry' do
        @result['results'].each do |r|
          r.should have_key('geometry')
        end
      end

    end

    describe 'assign_geocode' do
      describe '1 fuzzy location' do
        before do
          @result = FuzzySearch.new([@supermarket], @nonfuzzy).assign_geocode
        end
        it 'return 3 closest place' do
          @result.should have_at_most(3).items
        end
        it 'return a list of geocode' do
          @result.each do |a|
            a.each do |g|
              g.should have_key('lat')
              g.should have_key('lng')
            end
          end
        end
      end


      describe '2 fuzzy location' do
        before do
          @result = FuzzySearch.new([@supermarket, @restaurant], @nonfuzzy).assign_geocode
        end
        it 'return 3 closest place' do
          @result.should have_at_most(9).items
        end
        it 'return a list of geocode' do
          @result.each do |a|
            a.each do |g|
              g.should have_key('lat')
              g.should have_key('lng')
            end
          end
        end
      end


    end
  end


  describe Group do
    before do
      @a    = { 'searchtext' => 'a' }
      @b    = { 'searchtext' => 'b' }
      @c    = { 'searchtext' => 'c' }
      @d    = { 'searchtext' => 'd' }
      @e    = { 'searchtext' => 'e' }
      @f    = { 'searchtext' => 'f' }
      @g    = { 'searchtext' => 'g' }
      @locs = [@a, @b, @c, @d, @e, @f, @g]


    end
    describe 'basics' do
      before do
        gps    = [['d', 'e']]
        @group = Group.new(gps, @locs)
      end

      it 'has groups' do
        @group.groups.should_not be_nil
      end
      it 'has ungrouped' do
        @group.ungrouped.should_not be_nil
      end
      it 'groups contains locations' do
        @group.groups[0][0].should have_key('searchtext')
      end

      it 'one group' do
        @group.get_groups.should have(2).items
      end

      it 'return list of lists of right length' do
        @group.get_groups[0].should have(6).items
      end
      it 'return list of lists of right length' do
        @group.get_groups[1].should have(6).items
      end


    end
  end

  describe "Solve" do
    before do
      inp                  = {}
      inp['groups']        = nil
      one                  = {}
      one['arriveafter']   =''
      one['arrivebefore']  =''
      one['departafter']   ='3:30pm'
      one['departbefore']  =''
      one['geocode']       ={ 'lat' => 37.8644696, 'lng' => -122.25670630000002 }
      one['maxduration']   =''
      one['minduration']   =''
      one['priority']      = 1
      one['searchtext']    = "2050"
      two                  = {}
      two['arriveafter']   =''
      two['arrivebefore']  =''
      two['departafter']   =''
      two['departbefore']  =''
      two['geocode']       ={ 'lat' => 37.7749295, 'lng' => -122.41941550000001 }
      two['maxduration']   =''
      two['minduration']   =''
      two['priority']      = 2
      two['searchtext']    = "San Francisco"
      three                = {}
      three['arriveafter'] =''
      three['arrivebefore']=''
      three['departafter'] ='5:30pm'
      three['departbefore']=''
      three['geocode']     ={ 'lat' => 37.8757435, 'lng' => -122.25873230000002 }
      three['maxduration'] =''
      three['minduration'] =''
      three['priority']    = 1
      three['searchtext']  = "Soda Hall"

      inp['locationList'] = [one, two, three]
      inp['travelMethod'] = 'walking'


      @result = solve(inp)
      @routes = @result[:routes]
    end

    describe @result do
      it 'should success' do
        @result[:errCode].should eql(1)
      end
      it 'should return routes' do
        @result[:routes].should have_at_least(1).items
      end
      describe @routes do
        it 'should have more than one steps' do
          @routes[0][:steps].should have_at_least(2).items
        end
        it 'should have mode' do
          @routes[0][:mode].should eql('walking')
        end
        it 'should have traveltime' do
          @routes[0][:traveltime].should be_an(Float)
        end
      end
    end

  end
end


