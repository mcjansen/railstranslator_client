# frozen_string_literal: true

RailstranslatorClient::Engine.routes.draw do
  post "sync", to: "sync#create"
  get "status", to: "sync#status"
end
