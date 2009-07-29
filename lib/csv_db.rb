#require 'FasterCSV'
module CsvDb
  module Helper
    def self.loader
      Load
    end

    def self.dumper
      Dump
    end

    def self.extension
      "csv"
    end
  end

  class Load < SerializationHelper::Load
    def self.load_documents(io, truncate = true)
      tables = {}
      curr_table = nil
      io.each do |line|
        if /BEGIN_CSV_TABLE_DECLARATION(.+)END_CSV_TABLE_DECLARATION/ =~ line
          curr_table = $1
          tables[curr_table] = {}
        else
          if tables[curr_table]["columns"]
            tables[curr_table]["records"] << FasterCSV.parse(line)[0]
          else
            tables[curr_table]["columns"] = FasterCSV.parse(line)[0]
            tables[curr_table]["records"] = []
          end
        end
      end

      tables.each_pair do |table_name, contents|
        load_table(table_name, contents, truncate)
      end
    end
  end

  class Dump < SerializationHelper::Dump

    def self.before_table(io,table)
      io.write "BEGIN_CSV_TABLE_DECLARATION#{table}END_CSV_TABLE_DECLARATION\n"
    end

    def self.dump(io)
      tables.each do |table|
        before_table(io, table)
        dump_table(io, table)
        after_table(io, table)
      end
    end

    def self.after_table(io,table)
      io.write ""
    end

    def self.dump_table_columns(io, table)
      io.write(table_column_names(table).to_csv)
    end

    def self.dump_table_records(io, table)

      column_names = table_column_names(table)

      each_table_page(table) do |records|
        rows = SerializationHelper::Utils.unhash_records(records, column_names)
        records.each do |record|
          io.write(record.to_csv)
        end
      end
    end
    
  end


end