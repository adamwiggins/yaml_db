require File.dirname(__FILE__) + '/base'

describe YamlDb::Load do
	before do
		SerializationHelper::Utils.stub!(:quote_table).with('mytable').and_return('mytable')

		ActiveRecord::Base = mock('ActiveRecord::Base', :null_object => true)
		ActiveRecord::Base.connection = mock('connection')
		ActiveRecord::Base.connection.stub!(:transaction).and_yield
	end

	before(:each) do
		@io = StringIO.new
	end

end
