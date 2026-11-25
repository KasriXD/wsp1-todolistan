require 'sqlite3'
require_relative '../config'

db = SQLite3::Database.new(DB_PATH)
db.execute('PRAGMA foreign_keys = ON')

puts "Använder databasen: #{DB_PATH}"
puts "🧹 Tar bort gamla tabeller..."
db.execute('DROP TABLE IF EXISTS todos')
db.execute('DROP TABLE IF EXISTS categories')

puts "🧱 Skapar tabeller..."
db.execute('CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL
)')

db.execute('CREATE TABLE todos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  status INTEGER DEFAULT 0,
  category_id INTEGER,
  FOREIGN KEY (category_id) REFERENCES categories(id)
)')

puts "🍎 Fyller på med data..."
db.execute('INSERT INTO categories (name) VALUES (?)', ['Privat'])
db.execute('INSERT INTO categories (name) VALUES (?)', ['Skola'])
db.execute('INSERT INTO categories (name) VALUES (?)', ['Jobb'])

db.execute('INSERT INTO todos (name, description, status, category_id) VALUES (?, ?, ?, ?)',
           ['Laga pannkakor', '2 1/2 dl vetemjöl - 1/2 tsk salt - 6 dl mjölk - 3 ägg', 0, 1])
db.execute('INSERT INTO todos (name, description, status, category_id) VALUES (?, ?, ?, ?)',
           ['Smör', 'Inte margarin\nKöp', 0, 2])
db.execute('INSERT INTO todos (name, description, status, category_id) VALUES (?, ?, ?, ?)',
           ['Ägg', 'Ett tjog\nKöp', 1, 1])
db.execute('INSERT INTO todos (name, description, status, category_id) VALUES (?, ?, ?, ?)',
           ['Mjöl', 'Fyra kg\nKöp', 1, 1])

puts "✅ Databasen är seedad!"
