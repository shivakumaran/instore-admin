require "bulk_action.rb"
class Organisation
  include Mongoid::Document
  include Mongoid::Timestamps  
  #define all fields in the organisation model
  field :name, :type => String
  field :address1, :type => String
  field :address2, :type => String
  field :city, :type => String
  field :state, :type => String
  field :zip, :type => String
  field :country, :type => String
  field :business_phone_number, :type => String
  field :domain, :type => String
  field :disabled, :type => Boolean, :default => false
  field :archive, :type => Boolean, :default => false
  field :is_enabled_foursquare, :type => Boolean, :default => true
  field :is_enabled_reward_plus, :type => Boolean, :default => false
  field :created_at, :type => Time
  field :updated_at, :type => Time
  field :client_id, :type => String
  field :client_secret, :type => String
  
  #define validation tules
  validates :name, :uniqueness => true
  validates :name, :presence => true  
  validates :address1, :presence => true
  validates :address2, :presence => true
  validates :city, :presence => true
  validates :state, :presence => true
  validates :country, :presence => true
  validates :zip, :presence => true
  validates :domain, :presence => true
  
  #define association rules
  has_many :users, :dependent=>:destroy
  has_many :venues, :dependent=>:destroy  
    
  SEARCHABLE_COLUMNS = [:name, :address1, :address2, :city, :state, :zip, :country, :business_phone_number]
  
  def display_address
    [address1,address2,city,state,country,zip]
  end
  
  def status
    disabled ? "Inactive" : "Active"
  end
  
  def no_of_admin
    users.where({:is_admin=>true}).count  
  end
  
  def no_of_users
    users.where({:is_admin=>false}).count  
  end
    
  def self.search(search_term)
    conditions = []
    SEARCHABLE_COLUMNS.each do|column|
      conditions << {column=>/#{search_term}/i}
    end
    any_of(conditions)
  end
  
  #This is singleton class
  class << self    
    #This action is used for bulk action for orgabnisations
    def organisation_bulk_action(bulk_action, checked_organisation_ids)      
      bulk_action = BulkAction.new(self, bulk_action, checked_organisation_ids)
      bulk_action.bulk_action_method
    end    
    
    #CSV import
    def csv_import(infile, organisationid)
      csv_uploader(infile, organisationid)
    end
    
    #Method defining for uploading of CSV file
    #This includes parsing of data from CSV and inserting the records in Customers table 
    #as well as products table
    def csv_uploader(infile, organisationid)
      require 'csv'
      require 'timeout'
#      counter = 1
      begin                                     
        CSV.parse(infile).drop(1).each do |row| 
#          puts "************************************"
#          puts "Started reading #{counter} row and inserting row in the table"
          Customer.customer_build_from_csv(row, organisationid)         
#          puts "Ended the process of inserting #{counter} row in the table"
#          puts "************************************"
#          counter += 1        
        end                        
      rescue
        retry
#        puts "*****************************************"
#        puts "Anup got timeout error"
#        puts "*****************************************"    
      end
    end
    handle_asynchronously :csv_import
  end
  
  private
  before_save :create_admin_user
  
  def create_admin_user
    if new_record?
      User.create(:first_name=>"Admin",
        :last_name=>"#{domain}",
        :username=>"admin@#{domain}",
        :clear_password=>"#{domain}@123",
        :clear_password_confirmation=>"#{domain}@123",
        :is_admin=>true,
        :organisation_id=>id)      
    end
  end
end
