Rails.application.routes.draw do
  resources :inventories
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  match ':controller(/:action(/:id(/:id2(/:id3(/:id4)))))', via: [:get, :post]
  match ':context/all/:controller(/:action(/:id(/:id2(/:id3(/:id4)))))', via: [:get, :post], context_id: nil
  match ':context/:context_id/:controller(/:action(/:id(/:id2(/:id3(/:id4)))))', via: [:get, :post]
  
  
  match 'pop/:controller(/:action(/:id(/:id2(/:id3(/:id4)))))', via: [:get, :post], popup: true
  
  root 'home#index', via: [:get, :post]

end
