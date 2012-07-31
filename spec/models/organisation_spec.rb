require 'spec_helper'

module OrganisationSpecHelper
  
  def valid_organisation_attributes
    {
      :name => "Sasken Corporate Office",
      :address1 => "Bangalore",
      :address2 => "Domlur",
      :city => "Bangalore Central",
      :state => "Karnataka",
      :country => "India",
      :zip => "234556",
      :domain => "www.sasken.com"
    }
  end
end

describe Organisation do

  include OrganisationSpecHelper
  
  before(:each) do
    @organisation = Organisation.new    
  end
  
  it "Organization was successfully created" do
    @organisation.attributes = valid_organisation_attributes
    #@organisation.should be_valid
  end
  
  it "Name can't be blank" do
    @organisation.should have(1).error_on(:name)
  end
  
  it "Name is already taken" do    
    @organisation1 = Organisation.new(:name => "Sasken Corporate Office")
    @organisation1.should_not be_valid
  end
  
  it "Address1 can't be blank" do
    @organisation.should have(1).error_on(:address1)
  end
  
  it "Address2 can't be blank" do
    @organisation.should have(1).error_on(:address2)
  end
  
  it "City can't be blank" do
    @organisation.should have(1).error_on(:city)
  end
  
  it "State can't be blank" do
    @organisation.should have(1).error_on(:state)
  end    
  
  it "Zip Code can't be blank" do
    @organisation.should have(1).error_on(:zip)
  end
  
  it "Domain can't be blank" do
    @organisation.should have(1).error_on(:domain)
  end
  
  it "should dispaly status of organisation" do
    @organisation.disabled = false
    @organisation.status.should == "Active"
    @organisation.disabled = true
    @organisation.status.should == "Inactive"
  end
  
  it "should display address" do
    @organisation.attributes = valid_organisation_attributes    
    @organisation.display_address.should == ["Bangalore", "Domlur", "Bangalore Central", "Karnataka", "India", "234556"]
  end
  
  it "should test valid organisation" do
    
  end
  
  it "should test invalid organisation" do
    
  end
    
end
