module YamlDb
  module SerializationHelper
    RSpec.describe Base do
      def prestub_active_record
      end

      before do
        @io = StringIO.new
        allow(ActiveRecord::Base).to receive(:connection).and_return(double('connection'))
        allow(ActiveRecord::Base.connection).to receive(:tables).and_return([ 'mytable', 'schema_info', 'schema_migrations' ])
      end

      def stub_helper!
        @helper = double("MyHelper")
        @dumper = double("MyDumper");
        @loader = double("MyLoader");
        allow(@helper).to receive(:dumper).and_return(@dumper)
        allow(@helper).to receive(:loader).and_return(@loader)
        allow(@helper).to receive(:extension).and_return("yml")
        allow(@dumper).to receive(:tables).and_return([ActiveRecord::Base.connection.tables[0]])
        allow(@dumper).to receive(:before_table).and_return(nil)
        allow(@dumper).to receive(:after_table).and_return(nil)
      end

      context "for multi-file dumps" do
        before do
          expect(File).to receive(:open).once.with("dir_name/mytable.yml", "w").and_yield(@io)
          expect(Dir).to receive(:mkdir).once.with("dir_name")
          stub_helper!
          expect(@dumper).to receive(:dump_table).once.with(@io, "mytable")
        end

        it "creates the number of files that there are tables" do
           Base.new(@helper).dump_to_dir "dir_name"
        end

      end

      context "for multi-file loads" do
        before do
          stub_helper!
          expect(@loader).to receive(:load).once.with(@io, true)
          expect(File).to receive(:new).once.with("dir_name/mytable.yml", "r").and_return(@io)
          allow(Dir).to receive(:entries).and_return(["mytable.yml"])
        end

        it "inserts into the number of tables that there are files" do
          Base.new(@helper).load_from_dir "dir_name"
        end
      end

    end
  end
end
