module Monotes
  class Authenticator
    ACCESS_NOTE = "Monotes access token"
    def initialize(api_client_klass)
      @api_client_klass = api_client_klass
    end

    def get_oauth_token(username, password, &acquire_two_fa)
      api_client = @api_client_klass.new(:login => username, :password => password)
      begin
        api_client.create_authorization(:scopes => scopes, :note => ACCESS_NOTE)
      rescue Octokit::OneTimePasswordRequired
        two_fa_token = yield acquire_two_fa
        api_client.create_authorization(:scopes => scopes, :note => ACCESS_NOTE,
                                       :headers => { "X-GitHub-OTP" => two_fa_token })
      end
    end
    private
    def scopes
      ["user", "repo"]
    end
  end
end
