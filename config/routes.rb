Rails.application.routes.draw do
  resources :products do
    collection { get :search }
  end
  resources :filters do
    member do
      post :option
    end
  end
  root to: "products#search"
end
