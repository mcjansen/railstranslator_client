# frozen_string_literal: true

RailstranslatorClient::Engine.routes.draw do
  get "sync", to: "sync#show", as: :sync
  post "sync", to: "sync#create"
  get "status", to: "sync#status"
end
