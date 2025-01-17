namespace :db do
  desc 'create database'
  task :create do
    sh 'sqlite3 db/zman.sqlite3 < db/schema.sql'
  end

  desc 'drop database'
  task :drop do
    sh 'rm db/zman.sqlite3'
  end

  desc 'seed database'
  task :seed do
    sh 'ruby -Ilib -rzman db/seed.rb'
  end
end
