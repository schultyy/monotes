require 'monotes/models/issue'

module Monotes
  class IssueDownload
    def initialize(api_client)
      @api_client = api_client
    end

    def download(repository)
      raise ArgumentError, 'repository must not be nil' if repository.nil?

      @api_client.list_issues(repository).map do |issue|
        Monotes::Models::Issue.new(issue)
      end
    end
  end
end
