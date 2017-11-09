class UsersController < ApplicationController
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
      if current_user.id == params[:id]
        erb :'users/items'
      else
        redirect '/'
      end
    else
      redirect '/login'
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

end
