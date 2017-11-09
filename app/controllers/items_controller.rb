class ItemsController < ApplicationController
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
    if params["name"] != "" && params["description"] != "" && (params["tradeable?"] != nil)
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
    if params[:tradeable?] == "true"
      @item_to_edit.update_attributes(tradeable?: "true")
    end
    if params[:tradeable?] == "false"
      @item_to_edit.update_attributes(tradeable?: "false")
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
end
