# frozen_string_literal: true

require 'sinatra'
require 'sequel'
require 'bcrypt'

# Load all Sequel models
$LOAD_PATH.push('db/models')
Dir.glob('db/models/*.rb').sort.each { |file| require_relative file }

# Connect to local SQLite database
DB = Sequel.sqlite 'db/local.db'

# enable sessions to keep user logged in during their visit
# this creates a `session` table storing currently active users
enable :sessions

get '/' do
  erb :index
end

get '/signup' do
  erb :signup
end

post '/signup' do
  # Make sure email is unique
  if DB[:users].where(email: params[:email]).first
    erb :signup_err
  else
    user = User.new(
      email: params[:email],
      username: params[:username],
      password: params[:password]
    )
    if user.save
      session[:user_id] = user.id
      redirect '/'
    else
      erb :signup_err
    end
  end
end

get '/login' do
  erb :login
end

post '/login' do
  user = User.find(email: params[:email])
  if user&.authenticate(params[:password])
    session[:user_id] = user.id
    redirect '/'
  else
    erb :login_err
  end
end

get '/logout' do
  session.clear
  redirect '/login'
end
