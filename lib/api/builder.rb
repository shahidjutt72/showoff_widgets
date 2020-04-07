# frozen_string_literal: true

module Api
  module Builder
    mattr_accessor :url
    def self.included(base)
      base.include ActiveModel::Model
      base.include ActiveModel::Serialization
      base.extend ClassMethods
    end

    def add_errors_to_resource(exception, resource)
      errors = JSON.parse(exception.response.body, symbolize_names: true)[:errors]
      errors&.each do |key, value|
        resource.errors.add(key, value.join(', '))
      end
    end

    def persisted?
      id.present?
    end

    def attributes=(attributes)
      attributes&.each do |attr, value|
        public_send("#{attr}=", value)
      end
    end

    module ClassMethods
      def execute(method, path, data = {}, headers = {})
        url = ENV['BASE_URL']
        client_details = { client_id: ENV['CLIENT_ID'], client_secret: ENV['CLIENT_SECRET'] }
        data.merge!(client_details)

        headers.merge!({ "Content-Type": 'application/json' })

        parameters = []
        parameters.unshift(data) unless data.blank?

        client = RestClient::Resource.new(url, headers: headers)
        response = client[path].send(method, *parameters)

        JSON.parse(response, symbolize_names: true) unless response.blank?
      end
    end
  end
end
