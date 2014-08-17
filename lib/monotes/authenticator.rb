module Monotes
  class Authenticator
    def initialize(&block)
      @api_client_block = block
    end

    def get_oauth_token(username, password, &acquire_two_fa)
      api_client = @api_client_block.call(:login => username, :password => password)
      api_client.create_authorization(:scopes => ["user"], :note => "Monotes access token")
    end
  end
end
