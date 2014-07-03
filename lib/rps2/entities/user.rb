require 'digest/sha1'

module RPS2
  class User

    attr_reader :username, :password_digest, :user_id

    def initialize(username, password_digest=nil, user_id = nil)
      @username = username
      @password_digest = Digest::SHA1.hexdigest(password_digest)
      @user_id = RPS2.orm.create_user(@username,@password_digest)
    end

  end
end