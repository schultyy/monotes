require 'monotes/app_directory'
require 'yaml'

module Monotes
  class SyncList
    include Monotes::AppDirectory
    FILENAME = "unsynced.yaml"

    def initialize(fs)
      @fs = fs
      @list = {}
    end

    def record(repository, issue)
      issue_list = @list.fetch(repository,[])
      issue_list << { id: issue.number }
      @list[repository] = issue_list
    end

    def unsynced_count
      @list.values.flatten.length
    end

    def save
      @fs.save(FILENAME, @list.to_yaml)
    end
  end
end
