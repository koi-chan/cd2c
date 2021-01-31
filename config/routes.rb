# frozen_string_literal: true

Rails.application.routes.draw do
  root 'welcome#index'

  devise_for :users

  resources 'original_tables'
  resources 'mypage', only: %i(index)
  resources 'chat_system_authentication_tokens', only: %i(new create destroy)
  resources 'chat_system_authentication_mails', only: %i(destroy)
  get '/chat_system_links/:token', to: 'chat_system_links#create', as: 'chat_system_links'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
