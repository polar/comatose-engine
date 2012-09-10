Comatose::Engine.routes.draw do
  resources :pages
  resources :photos
  resources :admins do
    collection do
      post :preview
      post :expire_page_cache
      get  :export
      post :import
      post :reorder
    end
    member do
      get :versions
    end
  end
end
