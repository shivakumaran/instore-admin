require 'integration_test_helper'
class AuthenticationTest < ActionController::IntegrationTest
 @selenium
  test "viewing clubs" do
      visit '/login/login'
      click_button("Login")
      assert page.has_content?('Invalid login')
  end
end