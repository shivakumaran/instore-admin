module UsersHelper
  
  def find_status(user)    
    user.disabled == false ? status = "Enabled" : status = "Disabled"         
  end
  
  def contact_number(user)
    user.phone_number.blank? ? contact_number = "Not Updated" : contact_number = user.phone_number
  end
  
end
