require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :views, Proc.new { File.join(root, "../views/") }
    enable :sessions unless test?
    set :session_secret, "secret"
  end

  get '/' do
    erb :index
  end

  get '/signup' do
    erb :'/users/signup'
  end

  post '/signup' do
    user = User.new(:username => params[:username], :email => params[:email], :password => params[:password])
    if user.save
      session[:user_id] = user.id
      redirect "/users/#{user.id}"
    else
      redirect '/signup'
    end
  end

  get '/login' do
    erb :'users/login'
  end

  get '/user-agreement' do
    erb :'users/agreement'
  end

  get '/users/:id' do
    if logged_in?
      @user = User.find_by_slug(params[:id])
      erb :'users/items'
    else
      redirect '/login'
    end
  end



  helpers do
   def logged_in?
     !!session[:user_id]
   end

   def current_user
     User.find(session[:user_id])
   end

 end

end
