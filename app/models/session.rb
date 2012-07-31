class Session
  include Mongoid::Document
  belongs_to :user
  
  before_save :set_user_session
  
  def set_user_session
    user_id=User.current
  end
end
