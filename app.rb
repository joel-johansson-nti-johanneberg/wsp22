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
    loginResult = login_post(username,password)
    if loginResult[:status] == true
      session[:id] = loginResult[:id]
      session[:auth] = loginResult[:auth]
      redirect('/')
    else
      redirect('/showlogin')
    end
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
    registerResult = user_new_post( username,password,password_confirm)
    if registerResult[:status] == true
      session[:auth] = registerResult[:auth]
      session[:id] = registerResult[:id]
      redirect('/') 
    else 
      "Användarnamnet är för långt/Lösenorden matchade inte/tomma fält"
    end
  else
    redirect('/showlogin')
  end
end
# Displays a list of all restaurants
get('/restaurants') do 
  restaurants = restaurants_get()
  slim(:"restaurants/index", locals:{restaurants:restaurants})
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
  sessionid = session[:id]
  deleteResult = dish_delete_post(id,sessionid)
  if deleteResult[:status] == true
    redirect('/restaurants')
  else
    redirect('/error_authorization')
  end
end
# Creates a new dish
post('/dishes/') do
  sessionid = session[:id]
  name = params[:name]
  type_of_food_id = params[:type_of_food_id].to_i
  where_id = params[:where_id].to_i
  newdishResult = dish_new_post(name,type_of_food_id,where_id,sessionid)
  if not newdishResult[:empty] == true
    if newdishResult[:status] == true
      redirect('/restaurants')
    else
      redirect('/error_restaurang_relation')
    end
  else 
    redirect('/error_empty')
  end
end 
# Displays a edit dish  form
get('/dishes/:id/edit') do
  id = params[:id].to_i
  sessionid = session[:id]
  getdishResult = dish_edit_get(id,sessionid)
  if getdishResult[:status] == true
    result = getdishResult[:result]
    slim(:"/dishes/edit",locals:{result:result})
  else
    redirect('/error_authorization')  
  end
end
# Updates an existing dish
post('/dishes/:id/update') do
  sessionid = session[:id]
  id = params[:id].to_i
  name = params[:name]
  where_id = params[:where_id].to_i
  type_of_food_id = params[:type_of_food_id].to_i
  updatedishResult = dish_edit_post(id,name,where_id,type_of_food_id,sessionid)
  if updatedishResult[:auth] == true
    if not updatedishResult[:empty] == true
      if updatedishResult[:status] == true
        redirect('/')
      else 
        redirect('/error_restaurang_relation')
      end
    else 
      redirect('/error_empty')
    end
  else
    redirect('/error_authorization')
  end
end
# Displays a edit restaurant form
get('/restaurant/:id/edit') do
  id = params[:id].to_i
  sessionid = session[:id]
  res_editResult = restaurant_edit_get(id,sessionid)
  if res_editResult[:status] == true
    result = res_editResult[:result]
    slim(:"/restaurants/edit",locals:{result:result})
  else
    redirect('/error_authorization') 
  end
end
# Updates an existing restaurant
post('/restaurant/:id/update') do
  id = params[:id].to_i
  name = params[:name]
  link = params[:link]
  sessionid = session[:id]
  restauranteditResult = restaurant_edit_post(id,name,where_id,link,sessionid)
  if restauranteditResult[:status] == true
    redirect('/restaurants')
  else
    redirect('/error_authorization')  
  end
end
# Deletes an existing restaurant
post('/restaurant/:id/delete') do
  id = params[:id].to_i
  sessionid = session[:id]
  deleteResult = restaurant_delete_post(id,sessionid)
  if deleteResult[:status] == true
    redirect('/restaurants')
  else
    redirect('/error_authorization')
  end
end
# Displays a list of all type of food at the selected restant
get('/restaurant/:id') do
  restaurant_data = params[:id]
  restaurantResult = resturant_id_get(restaurant_data) 
  type_of_food = restaurantResult[:type_of_food] 
  restaurant = restaurantResult[:restaurant]
  slim(:"restaurant/index", locals:{type_of_food:type_of_food,restaurant_id:restaurant_data,restaurant:restaurant})
end
# Displays a list of all dishes at the selected type of food at the selected restaurant
get("/restaurant/:resturant_id/type_of_food/:id") do
  restaurant_data = params[:resturant_id]
  type_of_food_data = params[:id].to_i
  res_res_Result = restaurant_resturant_id_type_of_food_id_get(restaurant_data,type_of_food_data)
  type_of_food_name = res_res_Result[:type_of_food_name]
  dishes = res_res_Result[:dishes]
  slim(:"type_of_food/index", locals:{dishes:dishes,type_of_food_name:type_of_food_name})
end
