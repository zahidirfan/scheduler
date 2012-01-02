Resume::Application.routes.draw do

  resources :comments

  resources :interviews

  resources :priorities

  resources :statuses

  resources :projects

  resources :users do
    collection do
      get :followings
    end
  end

  resources :candidates do
    collection do
      get :tag
    end
    get 'toggle_follow'
    resources :interviews do
      resources :comments
    end
    get 'mark_archive'
  end

  resources :hr, :bm, :administrator, :pl, :interviewer, :controller => "users"
  resources :sessions

  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up" => "users#new", :as => "sign_up"

  match "password_change" => "users#password_change", :as => "password_change"
  match 'get_interviews' => "interviews#get_interviews" , :as => :get_interviews
  match 'get_interviews/:interviewer_id' => "interviews#get_interviews" , :as => :get_interviews
  match 'interview/:view' => 'interviews#index'
  match 'interviews/move' => "interviews#move"
  match 'interviews/resize' => "interviews#resize"
  match "interviews/make_ical/:int_id" => "interviews#make_ical", :as => :make_ical
  match 'create_custom_tags' => 'candidates#create_custom_tags'
  match 'pull_tags' => 'candidates#pull_tags'
  match 'fetch_candidates' => 'candidates#fetch_candidates', :as => 'fetch_candidates'
  match 'mark_archive_for_selected_candidates' => 'candidates#mark_archive_for_selected_candidates', :as => 'mark_archive_for_selected_candidates'
  match "my_trackings" => "candidates#my_trackings", :as => 'my_trackings'
  match "candidates/tag/:name" => "candidates#tag", :as => :tag_candidates, :constraints => { :name => /.+(?=\.(html|xml|js))|.+/ }
  match "add_candidate" => "candidates#new", :as => :add_candidate, :via => :get
  match "forgotten" => "sessions#forgotten", :as => :forgotten
  match "career" => "career#new", :as => :career, :via => :get
  match "career" => "career#create", :as => :career, :via => :post
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
  root :to => 'home#index'

# See how all your routes lay out with "rake routes"

# This is a legacy wild controller route that's not recommended for RESTful applications.
# Note: This route will make all actions in every controller accessible via GET requests.
# match ':controller(/:action(/:id(.:format)))'
end
