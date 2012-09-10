Rails.application.routes.draw do
  root :to => "comatose/pages#index"
  mount Comatose::Engine => "/comatose"
end
