class SerializationHelper
  attr_reader :extension

  def initialize(helper)
    @dumper = helper.dumper
    @loader = helper.loader
    @extension = helper.extension
  end

  def dump(filename)
    disable_logger
    @dumper.dump(File.new(filename, "w"))
    reenable_logger
  end

  def dump_to_dir(dirname)
    Dir.mkdir(dirname)
    tables = @dumper.tables
    tables.each do |table|
      file = File.new "#{dirname}/#{table}.#{@extension}", "w"
      @dumper.dump_table file, table
    end
  end

  def load(filename)
    disable_logger
    @loader.load(File.new(filename, "r"))
    reenable_logger
  end

  def disable_logger
    @@old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
  end

  def reenable_logger
    ActiveRecord::Base.logger = @@old_logger
  end

  class Load
    
  end

  class Dump
    def self.dump(io)
      tables.each do |table|
        dump_table(io, table)
      end
    end

    def self.tables
      ActiveRecord::Base.connection.tables.reject { |table| ['schema_info', 'schema_migrations'].include?(table) }
    end

    def self.dump_table(io, table)
      return if table_record_count(table).zero?

      dump_table_columns(io, table)
      dump_table_records(io, table)
    end

    def self.table_column_names(table)
      ActiveRecord::Base.connection.columns(table).map { |c| c.name }
    end

  end

end