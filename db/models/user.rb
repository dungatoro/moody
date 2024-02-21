# frozen_string_literal: true

DB = Sequel.sqlite 'db/local.db'

# base user model inherits from Sequel::Model
# - serialize to database
# - creates `initialize` method automatically using table fields
class User < Sequel::Model
  def password=(password)
    self.password_hash = BCrypt::Password.create(password)
  end

  def authenticate(password)
    BCrypt::Password.new(password_hash) == password
  end
end
