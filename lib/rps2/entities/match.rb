module RPS2

  class Match
    attr_reader :starter_player, :joiner_player, :match_id
    attr_accessor  :starter_win_count, :joiner_win_count

    def initialize(starter_player,joiner_player=nil)
      @starter_player = starter_player
      @joiner_player = joiner_player
      @starter_win_count = 0
      @joiner_win_count = 0
      @match_id = RPS2.orm.create_match(@starter_player,@joiner_player)
    end

    def load_match(match_id)
      RPS2.orm.grab_match(match_id)
    end

  end

end