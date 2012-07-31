require 'spec_helper'

module UserSpecHelper
  
  def valid_user_attributes
    {
      :username => "saskenfacz",
      :clear_password => "abc123@#",
      :clear_password_confirmation => "abc123@#"      
    }
  end
  
end

describe User do
  
  include UserSpecHelper
  
    before(:each) do
      @user = User.new
    end     
    
    it "should be valid user" do
      @user.attributes = valid_user_attributes
      @user.should be_valid
    end
    
    it "should require username" do
      @user.should have(1).error_on(:username)
    end
    
    it "should be unique username" do      
      @user1 = User.new(:username => "saskenfacz")
      @user1.should_not be_valid
    end
    
    it "should require password" do
      @user.should have(2).error_on(:clear_password)      
    end
    
    it "should validate length of password (8-40 characters)" do  
      @user1 = User.new(:clear_password => "abcdefgh")
      @user1.should have(1).error_on(:clear_password)   
    end
    
    it "should validate format of password (6-40 characters)" do 
      @user2 = User.new(:clear_password => "abcdef1$")     
      @user2.should have(0).error_on(:clear_password)   
    end

    it "should validate confirmation of password" do
      @user5 = User.new(:clear_password => "abcdef1$", :clear_password_confirmation => "abxdef1$")
      @user5.should_not be_valid
    end

    it "should display name" do
      @user.attributes = valid_user_attributes
      @user.first_name = "Anup"
      @user.last_name = "Shrivastaw"      
      @user.display_name.should == "Anup Shrivastaw"
    end
        
    it "should test valid user" do

    end

    it "should test invalid user" do

    end
end
