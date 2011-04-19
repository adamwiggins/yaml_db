require File.dirname(__FILE__) + '/base'

describe SerializationHelper::Base do
  def prestub_active_record

  end

	before do
    @io = StringIO.new
  	silence_warnings { ActiveRecord::Base = mock('ActiveRecord::Base', :null_object => true) }
  	ActiveRecord::Base.stub(:connection).and_return(mock('connection'))
		ActiveRecord::Base.connection.stub!(:tables).and_return([ 'mytable', 'schema_info', 'schema_migrations' ])
  end

    def stub_helper!
        @helper = mock("MyHelper")
        @dumper = mock("MyDumper");
        @loader = mock("MyLoader");
        @helper.stub!(:dumper).and_return(@dumper)
        @helper.stub!(:loader).and_return(@loader)
        @helper.stub!(:extension).and_return("yml")
        @dumper.stub!(:tables).and_return([ActiveRecord::Base.connection.tables[0]])
        @dumper.stub!(:before_table).and_return(nil)
        @dumper.stub!(:after_table).and_return(nil)
    end

    context "for multi-file dumps" do
      before do
        File.should_receive(:new).once.with("dir_name/mytable.yml", "w").and_return(@io)
        Dir.should_receive(:mkdir).once.with("dir_name")
        stub_helper!
        @dumper.should_receive(:dump_table).once.with(@io, "mytable")
      end

      it "should create the number of files that there are tables" do
         SerializationHelper::Base.new(@helper).dump_to_dir "dir_name"
      end   

    end

    context "for multi-file loads" do

      before do
        stub_helper!
        @loader.should_receive(:load).once.with(@io, true)
        File.should_receive(:new).once.with("dir_name/mytable.yml", "r").and_return(@io)
        Dir.stub!(:entries).and_return(["mytable.yml"])
      end

      it "should insert into then umber of tables that there are files" do
        SerializationHelper::Base.new(@helper).load_from_dir "dir_name"        
      end

    end

end
