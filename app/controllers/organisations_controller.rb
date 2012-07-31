class OrganisationsController < ApplicationController
  before_filter :check_for_super_admin , :except => [:app_detail,:update_app_detail, :csv, :upload, :update_enable]
  include ActiveSupport::Rescuable
  # GET /organisations
  # GET /organisations.json
  def index
    @organisations = params[:search] ? Organisation.search(params[:search]) : Organisation.all
    @organisations  = @organisations.where(:archive => false).paginate(:page=>params[:page],:per_page=>15)    
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @organisations }
    end
  end

  # GET /organisations/1
  # GET /organisations/1.json
  def show
    @organisation = Organisation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @organisation }
    end
  end

  # GET /organisations/new
  # GET /organisations/new.json
  def new
    @organisation = Organisation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @organisation }
    end
  end

  # GET /organisations/1/edit
  def edit
    @organisation = Organisation.find(params[:id])
  end

  # POST /organisations
  # POST /organisations.json
  def create
    @organisation = Organisation.new(params[:organisation])

    respond_to do |format|
      if @organisation.save
        format.html { redirect_to organisations_path, :notice => 'Organisation was successfully created.' }
        format.json { render :json => @organisation, :status => :created, :location => @organisation }
      else
        format.html { render :action => "new" }
        format.json { render :json => @organisation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /organisations/1
  # PUT /organisations/1.json
  def update
    @organisation = Organisation.find(params[:id])

    respond_to do |format|
      if @organisation.update_attributes(params[:organisation])
        format.html { redirect_to organisations_path, :notice => 'Organisation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @organisation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /organisations/1
  # DELETE /organisations/1.json
  def destroy
    @organisation = Organisation.find(params[:id])
    #@organisation.destroy
    @organisation.update_attribute(:archive, "true")    
    @organisation.users.first.update_attributes(:disabled => "true", :archive => "true") unless @organisation.users.blank?

    respond_to do |format|
      format.html { redirect_to organisations_url }
      format.json { head :no_content }
    end
  end
  
  #This action is used for bulk actions
  def bulk_action
    @bulk_action = params[:bulk_actions]
    @checked_organisations = params[:organisation][:organisation_ids] unless params[:organisation].blank?    
    Organisation.organisation_bulk_action(@bulk_action, @checked_organisations)   #Here bulk action method is calling. It is defined in model
    redirect_to :action => :index    
  end
  
  def app_detail
   @organisation=@curr_user.organisation
  end
  
  # def access_token
    # url='https://foursquare.com/oauth2/authenticate?client_id='+FOURSQUARE_CLIENT_ID+'&response_type=code&redirect_uri=http://localhost:3000/organisations/foursquare_callback_url'
    # redirect_to url
  # end
  
  def update_app_detail
    
    flash[:notice]="Regenerated Successfully"
    @curr_user.organisation.update_attributes(:client_id => params[:organisation][:client_id], :client_secret=> params[:organisation][:client_secret])
    redirect_to :action=>:app_detail
  end
  
  
  def csv
    @organisation = @curr_user.organisation
  end    
  
  #CSV upload functionality 
  def upload      
    require 'csv'
    require 'timeout'       
    begin     
      puts "*******CSV Reading started******************"
      infile = (params[:organisation][:csv]).read 
      puts "*******CSV Reading ended********************"
      organisation_id = @curr_user.organisation.id    
      puts "*******Start of calling of function csv_import started******************"
      Organisation.csv_import(infile, organisation_id) #calling of import functionality method   
      puts "*******End of calling of function csv_import started********************"
      flash[:notice]="CSV Import Successful, new records will be added to data base. It will take some time"
    rescue
      flash[:notice]="File is not valid. Please upload CSV file"      
    end    
    redirect_to :action => :csv
  end

  #Enable / Disable Functionlaity of FourSquare/Reward Plus app    
  def update_enable
    @organisation = Organisation.find(params[:id])   
    foursquare_enabled_value = params[:organisation][:is_enabled_foursquare].to_i   
    reward_plus_enabled_value = params[:organisation][:is_enabled_reward_plus].to_i   
    foursquare_enabled_value == 1 ? @organisation.update_attribute(:is_enabled_foursquare, true) : @organisation.update_attribute(:is_enabled_foursquare, false)
    reward_plus_enabled_value == 1 ? @organisation.update_attribute(:is_enabled_reward_plus, true) : @organisation.update_attribute(:is_enabled_reward_plus, false)    
    redirect_to :action => :csv
  end
  
end