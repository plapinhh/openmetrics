ActionController::Routing::Routes.draw do |map|
  map.resources :alerts

  map.resources :events
  map.resource :api_key

  map.resources :thresholds

  map.resources :collectd_plugins
  map.resources :collectd_services
  map.resources :system_group_maps

  map.resources :system_groups

  map.resources :permissions

  map.resources :roles

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.resources :users

  map.resource :session

  map.resources :system_variables

  map.resources :inventory_items

  map.resources :running_service_histories

  map.resources :service_histories

  map.resources :system_histories

  map.deploykey 'systems/deploykey', :controller => 'ssh_pubkey_adept', :action => 'deploykey'

  map.resources :running_services

  map.resources :services

  map.resources :systems

  map.resources :welcome_page
  map.welcomepage 'welcomepage', :controller => 'welcome_page', :action => 'display'
  
  map.resources :widgets
  map.resources :munin_image_widgets
  map.resources :collectd_image_widgets
  map.resources :live_ticker_bar_widgets
  map.resources :text_widgets
  map.resources :logtail_widgets
  map.logtail 'logtail/:system_id', :controller => 'logtail_widgets', :action => 'tailoutput'
  map.resources :alert_widgets
  map.recentalerts 'recentalerts', :controller => 'alerts', :action => 'recent'
  map.resources :hallo_world_widgets

  map.resources :dashboards

  map.resources :search, :singular => :search_instance

  map.system_history 'systems/history/:id', :controller => 'systems', :action => 'history'
  map.systemscan 'systemscan', :controller => 'systems', :action => 'scan'
  map.scanresult 'scanresult', :controller => 'systems', :action => 'scanresult'
 
  map.system_search 'systems/search', :controller => 'systems', :action => 'search'
  map.service_search 'services/search', :controller => 'services', :action => 'search'
  
  map.cc 'crontab_cmds', :controller => 'crontab_cmds', :action => 'index'
  
  #map.connect 'systems/history/:id', :controller => 'systems', :action => 'history'
  
  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'welcome_page', :action => 'display'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
