require 'spec_helper'

describe "Main Page" do 

	it "should have title" do
		visit '/'
		page.source.should have_selector("title", text: "Daily Route")
	end

	it "should have cotent" do
		visit '/'
		page.should have_content("Main")
		page.should have_content("Tutorial")
		page.should have_content("About")
		page.should have_field("email-field")
		page.should have_field("password-field")

	end
		
end

describe "Tutorial Page" do 

	it "should have title" do
		visit '/tutorial'
		page.source.should have_selector("title", text: "Daily Route")
	end

	it "should have cotent" do
		visit '/'
		page.should have_content("Main")
		page.should have_content("Tutorial")
		page.should have_content("About")
	end
		
end

describe "About Page" do 

	it "should have title" do
		visit '/about'
		page.source.should have_selector("title", text: "Daily Route")
	end

	it "should have cotent" do
		visit '/'
		page.should have_content("Main")
		page.should have_content("Tutorial")
		page.should have_content("About")
	end
		
end