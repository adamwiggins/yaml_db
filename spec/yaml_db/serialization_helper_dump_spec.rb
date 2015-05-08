module YamlDb
  module SerializationHelper
    RSpec.describe Dump do

      before do
        allow(ActiveRecord::Base).to receive(:connection).and_return(double('connection').as_null_object)
        allow(ActiveRecord::Base.connection).to receive(:tables).and_return([ 'mytable', 'schema_info', 'schema_migrations' ])
        allow(ActiveRecord::Base.connection).to receive(:columns).with('mytable').and_return([ double('a', :name => 'a', :type => :string), double('b', :name => 'b', :type => :string) ])
        allow(ActiveRecord::Base.connection).to receive(:select_one).and_return({"count"=>"2"})
        allow(ActiveRecord::Base.connection).to receive(:select_all).and_return([ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ])
        allow(Utils).to receive(:quote_table).with('mytable').and_return('mytable')
      end

      before(:each) do
        allow(File).to receive(:open).with('dump.yml', 'w').and_yield(StringIO.new)
        @io = StringIO.new
      end

      it "returns a list of column names" do
        expect(Dump.table_column_names('mytable')).to eq([ 'a', 'b' ])
      end

      it "returns a list of tables without the rails schema table" do
        expect(Dump.tables).to eq(['mytable'])
      end

      it "returns the total number of records in a table" do
        expect(Dump.table_record_count('mytable')).to eq(2)
      end

      it "returns all records from the database and returns them when there is only 1 page" do
        Dump.each_table_page('mytable') do |records|
          expect(records).to eq([ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ])
        end
      end

      it "paginates records from the database and returns them" do
        allow(ActiveRecord::Base.connection).to receive(:select_all).and_return([ { 'a' => 1, 'b' => 2 } ], [ { 'a' => 3, 'b' => 4 } ])

        records = [ ]
        Dump.each_table_page('mytable', 1) do |page|
          expect(page.size).to eq(1)
          records.concat(page)
        end

        expect(records).to eq([ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ])
      end

      it "dumps a table's contents to yaml" do
        expect(Dump).to receive(:dump_table_columns)
        expect(Dump).to receive(:dump_table_records)
        Dump.dump_table(@io, 'mytable')
      end

      it "does not dump a table's contents when the record count is zero" do
        allow(Dump).to receive(:table_record_count).with('mytable').and_return(0)
        expect(Dump).not_to receive(:dump_table_columns)
        expect(Dump).not_to receive(:dump_table_records)
        Dump.dump_table(@io, 'mytable')
      end

    end
  end
end
