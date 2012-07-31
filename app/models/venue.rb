require "bulk_action.rb"
class Venue
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, :type => String
  field :address, :type => String
  field :organisation_id, :type => Integer
  field :access_code, :type => String
  field :disabled, :type => Boolean, :default => false
  field :archive, :type => Boolean, :default => false
  field :created_at, :type => Time
  field :updated_at, :type => Time
  field :user_access_token, :type => String
  
  belongs_to :organisation
  has_and_belongs_to_many :users
  
  SEARCHABLE_COLUMNS = [:name, :address]
  
  def status
    disabled ? "Inactive" : "Active"
  end
  
#Searching venue based on latitude ,langitutude or venue id or nearby and query params. The method will connect to foursquare and retrive the information
  def search_from_four_square_api(search_params,venue_params)
    require "net/http"
    conditions=""
    conditions+="search?query="+search_params[:query]+"&near="+search_params[:near] if search_params[:query]!=nil and search_params[:near]!=nil and venue_params=="near"
    conditions+="search?ll="+search_params[:latitude]+","+search_params[:longitude] if search_params[:latitude]!=nil and search_params[:longitude] and venue_params=="ll"
    conditions+=search_params[:venue_id]+"?" if search_params[:venue_id]!=nil and venue_params=="access_id"
    url=FOURSQUARE_API+conditions+'&client_id='+FOURSQUARE_CLIENT_ID+'&client_secret='+FOURSQUARE_SECRET+'&v='+Time.now.strftime("%Y%m%d")
    uri = URI.parse(URI.escape(url))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request) 
    parsed_json = ActiveSupport::JSON.decode(response.body)
     
    return parsed_json
  end         
  
  class << self    
    #This action is used for bulk action for venues
    def venue_bulk_action(bulk_action, checked_venues_ids)      
      bulk_action = BulkAction.new(self, bulk_action, checked_venues_ids)
      bulk_action.bulk_action_method
    end 
    
    #This action is used for search
    def search(search_term)
      conditions = []
      SEARCHABLE_COLUMNS.each do|column|
        conditions << {column=>/#{search_term}/i}
      end
      any_of(conditions)
    end  
    
    def save_multiple_venues(curr_user,venue_params)
      venue_params[:ids].each_with_index do |item,i|
        venue=Venue.new
        venue.access_code=item[0].split("_")[1]
        venue.name=item[1].split("(")[0]
        venue.address=item[1].split("(")[1].split(")")[0]
        venue.organisation_id=curr_user.organisation.id
        venue.save
      end
    end
    
  end
end
