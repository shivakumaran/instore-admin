#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

InstoreAdmin::Application.load_tasks

require "cucumber/rake/task"
Cucumber::Rake::Task.new(:run) do |task|  
  #task.cucumber_opts = ["features"]
  task.cucumber_opts = ["-t", "@compile"  ,"@#{ENV["TAG"] || "all" }","features"]
end