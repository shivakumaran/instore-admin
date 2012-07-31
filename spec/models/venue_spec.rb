require 'spec_helper'

module VenueSpecHelper
  
  def valid_venue_attributes
    {
      :name => "saskenfacz",
      :address => "Bangalore",
      :access_code => "abc123@#"      
    }
  end
  
end

describe Venue do
  
  include VenueSpecHelper
  
  before(:each) do
    @venue = Venue.new
  end   
  
  it "sbhould be valid venues without attributes" do
    @venue.should be_valid
    @venue.should_not be_nil
  end
  
  it "should be valid venues" do
    @venue.attributes = valid_venue_attributes
    @venue.should be_valid
  end
  
  it "should dispaly status of venues" do
    @venue.disabled = false
    @venue.status.should == "Active"
    @venue.disabled = true
    @venue.status.should == "Inactive"
  end
  
  it "should include the elements of searchable columns" do
    Venue::SEARCHABLE_COLUMNS.should be_eql([:name, :address])
  end
  
  it "should test search functionality of foursquare API" do
    search_params = ""
    venue_params = ""
    venue = mock_model(Venue)
    Venue.stub!(:search_from_four_square_api).with(search_params, venue_params).and_return(venue)
  end
 
end
