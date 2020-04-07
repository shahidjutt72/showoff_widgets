# frozen_string_literal: true

class Session
  include Api::Builder

  attr_accessor :username

  attr_accessor :password

  # validates_presence_of :email, :password

  def attributes
    { username: nil,
      password: nil }
  end

  class << self
    def destroy(token)
      execute(:post, '/oauth/revoke', token, { "Authorization": "Bearer #{token[:token]}" })
    end
  end

  def persisted?
    false
  end

  def create
    self.class.execute(:post, '/oauth/token', serializable_hash.merge!({ "grant_type": 'password' }))
  end
end
