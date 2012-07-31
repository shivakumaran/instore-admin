class ApplicationController < ActionController::Base
  protect_from_forgery
  
  MAX_SESSION_TIME = 14400
  
  before_filter :check_for_enabled_user
  before_filter :check_session_timeout
  before_filter :set_user
  before_filter :login_required
  before_filter :password_change_required
  
  after_filter :restart_session_timeout

  def current_user
    get_user
  end
  
  def check_for_enabled_user
    if @curr_user || session[:id]
      user = User.find(session[:id] || @curr_user.id)
      disabled = user.disabled
      if disabled || user.archive || (user.organisation && (user.organisation.disabled || user.organisation.archive))
        reset_session
        session[:return_to] = request.fullpath
        flash[:error] = 'Your account was disabled. Please contact your system administrator.'
        redirect_to :controller => '/login', :action => 'login'        
      end      
    end
  end
  
  def check_for_privilleges
    if !@curr_user.is_admin && !@curr_user.is_super_admin
      redirect_to :controller=>"welcome", :action=>"insufficient_privilege"    
    end       
  end

  def check_for_admin
    redirect_to :controller=>"welcome", :action=>"insufficient_privilege" unless @curr_user.is_admin
  end
  
  def check_for_super_admin
    redirect_to :controller=>"welcome", :action=>"insufficient_privilege" unless @curr_user.is_super_admin
  end
  
protected
  def set_user
    if @curr_user.nil? && session[:id]
      @curr_user = User.find(session[:id])
      User.current = @curr_user
    end
  end

  def get_user
    return User.find(session[:id]) if session[:id]
  end

  def login_required
    return true if session[:id]
    if session[:after_timeout] 
      session_timed_out
      return false
    end
    not_logged_in
    return false
  end

  def not_logged_in
    flash[:error] = 'Please log in.'
    request_login
  end

  def session_timed_out
    flash[:error] = 'The session has timed out due to lack of activity.  Please log in again.'
    request_login
  end

  def request_login
    session[:return_to] = request.fullpath
    flash[:message] = nil
    redirect_to :controller => '/login', :action => 'login'
  end

  def password_change_required
    if @curr_user.pw_reset_req
      flash[:message] = "Please change your password."
      redirect_to :controller=>'/profile', :action=>'reset_password'
      return false
    end
  end

  def check_session_timeout
    if !session[:expiry_time].nil? and session[:expiry_time] < Time.now
      # Session has expired. Clear the current session.
      reset_session
      session[:after_timeout] = true
    end
  end

  def restart_session_timeout
    # Assign a new expiry time, whether the session has expired or not.
    session[:expiry_time] = MAX_SESSION_TIME.seconds.from_now
    return true
  end
  
end
