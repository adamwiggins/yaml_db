require File.dirname(__FILE__) + '/base'

describe YamlDb do
	before do
		ActiveRecord::Base = mock('ActiveRecord::Base', :null_object => true)
		ActiveRecord::Base.stub!(:configurations).and_return(mock('configurations'))
		RAILS_ENV = "test" unless defined?(RAILS_ENV)
	end

	it "verifies that the connection is encoded with unicode or utf8" do
		@config = { 'encoding' => 'utf8' }
		ActiveRecord::Base.configurations.stub!(:[]).with('test').and_return(@config)
		lambda { YamlDb.verify_utf8 }.should_not raise_error(YamlDb::EncodingException)
	end

	it "raises an exception if encoding is not set" do
		@config = { }
		ActiveRecord::Base.configurations.stub!(:[]).with('test').and_return(@config)
		lambda { YamlDb.verify_utf8 }.should raise_error(YamlDb::EncodingException)
	end

	it "raises an exception if encoding is not utf8 or unicode" do
		@config = { 'encoding' => 'latin1' }
		ActiveRecord::Base.configurations.stub!(:[]).with('test').and_return(@config)
		lambda { YamlDb.verify_utf8 }.should raise_error(YamlDb::EncodingException)
	end
end
