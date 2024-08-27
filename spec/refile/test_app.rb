require "yaml"
require "rails/all"

require "refile"
require "refile/rails"
require "jquery/rails"

module Refile
  class TestApp < Rails::Application
    config.load_defaults 6.1

    config.middleware.delete "ActionDispatch::Cookies"
    config.middleware.delete "ActionDispatch::Session::CookieStore"
    config.middleware.delete "ActionDispatch::Flash"
    config.active_support.deprecation = :log
    config.eager_load = false
    config.action_dispatch.show_exceptions = false
    config.consider_all_requests_local = true
    config.root = ::File.expand_path("test_app", ::File.dirname(__FILE__))
  end

  Rails.backtrace_cleaner.remove_silencers!
  TestApp.initialize!
end

require "rspec"
require "rspec/rails"
require "capybara/rails"
require "capybara/rspec"
require "refile/spec_helper"
require "refile/active_record_helper"
require 'selenium/webdriver'

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('headless')
  options.add_argument('disable-gpu') # Necessário em alguns ambientes
  options.add_argument('no-sandbox') # Pode ser necessário em ambientes Docker
  options.add_argument('disable-dev-shm-usage') # Pode ser necessário em ambientes Docker

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :headless_chrome

Capybara.configure do |config|
  config.server_port = 56120
end

module TestAppHelpers
  def download_link(text)
    url = find_link(text)[:href]
    if Capybara.current_driver == :rack_test
      using_session :other do
        visit(url)
        page.source.chomp
      end
    else
      uri = URI(url)
      uri.scheme ||= "http"
      Net::HTTP.get_response(URI(uri.to_s)).body.chomp
    end
  end
end

RSpec.configure do |config|
  config.include TestAppHelpers, type: :feature
  config.before(:all) do
    Refile.logger = Rails.logger
  end
end
