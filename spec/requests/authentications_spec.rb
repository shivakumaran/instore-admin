require 'spec_helper'

describe "Authentications" do
  describe "GET /login/login" do
    it "display login page" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      visit login_login_path
      assert page.should have_content("Sign in to MSI")
    end
  end
  
   describe "POST /login/login" do
    it "login with empty params" , :js => true do
      visit login_login_path
     
      click_button "Login"
      # save_and_open_page
      page.should have_content("Username is required")
      page.should have_content("Password is required")
    end
    
    
    
    it "login with empty password params" , :js => true do
      visit login_login_path
      fill_in "user[username]", :with => "e"
      click_button "Login"
      # save_and_open_page
     
      page.should have_content("Password is required")
    end
    
    it "login with empty username params" , :js => true do
      visit login_login_path
      fill_in "user[clear_password]", :with => "e"
      click_button "Login"
      # save_and_open_page
     
      page.should have_content("Username is required")
    end
    
     it "login with invalid username and password params" , :js => true do
      visit login_login_path
      fill_in "user[username]", :with => "e"
      fill_in "user[clear_password]", :with => "e"
      click_button "Login"
      # save_and_open_page
      page.should have_content("Invalid login")
      
    end
    
    user = User.create!(:username => "test@rspec", :clear_password=> "secret123",:first_name=>"test@rspec",:is_super_admin=>true)
     it "login with valid username and password" , :js => true do
      visit login_login_path
      fill_in "user[username]", :with => "test@rspec"
      fill_in "user[clear_password]", :with => "secret123"
      click_button "Login"
      # save_and_open_page
      page.should have_content("test@rspec")
      
    end
    
  end
  
end
