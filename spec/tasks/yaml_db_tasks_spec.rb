require 'rake'

RSpec.describe 'Rake tasks' do
  before do
    Rake::Application.new.rake_require('tasks/yaml_db_tasks')
    Rake::Task.define_task(:environment)
  end

  subject { Rake::Task[self.class.description] }

  describe 'db:dump' do
    it 'depends on db:schema:dump and db:data:dump' do
      expect(subject.prerequisites).to eq(['db:schema:dump', 'db:data:dump'])
    end
  end

  describe 'db:load' do
    it 'depends on db:schema:load and db:data:load' do
      expect(subject.prerequisites).to eq(['db:schema:load', 'db:data:load'])
    end
  end

  describe 'db:data:dump' do
    it 'loads the environment' do
      expect(subject.prerequisites).to eq(['environment'])
    end

    it 'invokes the correct task' do
      expect(YamlDb::RakeTasks).to receive(:data_dump_task).once.with(no_args)
      subject.invoke
    end
  end

  describe 'db:data:dump_dir' do
    it 'loads the environment' do
      expect(subject.prerequisites).to eq(['environment'])
    end

    it 'invokes the correct task' do
      expect(YamlDb::RakeTasks).to receive(:data_dump_dir_task).once.with(no_args)
      subject.invoke
    end
  end

  describe 'db:data:load' do
    it 'loads the environment' do
      expect(subject.prerequisites).to eq(['environment'])
    end

    it 'invokes the correct task' do
      expect(YamlDb::RakeTasks).to receive(:data_load_task).once.with(no_args)
      subject.invoke
    end
  end

  describe 'db:data:load_dir' do
    it 'loads the environment' do
      expect(subject.prerequisites).to eq(['environment'])
    end

    it 'invokes the correct task' do
      expect(YamlDb::RakeTasks).to receive(:data_load_dir_task).once.with(no_args)
      subject.invoke
    end
  end
end
