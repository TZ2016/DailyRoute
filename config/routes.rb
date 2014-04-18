DailyRouteTest::Application.routes.draw do
 
  # resources :users
  # resources :routes, only: [:create, :destroy]
  # resources :sessions,      only: [:new, :create, :destroy]

  root 'static_page#main'

  # static page nav
  get 'main'    => 'static_page#main'
  get 'about'  => 'static_page#about'
  get 'tutorial' => 'static_page#tutorial'

  # user management
  match 'signup',  to: 'users#create',            via: 'post'
  match 'signin',  to: 'sessions#create',         via: 'post'
  match 'signout', to: 'sessions#destroy',     via: 'delete'
  
  # route
  match 'routes', to: 'users#show', via: 'get'
  match 'newroute',  to: 'routes#create', via: 'post'

  # core
  # match 'saved', to: 'users#saved_routes',  via: 'get'

  # testing
  post '/main/reset' => "static_page#reset"
  get  '/main/test'  => "static_page#tests"
  # post '/main/parseRoute' => 'main#parseRoute'
  # post '/main/master'     => 'main#master'

end