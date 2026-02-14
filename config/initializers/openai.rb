# config/initializers/openai.rb
OpenAI.configure do |config|
  config.access_token =
    Rails.application.credentials.dig(:openai, :api_key).presence ||
    ENV["OPENAI_API_KEY"].to_s.presence
end
