require 'rubygems'
require 'yaml'
require 'active_record'
require 'serialization_helper'
require 'active_support/core_ext/kernel/reporting'
require 'rails/railtie'

module YamlDb
  module Helper
    def self.loader
      YamlDb::Load
    end

    def self.dumper
      YamlDb::Dump
    end

    def self.extension
      "yml"
    end
  end


  module Utils
    def self.chunk_records(records)
      yaml = [ records ].to_yaml
      yaml.sub!(/---\s\n|---\n/, '')
      yaml.sub!('- - -', '  - -')
      yaml
    end

  end

  class Dump < SerializationHelper::Dump

    def self.dump_table_columns(io, table)
      io.write("\n")
      io.write({ table => { 'columns' => table_column_names(table) } }.to_yaml)
    end

    def self.dump_table_records(io, table)
      table_record_header(io)

      column_names = table_column_names(table)

      each_table_page(table) do |records|
        rows = SerializationHelper::Utils.unhash_records(records, column_names)
        io.write(YamlDb::Utils.chunk_records(records))
      end
    end

    def self.table_record_header(io)
      io.write("  records: \n")
    end

  end

  class Load < SerializationHelper::Load
    def self.load_documents(io, truncate = true)
        YAML.load_documents(io) do |ydoc|
          ydoc.keys.each do |table_name|
            next if ydoc[table_name].nil?
            load_table(table_name, ydoc[table_name], truncate)
          end
        end
    end
  end

  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path('../tasks/yaml_db_tasks.rake',
__FILE__)
    end
  end

end
