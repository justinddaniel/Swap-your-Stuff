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
    Item.all.each do |i|
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
    if params["name"] != "" && params["description"] != "" && (params["tradeable?"] != nil || "")
      new_item = Item.create(params)
      new_item.user = item_user
      new_item.save
      redirect "/users/#{item_user.id}"
    else
      redirect "/items/new"
    end
  end

  get '/items/:id' do
    if logged_in?
      if (session[:user_id] == Item.find_by_id(params[:id]).user_id) ||
      (Item.find_by_id(params[:id]).tradeable? == true)
        @item_to_view = Item.find_by_id(params[:id])
        erb :'items/one'
      else
        redirect '/items'
      end
    else
      redirect '/login'
    end
  end

  get '/items/:id/edit' do
    if logged_in?
      @item_to_edit = Item.find(params[:id])
      if @item_to_edit.user_id == session[:user_id]
        erb :'/items/edit_item'
      else
        redirect '/items'
      end
    else
      redirect '/login'
    end
  end

  patch '/items/:id' do
    @item_to_edit = Item.find(params[:id])
    if params[:name] != ""
      @item_to_edit.name = params[:name]
      @item_to_edit.save
    end
    if params[:description] != ""
      @item_to_edit.description = params[:description]
      @item_to_edit.save
    end
    if params[:tradeable?] == true
      @item_to_edit.tradeable?
      @item_to_edit.save
    end
    if params[:tradeable?] == false
      @item_to_edit.tradeable?
      @item_to_edit.save
    end
    if params[:condition] != ""
      @item_to_edit.condition = params[:condition]
      @item_to_edit.save
    end
    if params[:asking_price] != ""
      @item_to_edit.asking_price = params[:asking_price]
      @item_to_edit.save
    end
    if params[:keywords] != ""
      @item_to_edit.keywords = params[:keywords]
      @item_to_edit.save
    end
    redirect "/items/#{@item_to_edit.id}"
  end

  delete '/items/:id/delete' do
    @item_to_delete = Item.find(params[:id])
    if @item_to_delete.user_id == session[:user_id]
      @item_to_delete.delete
      redirect '/items'
    else
      redirect '/items'
    end
  end

  get '/logout' do
    if logged_in?
      session.clear
      redirect '/login'
    else
      redirect "/"
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
