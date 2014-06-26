require 'sinatra'
require 'pg'

set :bind, '0.0.0.0'

get '/rps' do
  erb :login
end

post '/rps' do
  erb :dashboard
end