require 'active_support/core_ext/kernel/reporting'

module YamlDb
  module SerializationHelper

    class Base
      attr_reader :extension

      def initialize(helper)
        @dumper    = helper.dumper
        @loader    = helper.loader
        @extension = helper.extension
      end

      def dump(filename)
        disable_logger
        File.open(filename, "w") do |file|
          @dumper.dump(file)
        end
        reenable_logger
      end

      def dump_to_dir(dirname)
        Dir.mkdir(dirname)
        tables = @dumper.tables
        tables.each do |table|
          File.open("#{dirname}/#{table}.#{@extension}", "w") do |io|
            @dumper.before_table(io, table)
            @dumper.dump_table io, table
            @dumper.after_table(io, table)
          end
        end
      end

      def load(filename, truncate = true)
        disable_logger
        @loader.load(File.new(filename, "r"), truncate)
        reenable_logger
      end

      def load_from_dir(dirname, truncate = true)
        Dir.entries(dirname).each do |filename|
          if filename =~ /^[.]/
            next
          end
          @loader.load(File.new("#{dirname}/#{filename}", "r"), truncate)
        end
      end

      def disable_logger
        @@old_logger = ActiveRecord::Base.logger
        ActiveRecord::Base.logger = nil
      end

      def reenable_logger
        ActiveRecord::Base.logger = @@old_logger
      end
    end

    class Load
      def self.load(io, truncate = true)
        ActiveRecord::Base.connection.transaction do
          load_documents(io, truncate)
        end
      end

      def self.truncate_table(table)
        begin
          ActiveRecord::Base.connection.execute("TRUNCATE #{Utils.quote_table(table)}")
        rescue Exception
          ActiveRecord::Base.connection.execute("DELETE FROM #{Utils.quote_table(table)}")
        end
      end

      def self.load_table(table, data, truncate = true)
        column_names = data['columns']
        if truncate
          truncate_table(table)
        end
        load_records(table, column_names, data['records'])
        reset_pk_sequence!(table)
      end

      def self.load_records(table, column_names, records)
        if column_names.nil?
          return
        end
        quoted_column_names = column_names.map { |column| ActiveRecord::Base.connection.quote_column_name(column) }.join(',')
        quoted_table_name = Utils.quote_table(table)
        records.each do |record|
          quoted_values = record.map{|c| ActiveRecord::Base.connection.quote(c)}.join(',')
          ActiveRecord::Base.connection.execute("INSERT INTO #{quoted_table_name} (#{quoted_column_names}) VALUES (#{quoted_values})")
        end
      end

      def self.reset_pk_sequence!(table_name)
        if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
          ActiveRecord::Base.connection.reset_pk_sequence!(table_name)
        end
      end

    end

    module Utils

      def self.unhash(hash, keys)
        keys.map { |key| hash[key] }
      end

      def self.unhash_records(records, keys)
        records.each_with_index do |record, index|
          records[index] = unhash(record, keys)
        end

        records
      end

      def self.convert_booleans(records, columns)
        records.each do |record|
          columns.each do |column|
            next if is_boolean(record[column])
            record[column] = convert_boolean(record[column])
          end
        end
        records
      end

      def self.convert_boolean(value)
        ['t', '1', true, 1].include?(value)
      end

      def self.boolean_columns(table)
        columns = ActiveRecord::Base.connection.columns(table).reject { |c| silence_warnings { c.type != :boolean } }
        columns.map { |c| c.name }
      end

      def self.is_boolean(value)
        value.kind_of?(TrueClass) or value.kind_of?(FalseClass)
      end

      def self.quote_table(table)
        ActiveRecord::Base.connection.quote_table_name(table)
      end

      def self.quote_column(column)
        ActiveRecord::Base.connection.quote_column_name(column)
      end
    end

    class Dump
      def self.before_table(io, table)

      end

      def self.dump(io)
        tables.each do |table|
          before_table(io, table)
          dump_table(io, table)
          after_table(io, table)
        end
      end

      def self.after_table(io, table)

      end

      def self.tables
        ActiveRecord::Base.connection.tables.reject { |table| ['schema_info', 'schema_migrations'].include?(table) }.sort
      end

      def self.dump_table(io, table)
        return if table_record_count(table).zero?

        dump_table_columns(io, table)
        dump_table_records(io, table)
      end

      def self.table_column_names(table)
        ActiveRecord::Base.connection.columns(table).map { |c| c.name }
      end


      def self.each_table_page(table, records_per_page=1000)
        total_count = table_record_count(table)
        pages = (total_count.to_f / records_per_page).ceil - 1
        keys = sort_keys(table)
        boolean_columns = Utils.boolean_columns(table)
        quoted_table_name = Utils.quote_table(table)

        (0..pages).to_a.each do |page|
          query = Arel::Table.new(table).order(*keys).skip(records_per_page*page).take(records_per_page).project(Arel.sql('*'))
          records = ActiveRecord::Base.connection.select_all(query.to_sql)
          records = Utils.convert_booleans(records, boolean_columns)
          yield records
        end
      end

      def self.table_record_count(table)
        ActiveRecord::Base.connection.select_one("SELECT COUNT(*) FROM #{Utils.quote_table(table)}").values.first.to_i
      end

      # Return the first column as sort key unless the table looks like a
      # standard has_and_belongs_to_many join table, in which case add the second "ID column"
      def self.sort_keys(table)
        first_column, second_column = table_column_names(table)

        if [first_column, second_column].all? { |name| name =~ /_id$/ }
          [Utils.quote_column(first_column), Utils.quote_column(second_column)]
        else
          [Utils.quote_column(first_column)]
        end
      end
    end
  end
end
