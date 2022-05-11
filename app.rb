require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions
require_relative './model.rb'
include Model
# Attempts to check if the client has authorization
before do
  if session[:auth] == nil && (request.path_info != '/login' && request.path_info != '/users/new' && request.path_info != '/error' && request.path_info != '/' && request.path_info != '/showlogin' && request.path_info != '/register' )
    redirect('/error')
  end
end
  # Attempts to check if restaurant exist
before('/restaurant/:id') do
  id = params[:id]
  if not restaurant_exist(id)
    redirect('/error_authorization')
  end
end
# Attempts to check if the client has authorization
before('/restaurant/:id/edit') do
  if session[:id] != 1 
    redirect('/error_authorization')
  end
end
# Displays an error message
get('/error') do
  slim(:error)
end
# Displays an error message
get('/error_empty') do
  slim(:error_empty)
end
# Displays an error message
get('/error_authorization') do
  slim(:error_authorization)
end
# Displays an error message
get('/error_restaurang_relation') do
  slim(:error_restaurang_relation)
end 
# Display Landing Page
get('/')  do
  slim(:start)
end 
# Displays a register form
get('/register') do
  slim(:register)
end
# Displays Landing Page from logout
get('/logout') do
  session[:auth] = nil 
  redirect('/')
end 
# Displays a login form
get('/showlogin') do
  slim(:login)
end
# Login 
post('/login') do
  if session[:timeLogged] == nil
    session[:timeLogged] = 0
  end
  logTime =  timeChecker(session[:timeLogged])
  session[:timeLogged] = Time.now.to_i
  if logTime
    username = params[:username]
    password = params[:password]
    login_post(username,password)
  else
    redirect('/showlogin')
  end
end
# Creates new user
# @param [String] username, the user username
# @param [String] password, the user password
# @param [Hash] result, all information of a specific user
post('/users/new') do
  if session[:timeLogged] == nil
    session[:timeLogged] = 0
  end
  logTime =  timeChecker(session[:timeLogged])
  session[:timeLogged] = Time.now.to_i
  if logTime
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    user_new_post( username,password,password_confirm) 
  else
    redirect('/showlogin')
  end
end
# Displays a list of all restaurants
get('/restaurants') do 
  restaurants_get()
end 
# Displays all dishes according to the filter
get('/eaten_dishes/show') do 
  person = session[:id]
  result = eaten_dishes_show_get(person) 
  slim(:"person_dishes", locals:{result:result})
end
# Displays a form to post new dish
get('/dishes/new')do 
  restaurants = restaurants_data()
  slim(:"dishes/new",locals:{restaurants:restaurants})
end
# Deletes an existing dish
post('/dishes/:id/delete') do
  id = params[:id].to_i
  dish_delete_post(id)
end
# Creates a new dish
post('/dishes/') do
  name = params[:name]
  type_of_food_id = params[:type_of_food_id].to_i
  where_id = params[:where_id].to_i
  dish_new_post(name,type_of_food_id,where_id)
end 
# Displays a edit dish  form
get('/dishes/:id/edit') do
  id = params[:id].to_i
  dish_edit_get(id)
end
# Updates an existing dish
post('/dishes/:id/update') do
  id = params[:id].to_i
  name = params[:name]
  where_id = params[:where_id].to_i
  type_of_food_id = params[:type_of_food_id].to_i
  dish_edit_post(id,name,where_id,type_of_food_id)
end
# Displays a edit restaurant form
get('/restaurant/:id/edit') do
  id = params[:id].to_i
  restaurant_edit_get(id)
end
# Updates an existing restaurant
post('/restaurant/:id/update') do
  id = params[:id].to_i
  name = params[:name]
  link = params[:link]
  restaurant_edit_post(id,name,where_id,link)
end
# Deletes an existing restaurant
post('/restaurant/:id/delete') do
  id = params[:id].to_i
  restaurant_delete_post(id)
end
# Displays a list of all type of food at the selected restant
get('/restaurant/:id') do
  restaurant_data = params[:id]
  resturant_id_get(restaurant_data) 
end
# Displays a list of all dishes at the selected type of food at the selected restaurant
get("/restaurant/:resturant_id/type_of_food/:id") do
  restaurant_data = params[:resturant_id]
  type_of_food_data = params[:id].to_i
  restaurant_resturant_id_type_of_food_id_get(restaurant_data,type_of_food_data)
end
