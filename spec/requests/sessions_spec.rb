require 'spec_helper'

describe "Session pages" do

  before do
    @user = User.create(email: "test@test.com", password: "password", password_confirmation: "password")
  end

  subject { page }

  describe "Signin page" do
    before { visit signin_path }

    it { should have_content('Sign in') }
    it { should have_button('Sign in') }
    it { should have_field("Email") }
    it { should have_field("Password") }
    it { should have_link("Sign up now!")}
    it { should have_content('New user?')}

  end

  describe "the signin process" do

    it "report user not exist" do
      visit signin_path
      click_button 'Sign in'
      expect(page).to have_content 'User does not exist'
    end

    # it "report invalid password" do
    #   visit signin_path
    #   fill_in 'session_email', :with => 'test@test.com'
    #   fill_in 'session_password', :with => 'invalid'
    #   click_button 'Sign in'
    #   expect(page).to have_content 'Invalid'
    # end
  end

end