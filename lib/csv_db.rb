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

  end

  class Dump < SerializationHelper::Dump

    def self.before_table(io,table)
      io.write "#{table}:"
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