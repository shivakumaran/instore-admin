class LoginController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :password_change_required
  skip_before_filter :check_authorization  
  layout "login"
  def login
    @user = User.new
    @user.username = params[:username]    
  end

  def logout
    reset_session
    flash[:message] = 'Logged out'
    redirect_to :action => 'login'    
  end

  def do_login
    user = User.authenticate(params[:user])
    if (user && !user.disabled) && (user.is_admin || user.is_super_admin)
      session[:user_id] = user.id # Remember the user's id during this session
      session[:id] = user.id # Remember the user's id during this session
	  respond_to do |format|
	    format.html {redirect_to session[:return_to] || { :controller => 'welcome' }}
	    format.json { render :json => user }
	  end      
    else
      flash[:error] = 'Invalid login'
      flash[:error] = 'Your account was disabled. Please contact your system administrator.' if user and user.disabled
	  respond_to do |format|
	    format.html {
      if params[:user]
        redirect_to :action => 'login', :username => params[:user][:username]
      else
        redirect_to :action => 'login'
      end		
		}
	    format.json { render :json => {"error"=>"Invalid Login"} }
	  end 	  
    end
  end
  
  def client_login
    user = User.authenticate(params[:user])
    if user && !user.disabled && !user.is_super_admin
      user_session = UserSession.new({:user_id=>user.id})
      user_session.save      
      respond_to do |format|        
        foursquare_enable_flag = user.organisation.is_enabled_foursquare
        reward_plus_enable_flag = user.organisation.is_enabled_reward_plus        
        if(!user.venues.where(:archive=>false).blank?)
        venue= user.venues.where(:archive=>false).first        
        format.json { render :json => {"response_type" => "success", "auth_token" => user_session.auth_token, "users"=>user, "foursquare_enable_flag" => foursquare_enable_flag, "reward_plus_enable_flag" => reward_plus_enable_flag, "foursquare_user_access_token" => venue.user_access_token,"foursquare_venue_id"=>venue.access_code} }
        else
        format.json { render :json => {"response_type" => "success", "auth_token" => user_session.auth_token, "users"=>user, "foursquare_enable_flag" => foursquare_enable_flag, "reward_plus_enable_flag" => reward_plus_enable_flag} }  
        end  
      end                               
    else
      respond_to do |format|
        format.json { render :json => {"response_type" => "failure", "error"=>"Invalid Login"} }
      end
    end
  end
  
  def client_pwd_reset
    @user = UserSession.where(:auth_token=>params[:auth_token]).first.user rescue nil
    puts "=============================="
    puts params
    puts "-------------------------------"
    if @user
      @user.pw_change = true
      if @user.update_attributes(params[:user])
        @user.update_attributes :pw_reset_req=>false
        @user.pw_change = false
        respond_to do |format|
          format.json { render :json => {"response_type" => "success"} }
        end        
      else
        respond_to do |format|
          format.json { render :json => {"response_type" => "failure", "error"=>@user.errors.full_messages.join("<br/>")} }
        end            
      end
    else
      respond_to do |format|
        format.json { render :json => {"response_type" => "failure", "error"=>"Invalid Login"} }
      end      
    end
  end
  
  #API for getting information regarding Customer details and Product Details
  def customer_information
    first_name = params[:firstname].downcase unless params[:firstname].blank?
    last_name = params[:lastname].downcase unless params[:lastname].blank?
    facebook_id = params[:facebookid] unless params[:facebookid].blank?
    twitterid = params[:twitterid] unless params[:twitterid].blank?   
    auth_token = params[:authtoken] unless params[:authtoken].blank?   
    unless auth_token.blank?
      user = UserSession.where(:auth_token => "#{auth_token}").first.user rescue nil    
      unless user.blank?
        customer = Customer.find_customer_details(user, first_name, last_name, facebook_id, twitterid)
        unless customer.nil?
          products = customer.products
          respond_to do |format|
            format.json { render :json => {:customer => customer, :products => products}}          
          end
        else        
          respond_to do |format|
            format.json { render :json => {"response_type" => "failure", "error" => "Customer Not Found"} }
          end 
        end      
      else
        respond_to do |format|
          format.json { render :json => {"response_type" => "failure", "error" => "Invalid Authentication Token"} }
        end 
      end
    else
      respond_to do |format|
         format.json { render :json => {"response_type" => "failure", "error" => "Authentication Token is required"} }
      end 
    end        
  end
  
end
