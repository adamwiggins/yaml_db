require File.dirname(__FILE__) + '/base'

describe SerializationHelper do

	before do
		ActiveRecord::Base = mock('ActiveRecord::Base', :null_object => true)
		ActiveRecord::Base.connection = mock('connection')
		ActiveRecord::Base.connection.stub!(:tables).and_return([ 'mytable', 'schema_info', 'schema_migrations' ])
    end

    def stub_helper!
        @helper = mock("MyHelper")
        @helper.stub!(:dumper).and_return(@dumper)
        @helper.stub!(:loader)
        @helper.stub!(:extension).and_return("yml")
        @dumper.stub!(:tables).and_return([ActiveRecord::Base.connection.tables[0]])
    end

    context "for multi-file dumps" do
      before do
        @io = StringIO.new
        File.should_receive(:new).once.with("dir_name/mytable.yml", "w").and_return(@io)
        Dir.should_receive(:mkdir).once.with("dir_name")
        stub_helper!
        @dumper.should_receive(:dump_table).once.with(@io, "mytable")
      end

      it "should create the number of files that there are tables" do
         SerializationHelper.new(@helper).dump_to_dir "dir_name"
      end

    end

    context "for multi-file loads" do
      before do
        
      end


    end

end
