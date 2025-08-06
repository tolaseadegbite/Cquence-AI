# app/services/modal_api_client.rb
require "net/http"
require "uri"
require "json"

class ModalApiClient
  # Set a generous timeout for this long-running API call.
  # 300 seconds = 5 minutes.
  REQUEST_TIMEOUT = 300

  def self.generate(endpoint, body)
    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    # === ADD THESE LINES TO SET THE TIMEOUT ===
    http.open_timeout = 10 # Time to open connection (seconds)
    http.read_timeout = REQUEST_TIMEOUT # Time to wait for response (seconds)
    # ==========================================

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    request["Modal-Key"] = Rails.application.credentials.modal.api_key
    request["Modal-Secret"] = Rails.application.credentials.modal.api_secret
    request.body = body.to_json

    http.request(request)
  end
end
