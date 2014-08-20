module Monotes
  class SyncList

    def initialize(args)
      @list = args.fetch(:list)
      @adapter = args.fetch(:adapter)
      @repository = args.fetch(:repo)
    end

    def sync
      @list.find_all {|issue| issue.unsynced }.each do |issue|
        @adapter.create_issue(@repository, issue.title, issue.body)
      end
    end
  end
end
