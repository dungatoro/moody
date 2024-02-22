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
# this creates a `session` table storing currently active user
enable :sessions

get '/' do
  erb :index
end

get '/signup' do
  erb :signup
end

post '/signup' do
  # match passwords
  if params[:password] != params[:confirm_password]
    erb :signup_err
  # make sure email is unique
  elsif DB[:users].where(email: params[:email]).first
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
    session[:user] = user.id
    redirect '/new_mood'
  else
    erb :login_err
  end
end

get '/logout' do
  session.clear
  redirect '/login'
end

get '/history' do
  @moods = DB[:moods].where(user_id: session[:user]).order(Sequel.desc(:time))
  erb :history
end

get '/new_mood' do
  erb :new_mood
end

post '/new_mood' do
  puts params[:mood].class
  puts params[:note].class
  mood = Mood.new(
    user_id: session[:user],
    mood: params[:mood],
    note: params[:note],
    time: Time.now.to_i
  )
  if mood.save
    redirect '/history'
  else
    redirect '/login'
  end
end
