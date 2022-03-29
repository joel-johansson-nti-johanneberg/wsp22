require 'sinatra'
require 'slim'
require 'sqlite3'

def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end
   
get('/')  do
  slim(:start)
end 

get('/restaurants') do 
  db = SQLite3::Database.new("db/database.db")
  db.results_as_hash = true
  restaurants = db.execute("SELECT * FROM restaurant")
 # p restaurants
  slim(:"restaurants/index", locals:{restaurants:restaurants})
end 

get('/dishes/new')do 
  slim(:"dishes/new")
end

post('/dishes/new') do
  # p "PARAMS: #{params}"
  name = params[:name]
  type_of_food_id = params[:type_of_food_id].to_i
  where_id = params[:where_id].to_i
  db = SQLite3::Database.new("db/database.db")
  db.execute("INSERT INTO dishes (name,type_of_food_id,where_id) VALUES (?,?,?)",name, type_of_food_id,where_id)
  redirect('/')
end 
get('/dishes/:id/edit') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/chinook-crud.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM dishes WHERE id = ?",id).first
  slim(:"/dishes/edit",locals:{result:result})
end



get('/restaurant/:id') do
  restaurant_data = params[:id]
  session[:resturant_id]=params[:id]
  db = SQLite3::Database.new("db/database.db")
  db.results_as_hash = true
  restaurant = db.execute("SELECT * FROM restaurant WHERE id = ?",restaurant_data ).first
  type_of_food = db.execute("SELECT * FROM (type_of_food_restaurant_relation INNER JOIN type_of_food ON type_of_food_restaurant_relation.type_of_food_id = type_of_food.id) WHERE restaurant_id = ?",restaurant_data )
  p type_of_food
  slim(:"restaurant/index", locals:{type_of_food:type_of_food,restaurant_id:restaurant_data,restaurant:restaurant})
end

get("/restaurant/:resturant_id/type_of_food/:id") do
  restaurant_data = params[:resturant_id]
  p restaurant_data
  type_of_food_data = params[:id].to_i
  p type_of_food_data
  # p type_of_food_data
  db = SQLite3::Database.new("db/database.db")
  db.results_as_hash = true
  type_of_food_name = db.execute("SELECT * FROM type_of_food WHERE id = ?",type_of_food_data ).first
  # p type_of_food_name
  dishes = db.execute("SELECT dishes.name FROM dishes WHERE where_id = ? AND type_of_food_id = ?", restaurant_data, type_of_food_data )
  p dishes
  slim(:"type_of_food/index", locals:{dishes:dishes,type_of_food_name:type_of_food_name})
end