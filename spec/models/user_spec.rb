require 'spec_helper'

describe User do

	before do
		@user = User.new(email: "test@dailyroute.com", password: "password", password_confirmation: "password")
	end

	subject{@user}

	it {should be_valid}

	it { should respond_to(:email)}
	it { should respond_to(:password)}
	it { should respond_to(:password_digest)}
	it { should respond_to(:password) }
	it { should respond_to(:password_confirmation) }
	it { should respond_to(:remember_token) }
	it { should respond_to(:authenticate) }
	it { should respond_to(:routes) }

	################EMAIL################

	describe "when email is empty" do 
		before {@user.email = ""}
		it {should_not be_valid}
	end

	describe "when email is not unique" do 
		before do
			user_dup = @user.dup
			user_dup.email = @user.email.upcase
			user_dup.save
		end

		it { should_not be_valid }
	end

	describe "when email is of correct format" do 
		it "should be valid" do
			addresses = %w[user@dailyroute.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
			addresses.each do |valid_address|
				@user.email = valid_address
				expect(@user).to be_valid
			end
		end
	end

	describe "when email is of incorrect format" do 
		it "should be invalid" do
			addresses = %w[user@foo,com user_at_foo.org example.user@foo.
				foo@bar_baz.com foo@bar+baz.com foo@bar..com]
			addresses.each do |invalid_address|
				@user.email = invalid_address
				expect(@user).not_to be_valid
			end
		end
	end

	####################PASSWORD##################

	describe "when password is empty" do
		before do
			@user = User.new(email: "test@dailyroute.com", 
				password: "", password_confirmation: "")
		end
		it { should_not be_valid }
	end

	describe "when password is blank" do
		before do
			@user = User.new(email: "test@dailyroute.com", 
				password: " ", password_confirmation: " ")
		end
		it { should_not be_valid }
	end

	describe "when password doesn't match confirmation" do
		before { @user.password_confirmation = "mismatch" }
		it { should_not be_valid }
	end

	describe "with a password that's too short" do
		before { @user.password = @user.password_confirmation = "a" * 5 }
		it { should be_invalid }
	end

	##################AUTHENTICATE#####################

	describe "return value of authenticate method" do
		before { @user.save }
		let(:found_user) { User.find_by(email: @user.email) }

		describe "with valid password" do
			it { should eq found_user.authenticate(@user.password) }
		end

		describe "with invalid password" do
			let(:user_for_invalid_password) { found_user.authenticate("invalid") }

			it { should_not eq user_for_invalid_password }
			specify { expect(user_for_invalid_password).to be_false }
		end
	end

	describe "remember token" do
		before { @user.save }
		its(:remember_token) { should_not be_blank }
	end

	describe "route associations" do

		before { @user.save }
		let!(:older_route) do
			Route.create(user_id: @user.id, name: "old", mode: "driving", created_at: 1.day.ago)
		end
		let!(:newer_route) do
			Route.create(user_id: @user.id, name: "new", mode: "driving", created_at: 1.hour.ago)
		end

		it "should have the right routes in the right order" do
			expect(@user.routes.to_a).to eq [newer_route, older_route]
		end

		it "should destroy associated routes" do
			routes = @user.routes.to_a
			@user.destroy
			expect(routes).not_to be_empty
			routes.each do |route|
				expect(Route.where(id: route.id)).to be_empty
			end
		end
	
	end

	after(:each) do
		User.destroy_all
	end

end

