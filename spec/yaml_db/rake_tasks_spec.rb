module YamlDb
  RSpec.describe RakeTasks do
    before do
      @serializer = instance_double(SerializationHelper::Base)
      allow(SerializationHelper::Base).to receive(:new).and_return(@serializer)
      allow(Rails).to receive(:root).and_return('/root')
      allow(Time).to receive(:now).and_return(Time.parse('2007-08-09 12:34:56'))
      stub_const('UserSpecifiedHelper', Class.new)
      allow(UserSpecifiedHelper).to receive(:extension).and_return('ext')
    end

    describe '.data_dump_task' do
      it 'dumps to a file' do
        expect(SerializationHelper::Base).to receive(:new).once.with(Helper)
        expect(@serializer).to receive(:dump).once.with('/root/db/data.yml')
        RakeTasks.data_dump_task
      end

      it 'dumps to a file using a user-specified format class' do
        stub_const('ENV', 'class' => 'UserSpecifiedHelper')
        expect(SerializationHelper::Base).to receive(:new).once.with(UserSpecifiedHelper)
        expect(@serializer).to receive(:dump).once.with('/root/db/data.ext')
        RakeTasks.data_dump_task
      end
    end

    describe '.data_dump_dir_task' do
      it 'dumps to a directory' do
        expect(SerializationHelper::Base).to receive(:new).once.with(Helper)
        expect(@serializer).to receive(:dump_to_dir).once.with('/root/db/2007-08-09_12:34:56')
        RakeTasks.data_dump_dir_task
      end

      it 'dumps to a directory using a user-specified format class' do
        stub_const('ENV', 'class' => 'UserSpecifiedHelper')
        expect(SerializationHelper::Base).to receive(:new).once.with(UserSpecifiedHelper)
        expect(@serializer).to receive(:dump_to_dir).once.with('/root/db/2007-08-09_12:34:56')
        RakeTasks.data_dump_dir_task
      end

      it 'dumps to a user-specified directory' do
        stub_const('ENV', 'dir' => 'user_dir')
        expect(SerializationHelper::Base).to receive(:new).once.with(Helper)
        expect(@serializer).to receive(:dump_to_dir).once.with('/root/db/user_dir')
        RakeTasks.data_dump_dir_task
      end
    end

    describe '.data_load_task' do
      it 'loads a file' do
        expect(SerializationHelper::Base).to receive(:new).once.with(Helper)
        expect(@serializer).to receive(:load).once.with('/root/db/data.yml')
        RakeTasks.data_load_task
      end

      it 'loads a file using a user-specified format class' do
        stub_const('ENV', 'class' => 'UserSpecifiedHelper')
        expect(SerializationHelper::Base).to receive(:new).once.with(UserSpecifiedHelper)
        expect(@serializer).to receive(:load).once.with('/root/db/data.ext')
        RakeTasks.data_load_task
      end
    end

    describe '.data_load_dir_task' do
      it 'loads a directory' do
        expect(SerializationHelper::Base).to receive(:new).once.with(Helper)
        expect(@serializer).to receive(:load_from_dir).once.with('/root/db/base')
        RakeTasks.data_load_dir_task
      end

      it 'loads a directory using a user-specified format class' do
        stub_const('ENV', 'class' => 'UserSpecifiedHelper')
        expect(SerializationHelper::Base).to receive(:new).once.with(UserSpecifiedHelper)
        expect(@serializer).to receive(:load_from_dir).once.with('/root/db/base')
        RakeTasks.data_load_dir_task
      end

      it 'loads a user-specified directory' do
        stub_const('ENV', 'dir' => 'user_dir')
        expect(SerializationHelper::Base).to receive(:new).once.with(Helper)
        expect(@serializer).to receive(:load_from_dir).once.with('/root/db/user_dir')
        RakeTasks.data_load_dir_task
      end
    end
  end
end
