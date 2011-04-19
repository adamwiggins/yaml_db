require File.dirname(__FILE__) + '/base'

describe YamlDb::Dump do

	before do
		silence_warnings { ActiveRecord::Base = mock('ActiveRecord::Base', :null_object => true) }
		ActiveRecord::Base.stub(:connection).and_return(stub('connection').as_null_object)
		ActiveRecord::Base.connection.stub!(:tables).and_return([ 'mytable', 'schema_info', 'schema_migrations' ])
		ActiveRecord::Base.connection.stub!(:columns).with('mytable').and_return([ mock('a',:name => 'a', :type => :string), mock('b', :name => 'b', :type => :string) ])
		ActiveRecord::Base.connection.stub!(:select_one).and_return({"count"=>"2"})
		ActiveRecord::Base.connection.stub!(:select_all).and_return([ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ])
		YamlDb::Utils.stub!(:quote_table).with('mytable').and_return('mytable')
	end

	before(:each) do   
	  File.stub!(:new).with('dump.yml', 'w').and_return(StringIO.new)
	  @io = StringIO.new
	end

	it "should return a formatted string" do
		YamlDb::Dump.table_record_header(@io)
		@io.rewind
		@io.read.should == "  records: \n"
	end


	it "should return a yaml string that contains a table header and column names" do
		YamlDb::Dump.stub!(:table_column_names).with('mytable').and_return([ 'a', 'b' ])
		YamlDb::Dump.dump_table_columns(@io, 'mytable')
		@io.rewind
		@io.read.should == <<EOYAML

--- 
mytable: 
  columns: 
  - a
  - b
EOYAML
	end

	it "should return dump the records for a table in yaml to a given io stream" do
		YamlDb::Dump.dump_table_records(@io, 'mytable')
		@io.rewind
		@io.read.should == <<EOYAML
  records: 
  - - 1
    - 2
  - - 3
    - 4
EOYAML
	end



end
