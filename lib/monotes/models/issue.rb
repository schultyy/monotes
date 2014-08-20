require 'virtus'

module Monotes
  module Models
    class Issue
      include Virtus.model
      attribute :url, String
      attribute :id, Fixnum, :default => 0
      attribute :number, Fixnum, :default => 0
      attribute :title, String
      attribute :state, String
      attribute :created_at, DateTime
      attribute :updated_at, DateTime
      attribute :body, String

      def unsynced
        number == 0
      end
    end
  end
end
