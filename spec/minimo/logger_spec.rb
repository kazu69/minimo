require 'spec_helper'

describe Minimo::Logger do
  let(:logger) { Minimo::Logger.new('log', ::Logger::INFO) }

  before(:all) do
    Dir.mkdir './log' unless Dir.exist? './log'
  end

  after(:all) do
    FileUtils.rm_rf './log' if Dir.exist? './log'
  end

  it 'sets instance variables' do
    expect(logger.instance_variable_get :@dir).to eq('log')
    expect(logger.instance_variable_get :@level).to eq(::Logger::INFO)
  end

  describe '#write' do
    it 'writes log' do
      msg = 'message'
      expect_any_instance_of(Logger).to receive(:info).at_least(:once)
      expect_any_instance_of(Logger).to receive(:close).at_least(:once)
      logger.write msg
    end
  end
end
