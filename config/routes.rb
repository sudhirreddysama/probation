Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  match ':controller(/:action(/:id(/:id2(/:id3(/:id4)))))', via: [:get, :post]
  match ':context/:context_id/:controller(/:action(/:id(/:id2(/:id3(/:id4)))))', via: [:get, :post]
  
  root 'home#index', via: [:get, :post]

end
