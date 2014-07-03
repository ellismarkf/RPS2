module RPS2
  class SignUp
    def self.run(params)
      username = params[:username]
      password = params[:password]

      user_exists = RPS2.orm.check_user(username)

      if user_exists != nil
        return  { success?: false}
      end

      user = RPS2::User.new(username,password)

      session_id = RPS2.orm.create_session({ :user_id => user.user_id})

      return {
        success?: true,
        username: username,
        password: password
      }

    end
  end
end