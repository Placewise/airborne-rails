# frozen_string_literal: true

class TestApp < Rails::Application
  config.consider_all_requests_local = true
  config.hosts << "www.example.com"
end

class TestResponsesController < ActionController::API
  def show
    if params[:file] == "exception"
      render json: { some: "Error" }, status: :internal_server_error
    else
      render json: File.read("spec/support/test_responses/#{params[:file]}.json")
    end
  end

  def show_exception; end
end

TestApp.routes.draw do
  get "/(:file)", to: "test_responses#show"
end

Rails.logger = Logger.new("tmp/rails.log")
Rails.application = TestApp
