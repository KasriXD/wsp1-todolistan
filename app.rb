require 'debug'
require "awesome_print"

class App < Sinatra::Base
  register Sinatra::Reloader

  def db
    return @db if @db

    @db = SQLite3::Database.new(DB_PATH)
    @db.results_as_hash = true
    @db
  end

  helpers do
    def categories
      db.execute('SELECT * FROM categories ORDER BY name')
    end

    def todos(category_id = nil)
      sql = 'SELECT todos.*, categories.name AS category_name FROM todos LEFT JOIN categories ON todos.category_id = categories.id'
      if category_id
        db.execute(sql + ' WHERE todos.category_id = ? ORDER BY todos.id DESC', [category_id])
      else
        db.execute(sql + ' ORDER BY todos.id DESC')
      end
    end
  end

  get '/' do
    @categories = categories
    @todos = todos
    erb :'todos/index'
  end

  get '/categories' do
    @categories = categories
    @todos = todos
    erb :'todos/index'
  end

  post '/todos' do
    name = params[:name].to_s.strip
    description = params[:description].to_s.strip
    category_id = params[:category_id].to_i
    if !name.empty?
      db.execute(
        'INSERT INTO todos (name, description, status, category_id) VALUES (?, ?, 0, ?)',
        [name, description, category_id.zero? ? nil : category_id]
      )
    end
    redirect '/'
  end

  post '/todos/:id/toggle' do
    db.execute('UPDATE todos SET status = CASE WHEN status = 1 THEN 0 ELSE 1 END WHERE id = ?', [params[:id]])
    redirect '/'
  end

  post '/todos/:id/delete' do
    db.execute('DELETE FROM todos WHERE id = ?', [params[:id]])
    redirect '/'
  end

  post '/todos/:id/update' do
    name = params[:name].to_s.strip
    description = params[:description].to_s.strip
    category_id = params[:category_id].to_i
    unless name.empty?
      db.execute(
        'UPDATE todos SET name = ?, description = ?, category_id = ? WHERE id = ?',
        [name, description, category_id.zero? ? nil : category_id, params[:id]]
      )
    end
    redirect '/'
  end

  post '/categories' do
    name = params[:name].to_s.strip
    db.execute('INSERT INTO categories (name) VALUES (?)', [name]) unless name.empty?
    redirect '/categories'
  end

  post '/categories/:id/delete' do
    db.execute('UPDATE todos SET category_id = NULL WHERE category_id = ?', [params[:id]])
    db.execute('DELETE FROM categories WHERE id = ?', [params[:id]])
    redirect '/categories'
  end
end
