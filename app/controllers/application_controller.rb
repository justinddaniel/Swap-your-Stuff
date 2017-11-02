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
    if logged_in?
      user = User.find_by_id(session[:user_id])
      session[:user_id] = user.id
      redirect "/users/#{user.id}"
    else
      erb :'users/login'
    end
  end

  post '/login' do
    user = User.find_by(:username => params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/users/#{user.id}"
    else
      redirect "/login"
    end
  end

  get '/user-agreement' do
    erb :'users/agreement'
  end

  get '/users/:id' do
    if logged_in?
      @user = User.find_by_id(params[:id])
      erb :'users/items'
    else
      redirect '/login'
    end
  end

  get '/items' do
    @all_tradeable_items = []
    Items.all.each do |i|
      if i.tradeable? == true
        @all_tradeable_items << i
      end
    end
    erb :'items/show'
  end

  get '/items/new' do
    if logged_in?
      erb :'items/create_item'
    else
      redirect "/login"
    end
  end

  post '/items' do
    item_user = User.find_by_id(session[:user_id])
    if params["name"] != "" && params["description"] != ""
      new_item = Item.create(params)
      new_item.user = item_user
      new_item.save
      redirect "/users/#{item_user.id}"
    else
      redirect "/items/new"
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
