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
end