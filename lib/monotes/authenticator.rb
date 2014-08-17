module Monotes
  class Authenticator
    ACCESS_NOTE = "Monotes access token"
    def initialize(&block)
      @api_client_block = block
    end

    def get_oauth_token(username, password, &acquire_two_fa)
      api_client = @api_client_block.call(:login => username, :password => password)
      begin
      api_client.create_authorization(:scopes => ["user"], :note => ACCESS_NOTE)
      rescue Octokit::OneTimePasswordRequired => otp_error
        two_fa_token = yield acquire_two_fa
      end
    end
  end
end
