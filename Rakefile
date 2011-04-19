require 'rake'
require "rspec/core/rake_task"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "yaml_db"
    gem.summary = %Q{yaml_db allows export/import of database into/from yaml files}
    gem.description = %Q{
YamlDb is a database-independent format for dumping and restoring data.  It complements the the database-independent schema format found in db/schema.rb.  The data is saved into db/data.yml.
This can be used as a replacement for mysqldump or pg_dump, but only for the databases typically used by Rails apps.  Users, permissions, schemas, triggers, and other advanced database features are not supported - by design.
Any database that has an ActiveRecord adapter should work
}
    gem.email = "nate@ludicast.com"
    gem.homepage = "http://github.com/ludicast/yaml_db"
    gem.authors = ["Adam Wiggins","Orion Henry"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/*_spec.rb'
  spec.rspec_opts = ['--backtrace']
end

task :default => :spec

