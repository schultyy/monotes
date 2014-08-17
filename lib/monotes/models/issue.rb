require 'virtus'

module Monotes
  module Models
    class Issue
      include Virtus.model
      attribute :url, String
      attribute :id, Fixnum
      attribute :number, Fixnum
      attribute :title, String
      attribute :state, String
      attribute :created_at, DateTime
      attribute :updated_at, DateTime
      attribute :body, String
    end
  end
end
