require File.dirname(__FILE__) + '/base'

describe SerializationHelper::Utils, " convert records utility method" do

  before do
    allow(ActiveRecord::Base).to receive(:connection).and_return(double('connection').as_null_object)
  end

  it "returns an array of hash values using an array of ordered keys" do
    expect(SerializationHelper::Utils.unhash({ 'a' => 1, 'b' => 2 }, [ 'b', 'a' ])).to eq([ 2, 1 ])
  end

  it "should unhash each hash an array using an array of ordered keys" do
    expect(SerializationHelper::Utils.unhash_records([ { 'a' => 1, 'b' => 2 }, { 'a' => 3, 'b' => 4 } ], [ 'b', 'a' ])).to eq([ [ 2, 1 ], [ 4, 3 ] ])
  end

  it "should return true if it is a boolean type" do
    expect(SerializationHelper::Utils.is_boolean(true)).to be true
    expect(SerializationHelper::Utils.is_boolean('true')).to be false
  end

  it "should return an array of boolean columns" do
    allow(ActiveRecord::Base.connection).to receive(:columns).with('mytable').and_return([ double('a',:name => 'a',:type => :string), double('b', :name => 'b',:type => :boolean) ])
    expect(SerializationHelper::Utils.boolean_columns('mytable')).to eq(['b'])
  end

  it "should quote the table name" do
    expect(ActiveRecord::Base.connection).to receive(:quote_table_name).with('values').and_return('`values`')
    expect(SerializationHelper::Utils.quote_table('values')).to eq('`values`')
  end

  it "should convert ruby booleans to true and false" do
    expect(SerializationHelper::Utils.convert_boolean(true)).to be true
    expect(SerializationHelper::Utils.convert_boolean(false)).to be false
  end

  it "should convert ruby string t and f to true and false" do
    expect(SerializationHelper::Utils.convert_boolean('t')).to be true
    expect(SerializationHelper::Utils.convert_boolean('f')).to be false
  end

  it "should convert ruby string 1 and 0 to true and false" do
    expect(SerializationHelper::Utils.convert_boolean('1')).to be true
    expect(SerializationHelper::Utils.convert_boolean('0')).to be false
  end

  it "should convert ruby integer 1 and 0 to true and false" do
    expect(SerializationHelper::Utils.convert_boolean(1)).to be true
    expect(SerializationHelper::Utils.convert_boolean(0)).to be false
  end

end
