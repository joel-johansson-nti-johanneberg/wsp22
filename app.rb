require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions

def connect_to_db()
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    return db
end

get('/showlogin') do
  p session[:auth]
  slim(:login)
end

get('/register') do
  slim(:register)
end

post('/login') do
  username = params[:username]
  password = params[:password]
  db = connect_to_db()
  result = db.execute("SELECT * FROM user WHERE username = ?",username).first
  if result == nil
    redirect("https://www.youtube.com/watch?v=D-NJOoLlNC4")
  end
  pwdigest = result["pwdigest"]
  id = result["id"]
  auth = result["authorization"]
  
  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    session[:auth] = true
    redirect('/')
  else
    session[:auth] = false
    redirect("https://www.youtube.com/watch?v=D-NJOoLlNC4")
  end
end
get('/logout') do
  session[:id] = nil 
  redirect('/')
end 
post('/users/new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if password == password_confirm && username.length <= 12
    password_digest = BCrypt::Password.create(password)
    authorization = 1
    db = connect_to_db()
    db.execute("INSERT INTO user (username,pwdigest,authorization) VALUES (?,?,?)",username,password_digest,authorization)
    session[:auth] = true
    redirect('/')
  else 
    session[:auth] = false
    "Användarnamnet är för långt/Lösenorden matchade inte."
  end
end

get('/')  do
  slim(:start)
end 

get('/restaurants') do 
  db = connect_to_db()
  restaurants = db.execute("SELECT * FROM restaurant")
 # p restaurants
  slim(:"restaurants/index", locals:{restaurants:restaurants})
end 

get('/dishes/new')do 
  slim(:"dishes/new")
end
post('/dishes/:id/delete') do
  id = params[:id].to_i
  db = connect_to_db()
  db.execute("DELETE FROM dishes WHERE id = ?",id)
  redirect('/')
end
post('/dishes/new') do
  # p "PARAMS: #{params}"
  name = params[:name]
  type_of_food_id = params[:type_of_food_id].to_i
  where_id = params[:where_id].to_i
  db = connect_to_db()
  db.execute("INSERT INTO dishes (name,type_of_food_id,where_id) VALUES (?,?,?)",name, type_of_food_id,where_id)
  redirect('/')
end 
get('/dishes/:id/edit') do
  id = params[:id].to_i
  db = connect_to_db()
  result = db.execute("SELECT * FROM dishes WHERE id = ?",id).first
  slim(:"/dishes/edit",locals:{result:result})
end

post('/dishes/:id/update') do
  id = params[:id].to_i
  name = params[:name]
  db = connect_to_db()
  db.execute("UPDATE dishes SET name=? WHERE id = ?",name,id)
  redirect('/')
end

get('/restaurant/:id') do
  restaurant_data = params[:id]
  session[:resturant_id]=params[:id]
  db = connect_to_db()
  restaurant = db.execute("SELECT * FROM restaurant WHERE id = ?",restaurant_data ).first
  type_of_food = db.execute("SELECT * FROM (type_of_food_restaurant_relation INNER JOIN type_of_food ON type_of_food_restaurant_relation.type_of_food_id = type_of_food.id) WHERE restaurant_id = ?",restaurant_data )
  p type_of_food
  slim(:"restaurant/index", locals:{type_of_food:type_of_food,restaurant_id:restaurant_data,restaurant:restaurant})
end

get("/restaurant/:resturant_id/type_of_food/:id") do
  restaurant_data = params[:resturant_id]
  type_of_food_data = params[:id].to_i
  # p type_of_food_data
  db = connect_to_db()
  type_of_food_name = db.execute("SELECT * FROM type_of_food WHERE id = ?",type_of_food_data ).first
  # p type_of_food_name
  dishes = db.execute("SELECT * FROM dishes WHERE where_id = ? AND type_of_food_id = ?", restaurant_data, type_of_food_data)
  p dishes
  slim(:"type_of_food/index", locals:{dishes:dishes,type_of_food_name:type_of_food_name})
end
