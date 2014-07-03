module RPS2
  class Move
    attr_reader :id, :user_id, :match_id, :game_id, :move, :move_id

    def initialize(user_id,match_id,game_id,move,move_id=nil)
      @move = move
      @user_id = user_id
      @move_id = RPS2.orm.create_move(@user_id,match_id,game_id,@move)
    end

  end
end