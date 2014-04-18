require 'spec_helper'

describe User do
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
  		User.destroy_all
	end
end