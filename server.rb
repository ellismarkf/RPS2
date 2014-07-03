require 'sinatra'

enable :sessions

require_relative 'lib/rps2.rb'

set :bind, '0.0.0.0'

get '/signup' do
  erb :signup
end

post '/signup' do
  result = RPS2::SignUp.run(params)
  if result[:success?] == false
    @error = "User already exists! Please choose another username."
    redirect to '/sign_up_error'
  end
  session[:username] = result[:username]
  redirect to '/dashboard'
end
# post '/rps' do
#   user = params[:username]
#   pass = params[:password]
#   erb :dashboard
# end

get '/dashboard' do
  puts session.inspect
  # @user = params[:username]
  # @pass = params[:password]
  erb :dashboard
end

get '/play-move/:movetype' do
  user = RPS2.orm.get_user(session[:username])
  p1_user_id = user["id"]
  match_id = RPS2.orm.get_latest_match(p1_user_id)
  current_game_id = RPS2.orm.grab_game(match_id)

  move = params[:movetype]

  case move
  when 1
    move = 'rock'
  when 2
    move = 'paper'
  when 3
    move = 'scissors'
    return move
  end

  RPS2::Move.new(p1_user_id,match_id,current_game_id,move)

  run_game = RPS2::PlayGame.run({:game_id => current_game_id, :match_id => match_id})
  @p1_move = run_game[:p1_move]

  erb :play

end

get '/sign_up_error' do
  erb :sign_up_error
end

get '/play' do
  user = RPS2.orm.get_user(session[:username])
  result = RPS2::JoinMatch.run({ player: user["id"]})
  puts result.inspect
  if result[:success?] == false
    @error = "Waiting on opponent to join your match."
    erb :dashboard
  else
    erb :play
  end
end

get '/play/:game_id' do

end

get '/login' do
  puts session.inspect
  erb :login
end

post '/login' do
  result = RPS2::SignIn.run(params)
  if result[:success?]
    session[:username] = result[:username]
    # session[:password] = params[:password]
  end
  redirect to '/dashboard'
end

post '/logout' do
  session.clear
  redirect to '/login'
end