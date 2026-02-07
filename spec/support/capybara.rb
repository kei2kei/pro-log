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
    Capybara.app_host = "http://web:3001"
  end
end