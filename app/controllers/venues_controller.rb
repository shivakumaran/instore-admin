require 'uri'
class VenuesController < ApplicationController
  # GET /venues
  # GET /venues.json
  #before_filter :check_for_admin, :except=>[:index]
  def index
    if params[:search]
      @venues = Venue.search(params[:search])
      @venues = @venues.all_of({:organisation_id=>@curr_user.organisation.id}) if @curr_user.is_admin
    else
      @venues = @curr_user.is_admin ? @curr_user.organisation.venues  : Venue.all
    end
    @venues = @venues.where(:archive => false).paginate(:page => params[:page], :per_page => 15)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @venues }
    end
  end

  # GET /venues/1
  # GET /venues/1.json
  def show
    @venue = Venue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @venue }
    end
  end

  # GET /venues/new
  # GET /venues/new.json
  def new
    @venue = Venue.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @venue }
    end
  end

  # GET /venues/1/edit
  def edit
    @venue = Venue.find(params[:id])
  end

  # POST /venues
  # POST /venues.json
  def create
    
    if(!params["venue"].blank?)
    Venue.save_multiple_venues(@curr_user,params["venue"])
    @status=true
    else
      @status=false
    end
    respond_to do |format|
      if @status
        format.html { redirect_to :action=>:index }
        format.json { render :json => @venues, :status => :created, :location => @venues }
     else
       flash[:error] = 'Please select atleast one checkbox to create venue'
       format.html { redirect_to :action => "search"}
      end 
    end
  end

  # PUT /venues/1
  # PUT /venues/1.json
  def update
    @venue = Venue.find(params[:id])

    respond_to do |format|
      if @venue.update_attributes(params[:venue])
        format.html { redirect_to @venue, :notice => 'Venue was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @venue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /venues/1
  # DELETE /venues/1.json
  def destroy
    @venue = Venue.find(params[:id])
    @venue.destroy

    respond_to do |format|
      format.html { redirect_to venues_url }
      format.json { head :no_content }
    end
  end
  
  def search
    @venue=Venue.new
    if request.post?
    begin  
           @parsed_json=@venue.search_from_four_square_api(params[:search],params[:venue])
    rescue 
      flash[:error] = 'Some thing went wrong' 
    end  

    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @parsed_json }
    end
  end
  
  def assign_users_venues
    @venue = Venue.find(params[:id])
  end
  
  def update_users_venues
    @venue = Venue.find(params[:id])
    @venue.users = []
    params[:users].each do|id|
      @venue.users << User.find(id)
    end if params[:users]
    @venue.save
    flash[:notice]="Users assinged successfully"
    redirect_to venues_path
  end 

  #This action is used for bulk actions
  def bulk_action
    @bulk_action = params[:bulk_actions]
    @checked_venues = params[:venue][:venue_ids] unless params[:venue].blank?   
    Venue.venue_bulk_action(@bulk_action, @checked_venues)   #Here bulk action method is calling. It is defined in model
    redirect_to :action => :index    
  end
  
  def foursquare_access
    
    @venue = Venue.find(params[:id])
   
    if (!@venue.organisation.client_id.blank?) and (!@venue.organisation.client_secret.blank?)
      #  if @venue.user_access_token==nil
         redirect_to :action=>"access_token",:venue_id=>@venue
     #   end  
    else
          redirect_to :action=>:app_detail ,:controller=>:organisations
    end    
  end
  
  def access_token
    @venue = Venue.find(params[:venue_id])
    session[:venue_id]=@venue.id
    url='https://foursquare.com/oauth2/authorize?client_id='+@venue.organisation.client_id+'&response_type=code&redirect_uri=http://localhost:3000/venues/foursquare_callback_url'
    redirect_to url
  end
  
  def foursquare_callback_url
    require "net/http"
    @venue = Venue.find(session[:venue_id])
    if (params["error"]=="access_denied")
       redirect_to :action=>:show,:id=>@venue.id
    else  
    
    @venue = Venue.find(session[:venue_id])
    url = 'https://foursquare.com/oauth2/access_token?client_id='+@venue.organisation.client_id+'&client_secret='+@venue.organisation.client_secret+'&grant_type=authorization_code&redirect_uri=http://localhost:3000/venues/foursquare_callback_url1&code='+params[:code]
    uri = URI.parse(URI.escape(url))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request) 
   # res=RestClient.get url
    parsed_json = ActiveSupport::JSON.decode(response.body)
   
    flash[:notice]="Regenerated Successfully"
    @venue.update_attribute(:user_access_token,parsed_json["access_token"])
    session[:venue_id]=nil
    redirect_to :action=>:show,:id=>@venue.id
    end
  end
  
  
end
