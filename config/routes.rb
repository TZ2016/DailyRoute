DailyRouteTest::Application.routes.draw do
 
  resources :users do
    member do
      get 'remove_all_routes'
    end
  end
  resources :routes, only: [:create, :destroy]
  resources :sessions,      only: [:new, :create, :destroy]

  root 'static_page#main'

  # static page nav
  get 'main'    => 'static_page#main'
  get 'about'  => 'static_page#about'
  get 'tutorial' => 'static_page#tutorial'

  # user management
  match 'signup',  to: 'users#create',            via: 'post'
  match 'signup',  to: 'users#new',            via: 'get'
  match 'signin',  to: 'sessions#create',         via: 'post'
  match 'signin',  to: 'sessions#new',         via: 'get'
  match 'signout', to: 'sessions#destroy',     via: 'delete'
  
  # route
  match 'routes', to: 'users#show', via: 'get'
  match 'newroute',  to: 'routes#create', via: 'post'

  # testing

  post '/main/reset' => "static_page#reset"
  post '/tests/routes_of_user'
  post '/tests/remove_all_routes_of'
  post '/tests/add_route_to'
  get  '/tests/resetAll'
  get  '/tests/resetUser'
  get  '/tests/resetRoute'
  get  '/tests/resetStep'

end