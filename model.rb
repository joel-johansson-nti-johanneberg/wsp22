module Model
    # Attempts to open a new database connection
    # @return [Array] containing all the data from the database
    def connect_to_db()
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true
        return db
    end
     #Attempts to select all restaurants
    # @return [Array] containing all the restaurants from the database
    # @see Model#connect_to_db
    def restaurants_data()
        db = connect_to_db()
        restaurants = db.execute("SELECT * FROM restaurant")
        return restaurants
    end 
     # Attempts to check if user can login
     # @see Model#connect_to_db
    def login_post(username, password)
        db = connect_to_db()
        result = db.execute("SELECT * FROM user WHERE username = ?",username).first
        if result == nil
        redirect("https://www.youtube.com/watch?v=D-NJOoLlNC4")
        end
        pwdigest = result["pwdigest"]
        id = result["id"]
        auth = result["authorization"]
        
        if BCrypt::Password.new(pwdigest) == password
            return {id:id, auth:true, status:true}
        else
            return {status:false}
        end
    end
    # Attempts to check if restaurant exist
    # @param [Hash] exist, id for selected restaurant
    # @see Model#connect_to_db
    def restaurant_exist(id) 
        db = connect_to_db()
        exist = db.execute("SELECT id FROM restaurant WHERE id = ?",id).first
        if exist == nil
            return false
        else id = id.to_i
            return exist["id"] == id
        end 
    end 
    # Attempts to check if too many inputs are recieved in close proximity
    # @param [String] latestTime, the latest logged time
    # @return [Boolean] whether the inputs are recieved in close proximity
    # @see Model#connect_to_db
    def timeChecker(latestTime)
        timeDiff = Time.now.to_i - latestTime
        return timeDiff > 1.5
    end
    # Attempts to register user
    # @param [String] password, the password input
    # @param [String] username, the user username
    # @return [Boolean] whether the user registration succeeds 
    # @see Model#connect_to_db
    def user_new_post( username,password,password_confirm) 
        if (password == password_confirm && username.length <= 12 && (isEmpty(username) == false) && (isEmpty(password)== false ))
        password_digest = BCrypt::Password.create(password)
        authorization = 1
        db = connect_to_db()
        db.execute("INSERT INTO user (username,pwdigest,authorization) VALUES (?,?,?)",username,password_digest,authorization)
        result = db.execute("SELECT * FROM user WHERE username = ?",username).first
        id = result["id"]
        return {id:id, auth:true, status:true}
        else 
        return {status:false}
        end
    end
    # Attempts to delete a dish
    # @param [Integer] id, the dish ID
    # @see Model#connect_to_db
    def dish_delete_post(id,sessionid)
        db = connect_to_db()
        result = db.execute("SELECT * FROM dishes WHERE id = ?",id).first
        if sessionid == result['eaten_by']
            db.execute("DELETE FROM dishes WHERE id = ?",id)
            return {status:true}
        elsif sessionid == 1
            db.execute("DELETE FROM dishes WHERE id = ?",id)
            return {status:true}
        else 
            return {status:false} 
        end 
    end
    # Attempts to se if text is empty
    def isEmpty(text)
        if text == nil
            return true
        elsif text == ""
            return true
        else
            return false
        end
    end
    # Attempts to creat new dish
    # @param [Integer] eaten by, the users ID
    # @see Model#connect_to_db
    def dish_new_post(name,type_of_food_id,where_id,sessionid)
        db = connect_to_db()
        if not isEmpty(name)
            eaten_by = sessionid 
            type_of_food_list = db.execute("SELECT id FROM (type_of_food_restaurant_relation INNER JOIN type_of_food ON type_of_food_restaurant_relation.type_of_food_id = type_of_food.id) WHERE restaurant_id = ?",where_id )
            type_of_food_list = type_of_food_list.map { |item| item["id"]}
            if type_of_food_list.include?(type_of_food_id) 
                db.execute("INSERT INTO dishes (name,type_of_food_id,where_id,eaten_by) VALUES (?,?,?,?)",name, type_of_food_id,where_id,eaten_by)
                return {status:true}
            else 
                return {status:false}
            end 
        else 
            return {empty:true}
        end
    end 
    # Attempts to update dish information
    # @param [Hash] result , all information abaut the dish
    # @param [Integer] eaten by, the users ID
    # @see Model#connect_to_db
    def dish_edit_post(id,name,where_id,type_of_food_id,sessionid)
        db = connect_to_db()
        result = db.execute("SELECT * FROM dishes WHERE id = ?",id).first
        if sessionid == result['eaten_by']
            if not isEmpty(name)
                eaten_by = sessionid
                type_of_food_list = db.execute("SELECT id FROM (type_of_food_restaurant_relation INNER JOIN type_of_food ON type_of_food_restaurant_relation.type_of_food_id = type_of_food.id) WHERE restaurant_id = ?",where_id )
                type_of_food_list = type_of_food_list.map { |item| item["id"]}
                if type_of_food_list.include?(type_of_food_id) 
                    db.execute("UPDATE dishes SET name=? WHERE id = ?",name,id)
                    db.execute("UPDATE dishes SET where_id=? WHERE id = ?",where_id,id)
                    db.execute("UPDATE dishes SET type_of_food_id=? WHERE id = ?",type_of_food_id,id)
                    return {status:true, auth:true}
                else 
                    return {status:false}
                end
            else 
                return {empty:true}
            end 
        elsif sessionid == 1
            if not isEmpty(name)
                db.execute("UPDATE dishes SET name=? WHERE id = ?",name,id)
                db.execute("UPDATE dishes SET where_id=? WHERE id = ?",where_id,id)
                db.execute("UPDATE dishes SET type_of_food_id=? WHERE id = ?",type_of_food_id,id)
                return {status:true, auth:true}
            else 
                return {empty:true}
            end 
        else 
            return {auth:false}
        end 
    end
    # Attempts to update restaurant information
    # @see Model#connect_to_db
    def restaurant_edit_post(id,name,where_id,link, sessionid) 
        db = connect_to_db()
        if sessionid == 1
            db.execute("UPDATE restaurant SET name=? WHERE id = ?",name,id)
            db.execute("UPDATE restaurant SET link=? WHERE id = ?",link,id)
            return {status:true}
        else 
            return {status:false}
        end 
    end
    # Attempts to create a list of all restaurants
    # @see Model#connect_to_db
    def restaurants_get()
        db = connect_to_db()
        db.execute("SELECT * FROM restaurant")
    end 
    # Attempts to create a list eaten dishes by user
    # @see Model#connect_to_db
    def eaten_dishes_show_get(person)
        db = connect_to_db()
        result = db.execute("SELECT * FROM dishes WHERE eaten_by = ?",person)
        return result
    end
    # Attempts show form to edit dish
    # @see Model#connect_to_db
    def dish_edit_get(id,sessionid)
        db = connect_to_db()
        result = db.execute("SELECT * FROM dishes WHERE id = ?",id).first
        if sessionid == result['eaten_by']
            return {status:true, result:result}
        elsif sessionid == 1
            return {status:true, result:result}
        else 
            return {status:false}
        end 
    end
    # Attempts show form to edit restaurant
    # @see Model#connect_to_db
    def restaurant_edit_get(id,sessionid)
        if sessionid == 1
            db = connect_to_db()
            result = db.execute("SELECT * FROM restaurant WHERE id = ?",id).first
            return {status:true, result:result}
        else 
            return {status:false}
        end
    end
    # Attempts delete restaurant
    # @see Model#connect_to_db
    def restaurant_delete_post(id,sessionid)
        if sessionid == 1
            db = connect_to_db()
            db.execute("DELETE FROM restaurant WHERE id = ?",id)
            db.execute("DELETE FROM type_of_food_restaurant_relation WHERE restaurant_id = ?",id)
            return {status:true}
        else 
            return {status:false}
        end   
    end 
    # Attempts show list of all types of food at the selected restaurant
    # @see Model#connect_to_db
    def resturant_id_get(restaurant_data) 
        db = connect_to_db()
        restaurant = db.execute("SELECT * FROM restaurant WHERE id = ?",restaurant_data ).first
        type_of_food = db.execute("SELECT * FROM (type_of_food_restaurant_relation INNER JOIN type_of_food ON type_of_food_restaurant_relation.type_of_food_id = type_of_food.id) WHERE restaurant_id = ?",restaurant_data )
        return {restaurant:restaurant, type_of_food:type_of_food}
    end
    # Attempts show list all dishes ät the selected types of food at the selected restaurant
    # @see Model#connect_to_db
    def restaurant_resturant_id_type_of_food_id_get(restaurant_data,type_of_food_data)
        db = connect_to_db()
        type_of_food_name = db.execute("SELECT * FROM type_of_food WHERE id = ?",type_of_food_data ).first
        dishes = db.execute("SELECT * FROM dishes WHERE where_id = ? AND type_of_food_id = ?", restaurant_data, type_of_food_data)
        return {type_of_food_name:type_of_food_name, dishes:dishes}
    end
end 