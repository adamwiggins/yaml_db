module YamlDb
  module SerializationHelper
    RSpec.describe Load do

      before do
        allow(Utils).to receive(:quote_table).with('mytable').and_return('mytable')

        allow(ActiveRecord::Base).to receive(:connection).and_return(double('connection').as_null_object)
        allow(ActiveRecord::Base.connection).to receive(:transaction).and_yield
        @io = StringIO.new
      end

      it "truncates the table" do
        allow(ActiveRecord::Base.connection).to receive(:execute).with("TRUNCATE mytable").and_return(true)
        expect(ActiveRecord::Base.connection).not_to receive(:execute).with("DELETE FROM mytable")
        Load.truncate_table('mytable')
      end

      it "deletes the table if truncate throws an exception" do
        expect(ActiveRecord::Base.connection).to receive(:execute).with("TRUNCATE mytable").and_raise()
        expect(ActiveRecord::Base.connection).to receive(:execute).with("DELETE FROM mytable").and_return(true)
        Load.truncate_table('mytable')
      end

      it "calls reset pk sequence if the connection adapter is postgres" do
        expect(ActiveRecord::Base.connection).to receive(:respond_to?).with(:reset_pk_sequence!).and_return(true)
        expect(ActiveRecord::Base.connection).to receive(:reset_pk_sequence!).with('mytable')
        Load.reset_pk_sequence!('mytable')
      end

      it "does not call reset pk sequence for other adapters" do
        expect(ActiveRecord::Base.connection).to receive(:respond_to?).with(:reset_pk_sequence!).and_return(false)
        expect(ActiveRecord::Base.connection).not_to receive(:reset_pk_sequence!)
        Load.reset_pk_sequence!('mytable')
      end

      it "inserts records into a table" do
        mca = double('a',:name => 'a')
        mcb = double('b', :name => 'b')
        allow(ActiveRecord::Base.connection).to receive(:columns).with('mytable').and_return([mca , mcb ])
        allow(ActiveRecord::Base.connection).to receive(:quote_column_name).with('a').and_return('a')
        allow(ActiveRecord::Base.connection).to receive(:quote_column_name).with('b').and_return('b')
        allow(ActiveRecord::Base.connection).to receive(:quote).with(1, mca).and_return("'1'")
        allow(ActiveRecord::Base.connection).to receive(:quote).with(2, mcb).and_return("'2'")
        allow(ActiveRecord::Base.connection).to receive(:quote).with(3, mca).and_return("'3'")
        allow(ActiveRecord::Base.connection).to receive(:quote).with(4, mcb).and_return("'4'")
        expect(ActiveRecord::Base.connection).to receive(:execute).with("INSERT INTO mytable (a,b) VALUES ('1','2')")
        expect(ActiveRecord::Base.connection).to receive(:execute).with("INSERT INTO mytable (a,b) VALUES ('3','4')")

        Load.load_records('mytable', ['a', 'b'], [[1, 2], [3, 4]])
      end

      it "quotes column names that correspond to sql keywords" do
        mca = double('a',:name => 'a')
        mccount = double('count', :name => 'count')
        allow(ActiveRecord::Base.connection).to receive(:columns).with('mytable').and_return([mca , mccount ])
        allow(ActiveRecord::Base.connection).to receive(:quote_column_name).with('a').and_return('a')
        allow(ActiveRecord::Base.connection).to receive(:quote_column_name).with('count').and_return('"count"')
        allow(ActiveRecord::Base.connection).to receive(:quote).with(1, mca).and_return("'1'")
        allow(ActiveRecord::Base.connection).to receive(:quote).with(2, mccount).and_return("'2'")
        allow(ActiveRecord::Base.connection).to receive(:quote).with(3, mca).and_return("'3'")
        allow(ActiveRecord::Base.connection).to receive(:quote).with(4, mccount).and_return("'4'")
        expect(ActiveRecord::Base.connection).to receive(:execute).with("INSERT INTO mytable (a,\"count\") VALUES ('1','2')")
        expect(ActiveRecord::Base.connection).to receive(:execute).with("INSERT INTO mytable (a,\"count\") VALUES ('3','4')")

        Load.load_records('mytable', ['a', 'count'], [[1, 2], [3, 4]])
      end

      it "truncates the table and then loads the records into the table" do
        expect(Load).to receive(:truncate_table).with('mytable')
        expect(Load).to receive(:load_records).with('mytable', ['a', 'b'], [[1, 2], [3, 4]])
        expect(Load).to receive(:reset_pk_sequence!).with('mytable')

        Load.load_table('mytable', { 'columns' => [ 'a', 'b' ], 'records' => [[1, 2], [3, 4]] })
      end

    end
  end
end
