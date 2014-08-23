require 'yaml'

module Monotes
  class IssueList

    def initialize(args)
      @fs = args.fetch(:fs)
      @repository = args.fetch(:repository)
    end

    def save(args)
      issues = Array(args)
      issues.each do |issue|
        @fs.save(issue.to_yaml)
      end
    end
  end
end
