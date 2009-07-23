require 'rubygems'
require 'yaml'
require 'active_record'
require 'serialization_helper'

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
      yaml.sub!("--- \n", "")
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

    def self.each_table_page(table, records_per_page=1000)
      total_count = table_record_count(table)
      pages = (total_count.to_f / records_per_page).ceil - 1
      id = table_column_names(table).first
      boolean_columns = SerializationHelper::Utils.boolean_columns(table)
      quoted_table_name = SerializationHelper::Utils.quote_table(table)

      (0..pages).to_a.each do |page|
        sql = ActiveRecord::Base.connection.add_limit_offset!("SELECT * FROM #{quoted_table_name} ORDER BY #{id}",
                                                              :limit => records_per_page, :offset => records_per_page * page
        )
        records = ActiveRecord::Base.connection.select_all(sql)
        records = SerializationHelper::Utils.convert_booleans(records, boolean_columns)
        yield records
      end
    end

    def self.table_record_count(table)
      ActiveRecord::Base.connection.select_one("SELECT COUNT(*) FROM #{SerializationHelper::Utils.quote_table(table)}").values.first.to_i
    end
  end

  class Load < SerializationHelper::Load
    def self.load(io)
      ActiveRecord::Base.connection.transaction do
        YAML.load_documents(io) do |ydoc|
          ydoc.keys.each do |table_name|
            next if ydoc[table_name].nil?
            load_table(table_name, ydoc[table_name])
          end
        end
      end
    end

    def self.truncate_table(table)
      begin
        ActiveRecord::Base.connection.execute("TRUNCATE #{SerializationHelper::Utils.quote_table(table)}")
      rescue Exception
        ActiveRecord::Base.connection.execute("DELETE FROM #{SerializationHelper::Utils.quote_table(table)}")
      end
    end

    def self.load_table(table, data)
      column_names = data['columns']
      truncate_table(table)
      load_records(table, column_names, data['records'])
      reset_pk_sequence!(table)
    end

    def self.load_records(table, column_names, records)
      quoted_column_names = column_names.map { |column| ActiveRecord::Base.connection.quote_column_name(column) }.join(',')
      quoted_table_name = SerializationHelper::Utils.quote_table(table)
      records.each do |record|
        ActiveRecord::Base.connection.execute("INSERT INTO #{quoted_table_name} (#{quoted_column_names}) VALUES (#{record.map { |r| ActiveRecord::Base.connection.quote(r) }.join(',')})")
      end
    end

    def self.reset_pk_sequence!(table_name)
      if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
        ActiveRecord::Base.connection.reset_pk_sequence!(table_name)
      end
    end
  end

end