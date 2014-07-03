module RPS2
  class JoinMatch
    def self.run(params)

      specified_match = RPS2.orm.find_open_match

      if specified_match.first == nil
        RPS2::Match.new(params[:player])
        return {success?: true}
      elsif specified_match.first["player1"] == params[:player]
        return {success?: false}
      else
        RPS2.orm.update_match(specified_match.first["id"],params[:player])
        RPS2::Game.new(specified_match.first["player1"],params[:player],specified_match.first["id"])
        return {success?: true}
      end


    end
  end

end