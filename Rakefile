#!/usr/bin/env rake
require 'rspec/core/rake_task'
require 'sqlite3'
require 'active_record'
require 'yaml'
require 'active_support/all'

#VARIABLES
$migration_path = 'db/migrate'

#DEFAULT
task :default => :spec

#RSPEC
RSpec::Core::RakeTask.new(:spec)

#ACTIVE_RECORD
include ActiveRecord::Tasks

DatabaseTasks.env = 'linael'
DatabaseTasks.db_dir = 'db'
DatabaseTasks.migrations_paths = $migration_path
DatabaseTasks.database_configuration = YAML::load(File.open('config/database.yml'))

task :environment do
  ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
  ActiveRecord::Base.establish_connection DatabaseTasks.env
end

load 'active_record/railties/databases.rake'

#GENERATOR
namespace :g do
  
  def get_next_number
    sprintf '%03d', (FileList["#{$migration_path}/*.rb"].count + 1)

  end

  def create_migration name    
    file_path = "#{$migration_path}/#{get_next_number}_#{name.underscore}.rb"    
    touch file_path
    file_path
  end

  def pre_writte_migration name,file_path
    file = open(file_path,"w")
    file.write("class #{name.camelize} < ActiveRecord::Migration\n")
    file.write("  def up\n")
    file.write("  end\n\n")
    file.write("  def down\n")
    file.write("  end\n")
    file.write("end\n")
    file.close
    print "writing #{file_path}\n"
  end

  def check_name args
    raise Exception, "Aborting: No migration name specified!\n" unless args[:migration_name]
  end

  def check_presence name
    raise Exception, "Aborting: A migration with this name already exist!\n" if FileList["#{$migration_path}/*.rb"].any? {|f| f =~ /\d*_#{name.underscore}.rb/}
  end

  def check args
    begin
      check_name args
      check_presence args[:migration_name]
    rescue Exception => e
      print e.message
      exit
    end
  end

  desc 'create a new migration (need a name)'
  task :migration,:migration_name do |t,args|
    check args
    path = create_migration(args[:migration_name])
    pre_writte_migration(args[:migration_name],path)
  end

  

end
