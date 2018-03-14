module YamlDb
  module RakeTasks
    def self.data_dump_task filename=nil
      SerializationHelper::Base.new(helper).dump(db_dump_data_file(helper.extension, filename))
    end

    def self.data_dump_dir_task
      dir = ENV['dir'] || default_dir_name
      SerializationHelper::Base.new(helper).dump_to_dir(dump_dir("/#{dir}"))
    end

    def self.data_load_task filename=nil
      SerializationHelper::Base.new(helper).load(db_dump_data_file(helper.extension, filename))
    end

    def self.data_load_dir_task
      dir = ENV['dir'] || 'base'
      SerializationHelper::Base.new(helper).load_from_dir(dump_dir("/#{dir}"))
    end

    def self.default_filename
      'data'
    end

    private

    def self.default_dir_name
      Time.now.strftime('%FT%H%M%S')
    end

    def self.db_dump_data_file(extension = 'yml', filename=nil)
      filename = check_filename(filename)
      "#{dump_dir}/#{filename}.#{extension}"
    end

    def self.check_filename filename=nil
      if filename == nil
        p "using default filename #{default_filename}"
        default_filename
      else
        p "using #{filename}"
        filename
      end
    end

    def self.dump_dir(dir = '')
      "#{Rails.root}/db#{dir}"
    end

    def self.helper
      format_class = ENV['class'] || 'YamlDb::Helper'
      format_class.constantize
    end
  end
end
