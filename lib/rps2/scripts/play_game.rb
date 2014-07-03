module RPS2
  class PlayGame

    def self.run(params)

      overall = nil
      result = nil
      response = RPS2.orm.find_moves( params[:game_id] )
      player1 = response[0]["id"]
      move_one = response[0]["move"]
      # move_one = { response[0]["id"] => response[0]["move"] }
      if response.cmd_tuples != 1
        player2 = response[1]["id"]
        move_two = response[1]["move"]
        # move_two = { response[1]["id"] => response[1]["move"] }
      end

      # play = self.game_outcome(player1,player2,move_one,move_two,params,response)
      if response.cmd_tuples() == 1
        overall = { :success? => false, :error => :waiting_on_second_move }
      else
        # result = self.run_game(player1,player2,move_one,move_two)
        case move_one
          when 'rock'
            result = 'tie' if move_two == 'rock'
            result = player2 if move_two == 'paper'
            result = player1 if move_two == 'scissors'
          when 'paper'
            result = player1 if move_two == 'rock'
            result = 'tie' if move_two == 'paper'
            result = player2 if move_two == 'scissors'
          when 'scissors'
            result = player2 if move_two == 'rock'
            result = player1 if move_two == 'paper'
            result = 'tie' if move_two == 'scissors'
          else
            raise 'invalid move'
        end
        # Updates the winner in the current match
        RPS2.orm.update_winner(result,params[:match_id],player1,player2)

        # Updates the DB with new game, checks if match is over
        status = RPS2.orm.check_match_status(params[:match_id])
        if status[0]["player1_win_count"] == 3 || status[0]["player2_win_count"] == 3
          RPS2.orm.match_over(params[:match_id])
        else
          RPS2::Game.new(player1,player2,params[:match_id])
        end

        overall = { :success? => true, :winner => result, :p1_move => move_one }
      end

      return overall
    end

  end
end