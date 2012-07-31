InstoreAdmin::Application.routes.draw do
  get "profile/index"

  get "profile/reset_password"

  post "profile/update_password"

  get "login/login"

  get "login/logout"

  #post "login/do_login"
  
  resources :login do
	collection do
	  post :do_login, :client_login 
	  get :client_pwd_reset, :customer_information
	end
  end
  
  get "welcome/index"
  get "welcome/graph_code"
  get "welcome/insufficient_privilege"
  

  resources :venues do
    get 'search', :on => :collection
    post 'search',:on => :collection
    post 'bulk_action', :on => :collection
    get 'assign_users_venues', :on => :collection
    post 'update_users_venues', :on => :collection
    get 'foursquare_access', :on => :member
    get 'access_token', :on => :collection
    get 'foursquare_callback_url', :on => :collection
  end

  resources :organisations do
    post 'bulk_action', :on => :collection
    get 'app_detail', :on => :collection
    post 'update_app_detail', :on => :collection
    get 'csv', :on => :collection
    post "upload", :on => :collection  
    post 'update_enable', :on => :collection
#    collection do
#      get 'enbale'
#      post 'update_enable'
#    end
  end

  #add collections for searching of users on index page
  resources :users do  
    collection do
      post 'search', 'bulk_action'
      get :get_client_user
    end    
  end

  match '/' => 'login#login'
  root :to => "login#login"
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
