require 'api_constraints'

DeviseApiRailsWorking::Application.routes.draw do
  get 'feedbacks/profile'

  # ------- Admin Routes Start -------
  match '/admin/feedback_index', :controller => 'admin', :action => 'feedback_index', via: [:get, :post]
  match '/admin/user_index', :controller => 'admin', :action => 'user_index', via: [:get, :post]
  match '/admin/agency_index', :controller => 'admin', :action => 'agency_index', via: [:get, :post]
  match '/admin/assign_agency', :controller => 'admin', :action => 'assign_agency', via: [:get, :post]
  match '/admin/delete_feedback', :controller => 'admin', :action => 'delete_feedback', via: [:get, :post]
  match '/admin/delete_user', :controller => 'admin', :action => 'delete_user', via: [:get, :post]
  match '/admin/assign_abuse_status', :controller => 'admin', :action => 'assign_abuse_status', via: [:get, :post]
  match '/admin/add_agency', :controller => 'admin', :action => 'add_agency', via: [:get, :post]
  match '/admin/suspend_user', :controller => 'admin', :action => 'suspend_user', via: [:get, :post]
  match '/admin/unsuspend_user', :controller => 'admin', :action => 'unsuspend_user', via: [:get, :post]
  # ------- Admin Routes End -------

  # ------- Developer Routes Start -------
  match '/admin/image_index', :controller => 'admin', :action => 'image_index', via: [:get, :post]
  match '/admin/notification_index', :controller => 'admin', :action => 'notification_index', via: [:get, :post]
  match '/admin/user_agency_index', :controller => 'admin', :action => 'user_agency_index', via: [:get, :post]
  match '/admin/annotation_index', :controller => 'admin', :action => 'annotation_index', via: [:get, :post]
  # ------- Developer Routes End -------

  # ------- Feedbacks Routes Start -------
  match '/feedbacks/index', :controller => 'feedbacks', :action => 'index', via: [:get, :post]
  match '/feedbacks/search', :controller => 'feedbacks', :action => 'search', via: [:get, :post]
  match '/feedbacks/show', :controller => 'feedbacks', :action => 'show', via: [:get, :post]
  match '/feedbacks/create_vote', :controller => 'feedbacks', :action => 'create_vote', via: [:get, :post]
  match '/feedbacks/create_comment', :controller => 'feedbacks', :action => 'create_comment', via: [:get, :post]
  match '/feedbacks/unvote', :controller => 'feedbacks', :action => 'unvote', via: [:post, :delete]
  match '/feedbacks/my_feedbacks', :controller => 'feedbacks', :action => 'my_feedbacks', via: [:get, :post]
  match '/feedbacks/report_abuse', :controller => 'feedbacks', :action => 'report_abuse', via: [:get, :post]
  match '/feedbacks/marked_as_resolved', :controller => 'feedbacks', :action => 'marked_as_resolved', via: [:get, :post]
  match '/feedbacks/assign_progress_status', :controller => 'feedbacks', :action => 'assign_progress_status', via: [:get, :post]
  match '/feedbacks/other', :controller => 'feedbacks', :action => 'other', via: [:get, :post]
  # ------- Feedbacks Routes End -------

  get 'ranking/index'

  get 'notifications/index'

  get 'verifications/new'

  get 'verifications/verify'
  post 'verifications/verify'

  get 'verifications/create'
  post 'verifications/create'

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks", :registrations => "registrations" }
  
  get '/mu-b7a80520-38574f1d-8d74f9b9-cd358b57', :to => proc { |env| [200, {}, ["42"]] }

  namespace :api, {format: 'json'} do 
    scope module: :v1, constraints: ApiConstraints.new(version: 1) do
      resources :sessions, :only => [:create, :destroy]
      resources :registrations, :only => [:create]

    end
    scope module: :v2, constraints: ApiConstraints.new(version: 2, default: :true) do
      devise_for :users, skip: :all
      devise_scope :user do
        post "/sessions" => "sessions#create"
        post "/registrations" => "registrations#create"
        delete "/sessions" => "sessions#destroy"
      end
      resources :sessions, :only => [:create, :destroy]
      resources :registrations, :only => [:create]

      post "/verifications/create" => "verifications#create"
      post "/verifications/verify" => "verifications#verify"

      post "/feedbacks/create" => "feedbacks#create"
      post "/feedbacks/display_all" => "feedbacks#display_all"
      post "/feedbacks/display_mine" => "feedbacks#display_mine"
      post "/feedbacks/display_details" => "feedbacks#display_details"
      post "/feedbacks/create_comment" => "feedbacks#create_comment"
      post "/feedbacks/create_vote" => "feedbacks#create_vote"
      post "/feedbacks/check_vote" => "feedbacks#check_vote"
      post "/feedbacks/unvote" => "feedbacks#unvote"
      post "/feedbacks/get_comments" => "feedbacks#get_comments"
      post "/feedbacks/report_abuse" => "feedbacks#report_abuse"
      post "/feedbacks/assign_progress_status" => "feedbacks#assign_progress_status"

      post "/users/email_exists" => "users#email_exists"
      post "/users/facebook_login" => "users#facebook_login"
      post "/users/get_user" => "users#get_user"
      post "/users/change_password" => "users#change_password"
      post "/users/get_agency" => "users#get_agency"

      post "/annotations/create" => "annotations#create"

      post "/notifications/get_new_notifications" => "notifications#get_new_notifications"
      post "/notifications/get_more_notifications" => "notifications#get_more_notifications"
    end
  end

  root :to => "feedbacks#index" #, sort_type: "Last Updated"

end
