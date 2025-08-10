# lib/constraints/authenticated_constraint.rb

module Constraints
  class AuthenticatedConstraint
    def matches?(request)
      # Use `request.cookie_jar` which returns the object with the .signed method
      session_token = request.cookie_jar.signed[:session_token]

      session_token.present? && Session.exists?(session_token)
    end
  end
end