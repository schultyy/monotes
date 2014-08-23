require 'monotes/models/issue'

module Monotes
  class SyncList

    def initialize(args)
      @list = args.fetch(:list)
      @adapter = args.fetch(:adapter)
      @repository = args.fetch(:repo)
    end

    def sync
      unsynced = @list.find_all {|issue| issue.unsynced }
      unsynced.map do |issue|
        result = @adapter.create_issue(@repository, issue.title, issue.body)
        yield(result) if block_given?
        Monotes::Models::Issue.new(result.to_hash)
      end
    end
  end
end
