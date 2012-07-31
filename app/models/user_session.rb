class UserSession
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :user_id, :type => Integer
  field :auth_token, :type => String
  field :created_at, :type => Time
  field :updated_at, :type => Time
  
  belongs_to :user
  
  before_save :enable_api
   
  protected
 
  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end
 
  def enable_api
    self.auth_token = secure_digest(Time.now, (1..10).map{ rand.to_s })
  end  
end
