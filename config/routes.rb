Comatose::Engine.routes.draw do
  match "/", :to => "content#show"
  resources :content, :only => [:show]
  resources :pages do
    collection do
      get :export
      post :import
      # We use the :id in reorder as an argument in the post and not the URL,
      # which is why its in collection instead of member.
      post :reorder
    end
    member do
      get :versions
      post :set_version
    end
  end
  match "/(*page_path)", :to => "content#show"
end
