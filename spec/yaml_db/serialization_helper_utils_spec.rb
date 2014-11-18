module YamlDb
  module SerializationHelper
    RSpec.describe Utils do

      before do
        allow(ActiveRecord::Base).to receive(:connection).and_return(double('connection').as_null_object)
      end

      it "returns an array of hash values using an array of ordered keys" do
        expect(Utils.unhash({ 'a' => 1, 'b' => 2 }, [ 'b', 'a' ])).to eq([ 2, 1 ])
      end

      it "unhashes each hash to an array using an array of ordered keys" do
        expect(Utils.unhash_records([ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ], [ 'b', 'a' ])).to eq([ [ 2, 1 ], [ 4, 3 ] ])
      end

      it "returns true if it is a boolean type" do
        expect(Utils.is_boolean(true)).to be true
        expect(Utils.is_boolean('true')).to be false
      end

      it "returns an array of boolean columns" do
        allow(ActiveRecord::Base.connection).to receive(:columns).with('mytable').and_return([ double('a',:name => 'a',:type => :string), double('b', :name => 'b',:type => :boolean) ])
        expect(Utils.boolean_columns('mytable')).to eq(['b'])
      end

      it "quotes the table name" do
        expect(ActiveRecord::Base.connection).to receive(:quote_table_name).with('values').and_return('`values`')
        expect(Utils.quote_table('values')).to eq('`values`')
      end

      it "converts ruby booleans to true and false" do
        expect(Utils.convert_boolean(true)).to be true
        expect(Utils.convert_boolean(false)).to be false
      end

      it "converts ruby strings t and f to true and false" do
        expect(Utils.convert_boolean('t')).to be true
        expect(Utils.convert_boolean('f')).to be false
      end

      it "converts ruby strings 1 and 0 to true and false" do
        expect(Utils.convert_boolean('1')).to be true
        expect(Utils.convert_boolean('0')).to be false
      end

      it "converts ruby integers 1 and 0 to true and false" do
        expect(Utils.convert_boolean(1)).to be true
        expect(Utils.convert_boolean(0)).to be false
      end

    end
  end
end
