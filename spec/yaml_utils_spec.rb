require File.dirname(__FILE__) + '/base'

describe YamlDb::Utils, " convert records utility method" do

	it "turns an array with one record into a yaml chunk" do
		YamlDb::Utils.chunk_records([ %w(a b) ]).should == <<EOYAML
  - - a
    - b
EOYAML
	end

	it "turns an array with two records into a yaml chunk" do
		YamlDb::Utils.chunk_records([ %w(a b), %w(x y) ]).should == <<EOYAML
  - - a
    - b
  - - x
    - y
EOYAML
	end

end
