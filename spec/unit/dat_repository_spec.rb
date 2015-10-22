require 'spec_helper'

describe Dat::Repository do
  let(:dir) { 'tmp/test/dat_dir' }
  let(:expanded_dir) { File.expand_path dir }
  let(:repo) { described_class.new(dir: dir) }
  let(:log_json) { File.read(sample_file('dat_log_json.txt')) }
  let(:diff_json) { File.read(sample_file('dat_diff_json.txt')) }
  subject { repo }

  describe 'init' do
    it 'tells dat to init the repository' do
      expect(subject).to receive(:run_command).with("dat init --path=#{expanded_dir} --no-prompt --json").and_return('{"message":"Initialized a new dat at #{expanded_dir}","created":true}')
      subject.init
    end
  end
  
  describe 'import' do
    let(:file_path) { '/foo/bar' }
    let(:expanded_file_path) { File.expand_path file_path }
    let(:dat_response) { '{"version":"02ad87accca3ab5fbbe2d073d99a617d2c1c6b3bbf8db5534552c9fd186bbe02"}'}

    context 'a file, key and message' do
      subject { repo.import(dataset:'billion_flowers', file: file_path, key: 'urls', message:'this is a message') }
      it 'imports data from the file into dat' do
        expect(repo).to receive(:run_command).with("dat import #{expanded_file_path} -d billion_flowers -k urls -m \"this is a message\" --json").and_return(dat_response)
        subject
      end
    end    
  end
  
  describe 'push' do
    let(:remote) { 'ssh://boo@widgets.com:dat/widget_inventory'}
    let(:push_json) { '{"version":"02ad87accca3ab5fbbe2d073d99a617d2c1c6b3bbf8db5534552c9fd186bbe02"}'}
    subject { repo.push(remote: remote) }
    it 'tells dat to push to a remote dat repo' do
      expect(repo).to receive(:run_command).with("dat push #{remote} --json").and_return(push_json)
      subject
    end
  end
  
end