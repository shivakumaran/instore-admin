require "bulk_action.rb"
require 'digest/sha1'

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :first_name, :type => String
  field :last_name, :type => String
  field :username, :type => String
  field :password, :type => String
  field :organisation_id, :type => Integer
  field :pw_reset_req, :type => Boolean, :default => true
  field :is_super_admin, :type => Boolean
  field :is_admin, :type => Boolean
  field :archive, :type => Boolean, :default => false
  field :phone_number, :type => String
  field :disabled, :type => Boolean, :default => false
  field :created_at, :type => Time
  field :updated_at, :type => Time

  SEARCHABLE_COLUMNS = [:first_name, :first_name, :username, :phone_number]

  belongs_to :organisation
  has_and_belongs_to_many :venues
  has_many :user_sessions

  attr_accessor :clear_password
  attr_accessor :pw_change
  attr_protected :password

  validates_presence_of :username
  validates_uniqueness_of :username

  validates_length_of :clear_password, :within => 8..40,
    :if => lambda { |user| user.new_record? or not user.clear_password.blank? },
    :message => "must be at least 8 characters"

  validates_format_of :clear_password,
    :with => /^(?=.*\d)(?=.*([a-z]|[A-Z]))([\x20-\x7E]){8,40}$/,
    :message => "must be at least 8 characters and contain at least one letter and at least one number or special character.",
    :if => lambda { |user| user.new_record? or not user.clear_password.blank? }

  validates_presence_of :clear_password_confirmation, :if => :password_changed?

  validates_confirmation_of :clear_password, :if => lambda { |user| user.new_record? or not user.clear_password.blank?}

  def display_name
    first_name + " " + last_name
  end

  def status
    disabled ? 'Inactive' : 'Active'
  end

  def self.current
    Thread.current[:user] || User.first
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  def self.authenticate(user_info)
    if user_info && user_info.has_key?(:username)
      user = find_by_username(user_info[:username])
      if user && user.password == hashed(user_info[:clear_password])
      return user
      end
    end
  end

  def self.find_by_username(username)
    User.first(:conditions=>{:username=>username})
  end

  def self.hashed(str)
    #Digest::SHA1.new(str).to_s
    Digest::SHA1.hexdigest(str).to_s
  end

  class << self
    #This method will take query as a parameter and returns users as an array after successfull
    #search by first_name OR last_name
    def search(search_term)
      conditions = []
      SEARCHABLE_COLUMNS.each do|column|
        conditions << {column=>/#{search_term}/i}
      end
      any_of(conditions)
    end

    #This action is used for bulk action for users
    def user_bulk_action(bulk_action, checked_user_ids)
      bulk_action = BulkAction.new(self, bulk_action, checked_user_ids)
      bulk_action.bulk_action_method
    end

    def list(search_params,curr_user,page)
      if search_params
        users = User.search(search_params)
        if curr_user.is_super_admin
          users = users.all_of({"$or" => [{"is_admin" => true}, {"is_super_admin" => true}]})
        else
          users = users.all_of({"$or" => [{:organisation_id=>curr_user.organisation.id}]})
        end
      else
        users = curr_user.is_super_admin ? User.all_of({"$or" => [{"is_admin" => true}, {"is_super_admin" => true}]}) : curr_user.organisation.users
      end
      users = users.where(:archive => false).not_in(:username => ["#{curr_user.username}"]).paginate(:page => page, :per_page => 15)
    end

  end

  private
  before_save :update_password

  def update_password
    if not clear_password.blank?
      self.password = self.class.hashed(clear_password)
      self.clear_password = nil
    end
  end

  def password_changed?
    return pw_change
  end
end
