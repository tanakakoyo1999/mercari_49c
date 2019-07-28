Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root "items#index"
  get '/items/show', to: 'items#show'
  post '/items/create', to: 'items#create'
end
