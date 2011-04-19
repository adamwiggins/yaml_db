require File.dirname(__FILE__) + '/base'
require 'active_support/core_ext/kernel/debugger'

describe YamlDb::Load do
	before do
		SerializationHelper::Utils.stub!(:quote_table).with('mytable').and_return('mytable')

		silence_warnings { ActiveRecord::Base = mock('ActiveRecord::Base', :null_object => true) }
		ActiveRecord::Base.stub(:connection).and_return(stub('connection').as_null_object)
		ActiveRecord::Base.connection.stub!(:transaction).and_yield
	end

	before(:each) do
		@io = StringIO.new
    end
    

	it "should call load structure for each document in the file" do
		YAML.should_receive(:load_documents).with(@io).and_yield({ 'mytable' => { 
					'columns' => [ 'a', 'b' ], 
					'records' => [[1, 2], [3, 4]] 
				} } )
		YamlDb::Load.should_receive(:load_table).with('mytable', { 'columns' => [ 'a', 'b' ], 'records' => [[1, 2], [3, 4]] },true)
		YamlDb::Load.load(@io)
	end

	it "should not call load structure when the document in the file contains no records" do
		YAML.should_receive(:load_documents).with(@io).and_yield({ 'mytable' => nil })
		YamlDb::Load.should_not_receive(:load_table)
		YamlDb::Load.load(@io)
	end

end
