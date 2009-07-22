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
			YamlDb.dump db_dump_data_file
		end

		desc "Dump contents of database to curr_dir_name/data.ym"
		task(:dump_dir => :environment) do
            time_dir = dump_dir "/#{Time.now.to_s}"
            Dir.mkdir time_dir
			YamlDb.dump "#{time_dir}/data.yml"
		end

		desc "Load contents of db/data.yml into database"
		task(:load => :environment) do
			YamlDb.load db_dump_data_file
		end
	end
end
