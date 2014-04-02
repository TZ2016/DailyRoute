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


require 'spec_helper'

describe "UnitTests" do
	before do
		@user = User.new(email: "test@test.com", password: "password", password_confirmation: "password")
	end

	subject{@user}

	it {should respond_to(:email)}
	it {should respond_to(:password)}
	it {should respond_to(:password_digest)}


	describe "password can't be too short" do
		before {@user.password = "a"}
		it {should_not be_valid}
	end

	describe "email must have correct form" do 
		before {@user.email = "a"*129}
		it {should_not be_valid}
	end

	describe "email can't be blank" do 
		before {@user.email = ""}
		it {should_not be_valid}
	end

	describe "email form is valid" do 
		before {@user.email = "test@test.com"}
		it {should be_valid}
	end

	describe "email must be unique" do 
		before {
			User.create(email: "test@test.com", password: "pass11", password_confirmation: "pass11")
		}
		it {should_not be_valid}
	end

	after(:each) do
  		User.delete_all
	end
end
