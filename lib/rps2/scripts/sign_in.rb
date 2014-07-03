require 'digest/sha1'

module RPS2
  class SignIn

    def self.run(params)
      user = RPS2.orm.get_user(params[:username])

      if user["password_digest"] != Digest::SHA1.hexdigest(params[:password])
        return { :success? => false, :error => :invalid_password }
      end

      session_id = RPS2.orm.create_session({ :user_id => user["id"]})

      return { :success? => true,
               :session_id => session_id,
               :username => user["username"],
               :password => user["password_digest"]  }

    end
  end
end