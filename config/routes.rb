# frozen_string_literal: true

Rails.application.routes.draw do
  root 'welcome#index'

  devise_for :users

  resources 'original_tables'
  resources 'chat_system_authentication_tokens', only: %i(index new create destroy)
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
