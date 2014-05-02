require 'spec_helper'

describe "User pages" do

  before do
    @user = User.create(email: "test@test.com", password: "password", password_confirmation: "password")
  end

  subject { page }

  describe "Signup page" do
    before { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_button('Sign Up') }
    it { should have_field("Email") }
    it { should have_field("Password") }
    it { should have_field("Confirmation") }

  end

  describe "the signup process" do

    it "report blank email" do
      visit signup_path
      click_button 'Sign Up'
      expect(page).to have_content "Email can't be blank"
    end

    it "report invalid email" do
      visit signup_path
      fill_in 'Email', with: '1'
      click_button 'Sign Up'
      expect(page).to have_content "Email is invalid"
      expect(page).to have_no_content "Email can't be blank"
    end

    it "report blank password" do
      visit signup_path
      fill_in 'Email', with: '1@1.com'
      click_button 'Sign Up'
      expect(page).to have_content "Password is too short"
      expect(page).to have_no_content "Email can't be blank"
    end

    it "report password mismatch" do
      visit signup_path
      fill_in 'user_email', with: '1@1.com'
      fill_in 'user_password', with: '123123'
      click_button 'Sign Up'
      expect(page).to have_content "Password confirmation doesn't match Password"
      expect(page).to have_no_content "Email can't be blank"
      expect(page).to have_no_content "Password is too short"
    end

    it "report email taken" do
      visit signup_path
      fill_in 'user_email', with: 'test@test.com'
      click_button 'Sign Up'
      expect(page).to have_content "Email has already been taken"
    end

    # it "report success" do
    #   visit signup_path
    #   fill_in 'user_email', with: '1@1.com'
    #   fill_in 'user_password', with: '123123'
    #   fill_in 'user_password_confirmation', with: '123123'
    #   click_button 'Sign Up'
    #   expect(page).to have_content "Email has already been taken"
    # end

  end

end