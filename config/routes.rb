Promosite::Application.routes.draw do
  devise_for :admins
  devise_for :users, :controllers => {:registrations => 'user_registrations'}
  devise_for :merchants, :controllers => {
    :registrations => 'merchant_registrations'}

  resources :cities
  resources :classifications
  resources :merchants do
    resources :branches
    resources :promos do
      post :claim, :on => :member
      put :redeem, :on => :member
      match '/print', :to => 'promos#print', :on => :member
    end
  end

  match '/privacy',      :to => 'pages#privacy'
  match '/term_use',     :to => 'pages#term_use'
  match '/term_sale',    :to => 'pages#term_sale'
  match '/how_it_works', :to => 'pages#how_it_works'
  
  match '/my_promos',  :to => 'promos#track',   :as => 'claimed_promos'
  match '/my_tracker', :to => 'promos#records', :as => 'promo_records'

  match 'promos/:classification', :to => 'promos#index',
    :as => 'classified_promos'
  
  match '/merchants/classified-as/:classification',
    :to => 'merchants#index',
    :as => 'classified_merchants' 

  root :to => "promos#index"
end
