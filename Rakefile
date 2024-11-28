namespace :db do
  desc 'create database'
  task :create do
    sh 'sqlite3 db/zman.sqlite3 < db/schema.sql'
  end
end
