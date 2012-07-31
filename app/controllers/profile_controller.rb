class ProfileController < ApplicationController
  skip_before_filter :password_change_required, :only=>[:reset_password, :update_password]
  layout "login"
  def index
  end

  def reset_password
    @user = @curr_user
  end

  def update_password
    @curr_user.pw_change = true
    if @curr_user.update_attributes(params[:user])
      flash[:notice] = 'Password updated successfully.'
      @curr_user.update_attributes :pw_reset_req=>false
      @curr_user.pw_change = false
      if @curr_user.is_super_admin
        redirect_to organisations_path
      else
        redirect_to :controller=>"welcome", :action=>"index"       
      end      
    else
      render :action => 'reset_password'
    end    
  end
end
