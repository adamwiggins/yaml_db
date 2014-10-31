RSpec.describe YamlDb::Utils, " convert records utility method" do

  it "turns an array with one record into a yaml chunk" do
    expect(YamlDb::Utils.chunk_records([ %w(a b) ])).to eq(<<EOYAML
  - - a
    - b
EOYAML
    )
  end

  it "turns an array with two records into a yaml chunk" do
    expect(YamlDb::Utils.chunk_records([ %w(a b), %w(x y) ])).to eq(<<EOYAML
  - - a
    - b
  - - x
    - y
EOYAML
    )
  end

end
