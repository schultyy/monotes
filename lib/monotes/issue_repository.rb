require 'yaml'

module Monotes
  class IssueRepository

    def initialize(args)
      @context = args.fetch(:context)
      @repository = args.fetch(:repository)
    end

    def save(args)
      issues = Array(args)
      issues.each do |issue|
        @context.save(*@repository.split('/'), issue.to_yaml)
      end
    end
  end
end
