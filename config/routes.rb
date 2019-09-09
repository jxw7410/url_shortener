Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'static_pages#root'

  get '/:short_url', to: 'short_urls#show'

  namespace :api, defaults: {format: 'json'} do
    resources :short_urls, only: [:create, :index]
  end
end
