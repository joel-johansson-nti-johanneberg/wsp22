require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions
require_relative './model.rb'

before do
  if session[:auth] == nil && (request.path_info != '/login' &&request.path_info != '/error' && request.path_info != '/' && request.path_info != '/showlogin' && request.path_info != '/register' )
    redirect('/error')
  end
end

before('/restaurant/:id/edit') do
  if session[:id] != 1 
    redirect('/error_authorization')
  end
end

get('/error') do
  slim(:error)
end

get('/error_authorization') do
  slim(:error_authorization)
end

get('/')  do
  slim(:start)
end 

get('/register') do
  slim(:register)
end

get('/logout') do
  session[:auth] = nil 
  redirect('/')
end 

get('/showlogin') do
  slim(:login)
end

post('/login') do
  username = params[:username]
  password = params[:password]
  login_post(username,password)
end

post('/users/new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
  user_new_post( username,password,password_confirm) 
end


get('/restaurants') do 
  restaurants_get()
end 

get('/dishes/new')do 
  slim(:"dishes/new")
end

post('/dishes/:id/delete') do
  id = params[:id].to_i
  dish_delete_post(id)
end

post('/dishes/new') do
  name = params[:name]
  type_of_food_id = params[:type_of_food_id].to_i
  where_id = params[:where_id].to_i
  dish_new_post(name,type_of_food_id,where_id)
end 

get('/dishes/:id/edit') do
  id = params[:id].to_i
  dish_edit_get(id)
end

post('/dishes/:id/update') do
  id = params[:id].to_i
  name = params[:name]
  where_id = params[:where_id].to_i
  type_of_food_id = params[:type_of_food_id].to_i
  dish_edit_post(id,name,where_id,type_of_food_id)
end

get('/restaurant/:id/edit') do
  id = params[:id].to_i
  restaurant_edit_get(id)
end

post('/restaurant/:id/update') do
  id = params[:id].to_i
  name = params[:name]
  link = params[:link]
  restaurant_edit_post(id,name,where_id,link)
end

post('/restaurant/:id/delete') do
  id = params[:id].to_i
  restaurant_delete_post(id)
end

get('/restaurant/:id') do
  restaurant_data = params[:id]
  resturant_id_get(restaurant_data) 
end

get("/restaurant/:resturant_id/type_of_food/:id") do
  restaurant_data = params[:resturant_id]
  type_of_food_data = params[:id].to_i
  restaurant_resturant_id_type_of_food_id_get(restaurant_data,type_of_food_data)
end
