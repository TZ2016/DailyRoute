require 'spec_helper'

describe "Static pages" do

  subject { page }

  describe "Main page" do
    before { visit root_path }

    it { should have_content('Start your route now!') }
    it { should have_button('Add') }
    it { should have_field("newloc") }

    it { should have_content('Transportation Mode') }
    it { should have_selector("#trans-mode") }
    it { should have_selector("#mode-d") }
    it { should have_selector("#mode-w") }
    it { should have_selector("#mode-t") }
    it { should have_selector("#mode-b") }

    it { should have_content('Selected Locations') }
    it { should have_selector('#loc-acc-ins') }

    it { should have_button('Calculate Routes') }

    it { should have_selector("#map-canvas") }
  end

  describe "Navigation bar" do
    before { visit root_path }

    it "should have title" do
      page.source.should have_selector("title", text: "Daily Route")
    end

    it { should have_content('Daily Route') }
    it { should have_link('Daily Route') }
    it { should have_content('Main') }
    it { should have_link('Main') }

    it { should have_content('About') }
    it { should have_link('About') }
    it { should have_content('Tutorial') }
    it { should have_link('Tutorial') }

    describe "for not signed-in users" do
      before do
        sign_out
        visit root_path
      end

      it { should have_button("LogIn") }
      it { should have_button("SignUp") }
      it { should_not have_button("LogOut") }
      it { should have_field("Email") }
      it { should have_field("Password") }
    end

    describe "for signed-in users" do
      let!(:user) do
        User.create(email: "test@dailyroute.com", password: "password", password_confirmation: "password")
      end
      before do
        sign_in user
        visit root_path
      end

      # it { should have_button("LogOut")}
      # it { should_not have_button("SignUp") }
      # it { should_not have_button("LogIn") }

    end
  end

  describe "About page" do
    before { visit about_path }

    it { should have_content('About') }
    it { should have_link('About') }
  end

  describe "Tutorial page" do
    before { visit tutorial_path }

    it { should have_content('Tutorial') }
    it { should have_link('Tutorial') }
  end

end