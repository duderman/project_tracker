# frozen_string_literal: true

Rails.application.routes.draw do
  resources :projects do
    put :next_transition, on: :member

    resources :comments, only: %i[create]
  end

  root 'projects#index'
end
