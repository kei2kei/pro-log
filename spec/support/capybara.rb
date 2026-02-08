require "capybara/rspec"

Capybara.server = :puma, { Silent: true }

Capybara.register_driver :selenium_remote do |app|
  url = ENV.fetch("SELENIUM_REMOTE_URL", "http://selenium:4444/wd/hub")

  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    "goog:chromeOptions" => {
      args: %w[
        headless
        no-sandbox
        disable-dev-shm-usage
        window-size=1400,900
      ]
    }
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: url,
    capabilities: capabilities
  )
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_remote

    Capybara.server_host = "0.0.0.0"
    Capybara.server_port = 3001

    default_app_host = if ENV["SELENIUM_REMOTE_URL"].present?
      "http://web:#{Capybara.server_port}"
    else
      "http://127.0.0.1:#{Capybara.server_port}"
    end

    Capybara.app_host = ENV["CAPYBARA_APP_HOST"].presence || default_app_host
  end
end
