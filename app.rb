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

=begin
get('/dishes/new')do 
  slim(:"dishes/new")
end


post('/dishes/new') do
  title = params[:name]
  type_of_food_id = params[:type_of_food_id].to_i
  where_id = params[:where_id].to_i
  p "Vi fick in datan #{name} och #{type_of_food_id} och #{where_id}"
  db = SQLite3::Database.new("db/database.db")
  db.execute("INSERT INTO dishes (name,type_of_food_id,where_id) VALUES (?,?,?)",name, type_of_food_id,where_id)
  redirect('/')
end 
=end
get('/restaurant/:id') do
  restaurant_data = params[:id]
  restaurant_name = params[:name]
  db = SQLite3::Database.new("db/database.db")
  db.results_as_hash = true
  type_of_food = db.execute("SELECT type_of_food.name FROM (type_of_food_restaurant_relation INNER JOIN type_of_food ON type_of_food_restaurant_relation.type_of_food_id = type_of_food.id) WHERE restaurant_id = ?",restaurant_data )
  slim(:"restaurant/index", locals:{type_of_food:type_of_food})
end

