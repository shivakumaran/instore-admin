#require 'test_helper'
#
#class OrganisationsControllerTest < ActionController::TestCase
#  setup do
#    @organisation = organisations(:one)
#  end
#
#  test "should get index" do
#    get :index
#    assert_response :success
#    assert_not_nil assigns(:organisations)
#  end
#
#  test "should get new" do
#    get :new
#    assert_response :success
#  end
#
#  test "should create organisation" do
#    assert_difference('Organisation.count') do
#      post :create, :organisation => { :address1 => @organisation.address1, :address2 => @organisation.address2, :business_phone_number => @organisation.business_phone_number, :city => @organisation.city, :country => @organisation.country, :created_at => @organisation.created_at, :disabled => @organisation.disabled, :domain => @organisation.domain, :name => @organisation.name, :state => @organisation.state, :updated_at => @organisation.updated_at, :zip => @organisation.zip }
#    end
#
#    assert_redirected_to organisation_path(assigns(:organisation))
#  end
#
#  test "should show organisation" do
#    get :show, :id => @organisation
#    assert_response :success
#  end
#
#  test "should get edit" do
#    get :edit, :id => @organisation
#    assert_response :success
#  end
#
#  test "should update organisation" do
#    put :update, :id => @organisation, :organisation => { :address1 => @organisation.address1, :address2 => @organisation.address2, :business_phone_number => @organisation.business_phone_number, :city => @organisation.city, :country => @organisation.country, :created_at => @organisation.created_at, :disabled => @organisation.disabled, :domain => @organisation.domain, :name => @organisation.name, :state => @organisation.state, :updated_at => @organisation.updated_at, :zip => @organisation.zip }
#    assert_redirected_to organisation_path(assigns(:organisation))
#  end
#
#  test "should destroy organisation" do
#    assert_difference('Organisation.count', -1) do
#      delete :destroy, :id => @organisation
#    end
#
#    assert_redirected_to organisations_path
#  end
#end
