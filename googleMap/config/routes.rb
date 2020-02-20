Rails.application.routes.draw do
  root 'googlemaps#index'
  get 'googlemaps/google_map_result'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
