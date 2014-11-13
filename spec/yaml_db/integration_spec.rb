require 'active_record/railtie'

# connect to in-memory SQLite database
ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:'
)

# define a dummy User model
class User < ActiveRecord::Base
end

# create the users table
ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, :force => true do |t|
    t.string :username
  end
end

# add some users
User.create([
  {:username => 'alice'},
  {:username => 'bob'}
])


RSpec.describe "with real ActiveRecord," do

  it "contains two users" do
    expect(User.count).to eq(2)
  end

  it "dumps the user records" do
    @io = StringIO.new
    YamlDb::Dump.dump_table_records(@io, 'users')
    @io.rewind
    expect(@io.read).to eq(<<EOYAML
  records: 
  - - 1
    - alice
  - - 2
    - bob
EOYAML
    )
  end

end
