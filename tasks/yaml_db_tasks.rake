namespace :db do
	desc "Dump schema and data to db/schema.rb and db/data.yml"
	task(:dump => [ "db:schema:dump", "db:data:dump" ])

	desc "Load schema and data from db/schema.rb and db/data.yml"
	task(:load => [ "db:schema:load", "db:data:load" ])

	namespace :data do
		def db_dump_data_file
			"#{dump_dir}/data.yml"
        end
            
        def dump_dir(dir = "")
          "#{RAILS_ROOT}/db#{dir}"
        end

		desc "Dump contents of database to db/data.yml"
		task(:dump => :environment) do
			SerializationHelper.new(YamlDb::SerializationHelper).dump db_dump_data_file
		end

		desc "Dump contents of database to curr_dir_name/data.ym"
		task(:dump_dir => :environment) do
            time_dir = dump_dir "/#{Time.now.to_s.gsub(/ /, '_')}"
            SerializationHelper.new(YamlDb::SerializationHelper).dump_to_dir time_dir
		end

		desc "Load contents of db/data.yml into database"
		task(:load => :environment) do
			SerializationHelper.new(YamlDb::SerializationHelper).load db_dump_data_file
		end
	end
end
