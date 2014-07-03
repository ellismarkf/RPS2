require 'pry-byebug'
require 'pg'

module RPS2
  class ORM

    def initialize
      @db = PG.connect(host: 'localhost', dbname: 'RPS2')
      build_tables
    end

    def build_tables
      @db.exec(%q[
        CREATE TABLE IF NOT EXISTS users (
        id serial NOT NULL PRIMARY KEY,
        username varchar(30),
        password_digest text
      )])

      @db.exec(%q[
        CREATE TABLE IF NOT EXISTS sessions (
        id serial NOT NULL PRIMARY KEY,
        user_id integer REFERENCES users(id)
      )])

      @db.exec(%q[
        CREATE TABLE IF NOT EXISTS matches (
        id serial NOT NULL PRIMARY KEY,
        player1 integer REFERENCES users(id),
        player2 integer REFERENCES users(id),
        player1_win_count integer,
        player2_win_count integer,
        active text
      )])

      @db.exec(%q[
        CREATE TABLE IF NOT EXISTS games (
        id serial NOT NULL PRIMARY KEY,
        player1 integer REFERENCES users(id),
        player2 integer REFERENCES users(id),
        match_id integer REFERENCES matches(id)
      )])

      @db.exec(%q[
        CREATE TABLE IF NOT EXISTS moves (
        id serial NOT NULL PRIMARY KEY,
        user_id integer REFERENCES users(id),
        match_id integer REFERENCES matches(id),
        game_id integer REFERENCES games(id),
        move text
      )])
    end

    def create_user(username,password_digest)
      response = @db.exec_params(%Q[ INSERT INTO users (username,password_digest)
      VALUES ($1,$2) RETURNING id;], [username,password_digest])

      response.first["id"]
    end

    def create_session(params)
      response = @db.exec_params(%Q[ INSERT INTO sessions (user_id) VALUES ($1) RETURNING id;], [params[:user_id]])

      response.first["id"]
    end

    def get_user_by_id(user_id)
      response = @db.exec("SELECT * FROM users WHERE id = #{user_id};")

      response.first["username"]
    end

    def check_user(username)
      response = @db.exec("SELECT * FROM users WHERE username = '#{username}';")
      puts response.first
      if response.first == nil
        return nil
      end
      puts response.first["username"]
      response.first["username"]
    end

    def get_user(username)
      response = @db.exec("SELECT * FROM users WHERE username = '#{username}';")

      if response.first == nil
        return nil
      end
      response.first
    end

    def create_match(player1,player2)
      response = @db.exec_params(%Q[ INSERT INTO matches (player1,player1_win_count,player2_win_count,active)
      VALUES ($1,$2,$3,$4) RETURNING id;], [player1,0,0,'yes'])

      response.first["id"]
    end

    def grab_match(match_id)
      response = @db.exec("SELECT * FROM matches WHERE id = #{match_id};")

      return response.first
    end

    def get_latest_match(user_id)
      response = @db.exec("SELECT * FROM matches WHERE player1 = '#{user_id}';")

      return response[-1]["id"]
    end

    def find_open_match
      return response = @db.exec("SELECT * FROM matches WHERE player2 IS NULL;")
    end

    def update_match(match_id,player2)
      @db.exec("UPDATE matches SET player2 = #{player2} where id = #{match_id};")
    end

    def create_game(player1,player2,match_id)
      response = @db.exec_params(%Q[ INSERT INTO games (player1,player2,match_id)
      VALUES ($1,$2,$3) RETURNING id;], [player1,player2,match_id])

      response.first["id"]
    end

    def grab_game(match_id)
      response = @db.exec("SELECT * FROM games WHERE id = '#{match_id}';")

      return response[-1]["id"]
    end

    def create_move(user_id,match_id,game_id,move)
      response = @db.exec_params(%Q[ INSERT INTO moves (user_id,match_id,game_id,move)
      VALUES ($1,$2,$3,$4) RETURNING id;], [user_id,match_id,game_id,move])

      response.first["id"]
    end

    def find_moves(game_id)
      return response = @db.exec_params("SELECT * FROM moves where game_id = #{game_id};")
    end

    def update_winner(result,match_id,player1,player2)
      if result == "tie"
        return
      elsif result == player1
        @db.exec("UPDATE matches SET player1_win_count = player1_win_count + 1 WHERE id = #{match_id};")
      elsif result == player2
        @db.exec("UPDATE matches SET player2_win_count = player2_win_count + 1 WHERE id = #{match_id};")
      end
    end

    def check_match_status(match_id)
      return @db.exec("SELECT * from matches WHERE id = #{match_id}")
    end

    def match_over(match_id)
      @db.exec("UPDATE matches SET active = \'no\' WHERE id = #{match_id};")
    end

    # def find_empty_move(game_id)
    #   check = @db.exec("SELECT move1 FROM games where id = #{game_id};")
    #   if check.first == nil
    #     return "move1"
    #   else
    #     return "move2"
    #   end
    # end



  end

    def self.orm
      @__db_instance ||= ORM.new
    end
end