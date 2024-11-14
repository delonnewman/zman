namespace :db do
  desc 'create database'
  task :create do
    sh 'sqlite3 -init db/schema.sql db/zman.sqlite3'
  end
end
