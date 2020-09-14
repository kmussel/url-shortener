Rails.application.routes.draw do

  
  namespace :api, constraints: { format: 'json' } do 
    namespace :v1 do
     post 'short_urls', to: 'short_urls#create'
     get 'short_urls/:id', to: 'short_urls#show'     
    end 
  end 

  get '/:key', constraints: { key: /.+/ }, to: 'home#show'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'
end