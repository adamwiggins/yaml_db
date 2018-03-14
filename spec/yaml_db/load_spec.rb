module YamlDb
  RSpec.describe Load do

    before do
      allow(SerializationHelper::Utils).to receive(:quote_table).with('mytable').and_return('mytable')

      allow(ActiveRecord::Base).to receive(:connection).and_return(double('connection').as_null_object)
      allow(ActiveRecord::Base.connection).to receive(:transaction).and_yield
    end

    before(:each) do
      @io = StringIO.new
    end

    it "calls load structure for each document in the file" do
      expect(YAML).to receive(:load_documents).with(@io).and_yield({ 'mytable' => {
            'columns' => [ 'a', 'b' ],
            'records' => [[1, 2], [3, 4]]
          } } )
      expect(Load).to receive(:load_table).with('mytable', { 'columns' => [ 'a', 'b' ], 'records' => [[1, 2], [3, 4]] },true)
      Load.load(@io)
    end

    it "calls load structure when the document in the file contains no records" do
      expect(YAML).to receive(:load_documents).with(@io).and_yield({ 'mytable' => nil })
      expect(Load).not_to receive(:load_table)
      Load.load(@io)
    end

  end
end
