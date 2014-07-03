module RPS2
  class Game
    attr_reader :starter_player, :joiner_player, :match_id, :game_id

    def initialize(starter_player,joiner_player,match_id,game_id = nil)
      @starter_player = starter_player
      @joiner_player = joiner_player
      @match_id = match_id
      @game_id = RPS2.orm.create_game(@starter_player,@joiner_player,@match_id)
    end

  end
end