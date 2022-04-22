require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions
require_relative './model.rb'

before do
  p "Before KÖRS, session_user_id är #{session[:id]}"
  if session[:auth] == nil && (request.path_info != '/login' &&request.path_info != '/error' && request.path_info != '/' && request.path_info != '/showlogin' && request.path_info != '/register' )
    redirect('/error')
  end
end

get('/error') do
  slim(:error)
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
  p session[:auth]
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

get('/restaurant/:id') do
  restaurant_data = params[:id]
  resturant_id_get(restaurant_data) 
end

get("/restaurant/:resturant_id/type_of_food/:id") do
  restaurant_data = params[:resturant_id]
  type_of_food_data = params[:id].to_i
  restaurant_resturant_id_type_of_food_id_get(restaurant_data,type_of_food_data)
end

get('/error/:id') do
  errors = {
      401 => "Not authorized",
      404 => "Page not found"
  }

  errorId = params[:id].to_i
  errorMsg = errors[errorId]

  slim(:error, locals: {errorId:errorId, errorMsg:errorMsg})
end

not_found do
  redirect("/error/404")
end