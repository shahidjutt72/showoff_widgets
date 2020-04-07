# frozen_string_literal: true

class Widget
  include Api::Builder

  attr_accessor :id, :name, :description, :kind, :user, :owner

  def attributes
    {
      name: nil,
      description: nil,
      kind: nil
    }
  end

  def self.all(type, term = '', current_user)
    if type == 'visible'
      response = execute(:get, "/api/v1/widgets/visible?term=#{term}&client_id=#{ENV['CLIENT_ID']}&client_secret=#{ENV['CLIENT_SECRET']}", {})
    else
      response = execute(:get, '/api/v1/widgets', current_user.serializable_hash)
    end

    widgets = response[:data][:widgets].map { |widget| Widget.new(widget) }
    widgets
  rescue RestClient::UnprocessableEntity => e
    false
  end

  def self.all_by_user(id, term = '', current_user)
    response = execute(:get, "/api/v1/users/#{id}/widgets?term=#{term}&client_id=#{ENV['CLIENT_ID']}&client_secret=#{ENV['CLIENT_SECRET']}", {}, { "Authorization": "Bearer #{current_user.access_token}" })
    widgets = response[:data][:widgets].map { |widget| Widget.new(widget) }
    widgets
  rescue RestClient::UnprocessableEntity => e
    []
  end

  def save(current_user)
    if id.present?
      response = self.class.execute(:put, "/api/v1/widgets/#{id}", { widget: serializable_hash }, { "Authorization": "Bearer #{current_user.access_token}" })
    else
      response = self.class.execute(:post, '/api/v1/widgets', { widget: serializable_hash }, { "Authorization": "Bearer #{current_user.access_token}" })
      self.id = response[:id]
    end
    response
    # rescue RestClient::UnprocessableEntity => exception
    # return false
  end

  def self.destroy(current_user, id)
    response = execute(:delete, "/api/v1/widgets/#{id}", { "Authorization": "Bearer #{current_user.access_token}" })
    response
  rescue RestClient::UnprocessableEntity => e
  end
end
