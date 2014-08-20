module Monotes
  class SyncList

    def initialize(args)
      @list = args.fetch(:list)
      @adapter = args.fetch(:adapter)
    end
  end
end
