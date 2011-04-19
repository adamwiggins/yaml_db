require File.dirname(__FILE__) + '/base'

describe SerializationHelper::Load do
	before do
		SerializationHelper::Utils.stub!(:quote_table).with('mytable').and_return('mytable')

		silence_warnings { ActiveRecord::Base = mock('ActiveRecord::Base', :null_object => true) }
		ActiveRecord::Base.stub(:connection).and_return(stub('connection').as_null_object)
		ActiveRecord::Base.connection.stub!(:transaction).and_yield
		@io = StringIO.new
	end

  	it "should truncate the table" do
		ActiveRecord::Base.connection.stub!(:execute).with("TRUNCATE mytable").and_return(true)
		ActiveRecord::Base.connection.should_not_receive(:execute).with("DELETE FROM mytable")
		SerializationHelper::Load.truncate_table('mytable')
	end

	it "should delete the table if truncate throws an exception" do
		ActiveRecord::Base.connection.should_receive(:execute).with("TRUNCATE mytable").and_raise()
		ActiveRecord::Base.connection.should_receive(:execute).with("DELETE FROM mytable").and_return(true)
		SerializationHelper::Load.truncate_table('mytable')
	end


	it "should call reset pk sequence if the connection adapter is postgres" do
		ActiveRecord::Base.connection.should_receive(:respond_to?).with(:reset_pk_sequence!).and_return(true)
		ActiveRecord::Base.connection.should_receive(:reset_pk_sequence!).with('mytable')
		SerializationHelper::Load.reset_pk_sequence!('mytable')
	end

	it "should not call reset pk sequence for other adapters" do
		ActiveRecord::Base.connection.should_receive(:respond_to?).with(:reset_pk_sequence!).and_return(false)
		ActiveRecord::Base.connection.should_not_receive(:reset_pk_sequence!)
		SerializationHelper::Load.reset_pk_sequence!('mytable')
	end

    it "should insert records into a table" do
        mca = mock('a',:name => 'a')
        mcb = mock('b', :name => 'b')
        ActiveRecord::Base.connection.stub!(:columns).with('mytable').and_return([mca , mcb ])
        ActiveRecord::Base.connection.stub!(:quote_column_name).with('a').and_return('a')
        ActiveRecord::Base.connection.stub!(:quote_column_name).with('b').and_return('b')
        ActiveRecord::Base.connection.stub!(:quote).with(1, mca).and_return("'1'")
        ActiveRecord::Base.connection.stub!(:quote).with(2, mcb).and_return("'2'")
        ActiveRecord::Base.connection.stub!(:quote).with(3, mca).and_return("'3'")
        ActiveRecord::Base.connection.stub!(:quote).with(4, mcb).and_return("'4'")
        ActiveRecord::Base.connection.should_receive(:execute).with("INSERT INTO mytable (a,b) VALUES ('1','2')")
        ActiveRecord::Base.connection.should_receive(:execute).with("INSERT INTO mytable (a,b) VALUES ('3','4')")

        SerializationHelper::Load.load_records('mytable', ['a', 'b'], [[1, 2], [3, 4]])
    end

    it "should quote column names that correspond to sql keywords" do
        mca = mock('a',:name => 'a')
        mccount = mock('count', :name => 'count')
        ActiveRecord::Base.connection.stub!(:columns).with('mytable').and_return([mca , mccount ])
        ActiveRecord::Base.connection.stub!(:quote_column_name).with('a').and_return('a')
        ActiveRecord::Base.connection.stub!(:quote_column_name).with('count').and_return('"count"')
        ActiveRecord::Base.connection.stub!(:quote).with(1, mca).and_return("'1'")
        ActiveRecord::Base.connection.stub!(:quote).with(2, mccount).and_return("'2'")
        ActiveRecord::Base.connection.stub!(:quote).with(3, mca).and_return("'3'")
        ActiveRecord::Base.connection.stub!(:quote).with(4, mccount).and_return("'4'")
        ActiveRecord::Base.connection.should_receive(:execute).with("INSERT INTO mytable (a,\"count\") VALUES ('1','2')")
        ActiveRecord::Base.connection.should_receive(:execute).with("INSERT INTO mytable (a,\"count\") VALUES ('3','4')")

        SerializationHelper::Load.load_records('mytable', ['a', 'count'], [[1, 2], [3, 4]])
    end

  	it "should truncate the table and then load the records into the table" do
		SerializationHelper::Load.should_receive(:truncate_table).with('mytable')
		SerializationHelper::Load.should_receive(:load_records).with('mytable', ['a', 'b'], [[1, 2], [3, 4]])
		SerializationHelper::Load.should_receive(:reset_pk_sequence!).with('mytable')

		SerializationHelper::Load.load_table('mytable', { 'columns' => [ 'a', 'b' ], 'records' => [[1, 2], [3, 4]] })
	end
end
