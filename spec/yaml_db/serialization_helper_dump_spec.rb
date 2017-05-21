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

      it "returns the total number of records in a table" do
        expect(Dump.table_record_count('mytable')).to eq(2)
      end

      describe ".each_table_page" do
        before do
          allow(Dump).to receive(:sort_keys)
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

      describe ".tables" do
        it "returns a list of tables without the rails schema table" do
          expect(Dump.tables).to eq(['mytable'])
        end

        it "returns the list of tables in a consistent (sorted) order" do
          allow(ActiveRecord::Base.connection).to receive(:tables).and_return(%w(z y x))
          expect(Dump.tables).to eq(%w(x y z))
        end
      end

      describe ".sort_keys" do
        before do
          allow(Utils).to receive(:quote_column) { |column| column }
        end

        it "returns the first column as sort key" do
          expect(Dump.sort_keys('mytable')).to eq(['a'])
        end

        it "returns the combined ids as sort key if the table looks like a HABTM" do
          allow(ActiveRecord::Base.connection).to receive(:columns).with('mytable').and_return([
            double('a_id', :name => 'a_id', :type => :string),
            double('b_id', :name => 'b_id', :type => :string)
          ])

          expect(Dump.sort_keys('mytable')).to eq(['a_id', 'b_id'])
        end

        it "quotes the column name" do
          allow(Utils).to receive(:quote_column).with('a').and_return('`a`')
          expect(Dump.sort_keys('mytable')).to eq(['`a`'])
        end
      end
    end
  end
end
