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
        issue.number = result.number
        yield(result) if block_given?
        issue
      end
    end
  end
end
