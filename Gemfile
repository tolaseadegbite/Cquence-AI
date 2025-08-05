source "https://rubygems.org"

gem "rails", "~> 8.0.2"
gem "bootsnap", require: false
gem "importmap-rails"
gem "jbuilder"
gem "kamal", require: false
gem "pg", "~> 1.1"
gem "propshaft"
gem "puma", ">= 5.0"
gem "solid_cache"
gem "solid_cable"
gem "solid_queue"
gem "stimulus-rails"
gem "thruster", require: false
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use Active Model has_secure_password
gem "bcrypt", "~> 3.1.7"
# Use Active Storage variants
gem "image_processing", "~> 1.2"

group :development, :test do
  # Static analysis for security vulnerabilities
  gem "brakeman", require: false
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  # Omakase Ruby styling
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages
  gem "web-console"
end

group :test do
  # Use system testing
  gem "capybara"
  gem "selenium-webdriver"
end

gem "css-zero", "~> 2.0", github: "lazaronixon/css-zero"

gem "authentication-zero", "~> 4.0"
# Use Pwned to check if a password has been found in any of the huge data breaches [https://github.com/philnash/pwned]
gem "pwned"
# Use OmniAuth to support multi-provider authentication [https://github.com/omniauth/omniauth]
gem "omniauth"
# Provides a mitigation against CVE-2015-9284 [https://github.com/cookpad/omniauth-rails_csrf_protection]
gem "omniauth-rails_csrf_protection"
# Use rotp for generating and validating one time passwords [https://github.com/mdp/rotp]
gem "rotp"
# Use rqrcode for creating and rendering QR codes into various formats [https://github.com/whomwah/rqrcode]
gem "rqrcode"
# Use webauthn for making rails become a conformant web authn relying party [https://github.com/cedarcode/webauthn-ruby]
gem "webauthn"
