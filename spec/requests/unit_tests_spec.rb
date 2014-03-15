require 'spec_helper'

describe Location do

	before do
		@loc = Location.new()
	end

	subject { @loc }

	it { should respond_to(:routeid) }
	it { should respond_to(:searchtext) }
	it { should respond_to(:minduration)  }
	it { should respond_to(:maxduration)  }
	it { should respond_to(:arrivebefore)  }
	it { should respond_to(:arriveafter)  }
	it { should respond_to(:departbefore)  }
	it { should respond_to(:departafter)  }
	it { should respond_to(:priority)  }
	it { should respond_to(:geocode)  }
	it { should respond_to(:blacklisted)  }
	it { should respond_to(:lockedin)  }
	it { should_not be_valid }
	
	describe "when no geocode" do

		it { should_not be_valid }
	end

	describe " when no routeid" do
		before do
			@loc.geocode = {'lat' => 23, 'lng' => 34} 
		end
		it { should_not be_valid }
	end

	describe "with geocode and routied" do
		before do
			@loc.geocode = {'lat' => 23, 'lng' => 34} 
			@loc.routeid = 1
		end

		it { should be_valid }		
	end	

	

	after(:each) do
  		User.delete_all
	end

end
