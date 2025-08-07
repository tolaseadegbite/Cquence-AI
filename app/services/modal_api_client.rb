require "net/http"
require "uri"
require "json"

class ModalApiClient
  REQUEST_TIMEOUT = 300

  def self.generate(endpoint, body)
    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    http.open_timeout = 10
    http.read_timeout = REQUEST_TIMEOUT

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    request["Modal-Key"] = Rails.application.credentials.modal.api_key
    request["Modal-Secret"] = Rails.application.credentials.modal.api_secret
    request.body = body.to_json

    http.request(request)
  end
end
