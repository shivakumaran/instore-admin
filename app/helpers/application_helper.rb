module ApplicationHelper
  def side_menus
    menus = {}
    if @curr_user.is_super_admin
      menus["Organizations"] = []
      menus["Organizations"] << {:name=>"List Organisations", :url=>"/organisations", :controller=>"/organisations", :action=>"index", :class=>"icon-list"}
      menus["Organizations"] << {:name=>"Add Organisation", :url=>"/organisations/new", :controller=>"/organisations", :action=>"new", :class=>"icon-plus-sign"}
    end
    if !@curr_user.is_super_admin
    menus["Details about your App"]  = []
    menus["Details about your App"]  << {:name=>"App Detail", :url=>"/organisations/app_detail", :controller=>"/organisations", :action=>"foursquare_access", :class=>"icon-plus-sign"}
    menus["Details about your App"]  << {:name=>"Configuration", :url=>"/organisations/csv", :controller=>"/organisations", :action=>"csv", :class=>"icon-plus-sign"}
    end
    menus["Users"] = []
    menus["Users"] << {:name=>"List Users", :url=>"/users", :controller=>"/users", :action=>"index", :class=>"icon-list"}
    menus["Users"] << {:name=>"Add User", :url=>"/users/new", :controller=>"/users", :action=>"new", :class=>"icon-plus-sign"} if @curr_user.is_admin
      
    menus["Venues"] = []
    menus["Venues"] << {:name=>"List Venues", :url=>"/venues", :controller=>"/venues", :action=>"index", :class=>"icon-list"}
    menus["Venues"] << {:name=>"Add Venues", :url=>"/venues/search", :controller=>"/venues", :action=>"search", :class=>"icon-plus-sign"} if @curr_user.is_admin
    menus["Venues"] << {:name=>"Dashboard", :url=>"/welcome/index", :controller=>"/welcome", :action=>"", :class=>""} unless @curr_user.is_super_admin
    menus.sort
  end
  
  def active_controller?(menu_item, parameters={})
    menu_controller_action = menu_item[:action]
    menu_controller_name = (menu_item[:controller].gsub(/^\//,'')+"_controller").camelize
    
    # Validate if the controller's params include the params specified by the menu
    hash = menu_item.dup.delete_if{|k,v| [:name,:controller,:action,:url,:class].include?(k)}
    (menu_controller_name==controller.class.to_s && menu_controller_action==controller.action_name && params_include_menu_params?(hash) )  
  end
  
  def params_include_menu_params?(hash)
    included=true
    
    hash.each do |k,v|
      included &&= (params.has_key?(k) && params[k]==v.to_s)
    end
    
    included
  end  
  
  def profile_path
    link_to "<i class='icon-user'></i>&nbsp;Profile".html_safe, user_path(@curr_user)
  end
  
  def display_name
    @curr_user.display_name
  end
end
