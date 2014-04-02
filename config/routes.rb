DailyRouteTest::Application.routes.draw do
 
  resources :users
  resources :sessions,      only: [:new, :create, :destroy]

  root 'static_page#main'

  # static page nav
  get 'main'    => 'static_page#main'
  get 'about'  => 'static_page#about'
  get 'tutorial' => 'static_page#tutorial'

  # user management
  match 'signup',  to: 'users#create',            via: 'post'
  match 'signin',  to: 'sessions#create',         via: 'post'
  match 'signout', to: 'sessions#destroy',     via: 'delete'
  
  # core

  # testing
  post '/main/reset' => "main#reset"
  post '/main/parseRoute' => 'main#parseRoute'
  post '/main/master'     => 'main#master'

end