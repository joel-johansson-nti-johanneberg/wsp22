module Model

    def connect_to_db()
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true
        return db
    end
    def restaurants_data()
        db = connect_to_db()
        restaurants = db.execute("SELECT * FROM restaurant")
        return restaurants
    end 
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
        session[:id] = id
        session[:auth] = true
        redirect('/')
        else
        session[:auth] = false
        redirect("https://www.youtube.com/watch?v=D-NJOoLlNC4")
        end
    end
    def dish_exist(id) 
        db = connect_to_db()
        exist = db.execute("SELECT id FROM dishes WHERE id = ?",id).first
        return exist == id
    end 
    def timeChecker(latestTime)
        timeDiff = Time.now.to_i - latestTime
        return timeDiff > 1.5
    end
    def user_new_post( username,password,password_confirm) 
        if (password == password_confirm && username.length <= 12 && (isEmpty(username) == false) && (isEmpty(password)== false ))
        password_digest = BCrypt::Password.create(password)
        authorization = 1
        db = connect_to_db()
        db.execute("INSERT INTO user (username,pwdigest,authorization) VALUES (?,?,?)",username,password_digest,authorization)
        session[:auth] = true
        redirect('/')
        else 
        session[:auth] = false
        "Användarnamnet är för långt/Lösenorden matchade inte/tomma fält"
        end
    end

    def dish_delete_post(id)
        db = connect_to_db()
        result = db.execute("SELECT * FROM dishes WHERE id = ?",id).first
        if session[:id] == result['eaten_by']
            db.execute("DELETE FROM dishes WHERE id = ?",id)
            redirect('/restaurants')
        elsif session[:id] == 1
            db.execute("DELETE FROM dishes WHERE id = ?",id)
            redirect('/restaurants')
        else 
            redirect('/error_authorization')  
        end 
    end

    def isEmpty(text)
        if text == nil
            return true
        elsif text == ""
            return true
        else
            return false
        end
    end

    def dish_new_post(name,type_of_food_id,where_id)
        db = connect_to_db()
        if not isEmpty(name)
            eaten_by = session[:id] 
            type_of_food_list = db.execute("SELECT id FROM (type_of_food_restaurant_relation INNER JOIN type_of_food ON type_of_food_restaurant_relation.type_of_food_id = type_of_food.id) WHERE restaurant_id = ?",where_id )
            type_of_food_list = type_of_food_list.map { |item| item["id"]}
            if type_of_food_list.include?(type_of_food_id) 
                db.execute("INSERT INTO dishes (name,type_of_food_id,where_id,eaten_by) VALUES (?,?,?,?)",name, type_of_food_id,where_id,eaten_by)
                redirect('/')
            else 
                redirect('/error_restaurang_relation')
            end 
        else 
            redirect('/error_empty')
        end
    end 

    def dish_edit_post(id,name,where_id,type_of_food_id)
        db = connect_to_db()
        result = db.execute("SELECT * FROM dishes WHERE id = ?",id).first
        if session[:id] == result['eaten_by']
            if not isEmpty(name)
                eaten_by = session[:id] 
                type_of_food_list = db.execute("SELECT id FROM (type_of_food_restaurant_relation INNER JOIN type_of_food ON type_of_food_restaurant_relation.type_of_food_id = type_of_food.id) WHERE restaurant_id = ?",where_id )
                type_of_food_list = type_of_food_list.map { |item| item["id"]}
                if type_of_food_list.include?(type_of_food_id) 
                    db.execute("UPDATE dishes SET name=? WHERE id = ?",name,id)
                    db.execute("UPDATE dishes SET where_id=? WHERE id = ?",where_id,id)
                    db.execute("UPDATE dishes SET type_of_food_id=? WHERE id = ?",type_of_food_id,id)
                    redirect('/')
                else 
                    redirect('/error_restaurang_relation')
                end
            else 
                redirect('/error_empty')
            end 
        elsif session[:id] == 1
            if not isEmpty(name)
                db.execute("UPDATE dishes SET name=? WHERE id = ?",name,id)
                db.execute("UPDATE dishes SET where_id=? WHERE id = ?",where_id,id)
                db.execute("UPDATE dishes SET type_of_food_id=? WHERE id = ?",type_of_food_id,id)
                redirect('/')
            else 
                redirect('/error_empty')
            end 
        else 
            redirect('/error_authorization')  
        end 
    end

    def restaurant_edit_post(id,name,where_id,link) 
        db = connect_to_db()
        if session[:id] == 1
            db.execute("UPDATE restaurant SET name=? WHERE id = ?",name,id)
            db.execute("UPDATE restaurant SET link=? WHERE id = ?",link,id)
        else 
            redirect('/error_authorization')  
        end 
    end

    def restaurants_get()
        db = connect_to_db()
        restaurants = db.execute("SELECT * FROM restaurant")
        slim(:"restaurants/index", locals:{restaurants:restaurants})
    end 

    def eaten_dishes_show_get(person)
        db = connect_to_db()
        result = db.execute("SELECT * FROM dishes WHERE eaten_by = ?",person)
        p result
        return result
    end

    def dish_edit_get(id)
        db = connect_to_db()
        result = db.execute("SELECT * FROM dishes WHERE id = ?",id).first
        if session[:id] == result['eaten_by']
            slim(:"/dishes/edit",locals:{result:result})
        elsif session[:id] == 1
            slim(:"/dishes/edit",locals:{result:result})
        else 
            redirect('/error_authorization')  
        end 
    end

    def restaurant_edit_get(id)
        if session[:id] == 1
            db = connect_to_db()
            result = db.execute("SELECT * FROM restaurant WHERE id = ?",id).first
            slim(:"/restaurants/edit",locals:{result:result})
        else 
            redirect('/error_authorization') 
        end
    end

    def restaurant_delete_post(id)
        if session[:id] == 1
            db = connect_to_db()
            db.execute("DELETE FROM restaurant WHERE id = ?",id)
            db.execute("DELETE FROM type_of_food_restaurant_relation WHERE restaurant_id = ?",id)
            redirect('/restaurants')
        else 
            redirect('/error_authorization')  
        end   
    end 

    def resturant_id_get(restaurant_data) 
        session[:resturant_id]=params[:id]
        db = connect_to_db()
        restaurant = db.execute("SELECT * FROM restaurant WHERE id = ?",restaurant_data ).first
        type_of_food = db.execute("SELECT * FROM (type_of_food_restaurant_relation INNER JOIN type_of_food ON type_of_food_restaurant_relation.type_of_food_id = type_of_food.id) WHERE restaurant_id = ?",restaurant_data )
        slim(:"restaurant/index", locals:{type_of_food:type_of_food,restaurant_id:restaurant_data,restaurant:restaurant})
    end

    def restaurant_resturant_id_type_of_food_id_get(restaurant_data,type_of_food_data)
        db = connect_to_db()
        type_of_food_name = db.execute("SELECT * FROM type_of_food WHERE id = ?",type_of_food_data ).first
        dishes = db.execute("SELECT * FROM dishes WHERE where_id = ? AND type_of_food_id = ?", restaurant_data, type_of_food_data)
        p dishes
        slim(:"type_of_food/index", locals:{dishes:dishes,type_of_food_name:type_of_food_name})
    end
end 