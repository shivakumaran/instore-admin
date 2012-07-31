class UsersController < ApplicationController
  before_filter :check_for_privilleges, :only=>[:new,:edit,:create,:update,:destroy]
  skip_before_filter :login_required, :only=>[:get_client_user]
  skip_before_filter :password_change_required, :only=>[:get_client_user]
  skip_before_filter :check_authorization, :only=>[:get_client_user]    
  # GET /users
  # GET /users.json
  def index
    @users = User.list(params[:search],@curr_user,params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
    @user.organisation_id = @curr_user.organisation_id
    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, :notice => 'User was successfully created.' }
        format.json { render :json => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to users_path, :notice => 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    #@user.destroy    
    @user.update_attribute(:archive, "true")
    
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
  
  #This method is used for searching of person by
  #first_name AND last_name
  def search
    query = params[:name]        
    @paginated_users = User.search(query)     
  end
  
  #This action is used for bulk actions
  def bulk_action
    @bulk_action = params[:bulk_actions]
    @checked_users = params[:user][:user_ids] unless params[:user].blank?
    User.user_bulk_action(@bulk_action, @checked_users)   #Here bulk action method is calling. It is defined in model
    redirect_to :action => :index    
  end
  
  def get_client_user
    user_session = UserSession.where(:auth_token=>params[:auth_token]).first
    @user = user_session.user rescue {}
    respond_to do |format|
	if(!@user.blank?)
	foursquare_enable_flag = @user.organisation.is_enabled_foursquare
        reward_plus_enable_flag = @user.organisation.is_enabled_reward_plus       
      if(!@user.venues.where(:archive=>false).blank?)
      venue= @user.venues.where(:archive=>false).first
      format.json { render :json => (@user.attributes.merge({"auth_token"=>user_session.auth_token, "foursquare_user_access_token" => venue.user_access_token,"foursquare_venue_id"=>venue.access_code, "foursquare_enable_flag" => foursquare_enable_flag, "reward_plus_enable_flag" => reward_plus_enable_flag}) rescue {}) }
      else
      format.json { render :json => (@user.attributes.merge({"auth_token"=>user_session.auth_token, "foursquare_enable_flag" => foursquare_enable_flag, "reward_plus_enable_flag" => reward_plus_enable_flag}) rescue {}) }
      end  
	  else
	format.json { render :json => ({"error"=>"auth token is invalid"}) }
	end
    end
	
  end
  
  
end
