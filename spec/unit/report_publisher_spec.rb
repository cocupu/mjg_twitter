require 'spec_helper'

describe ReportPublisher do
  let(:bindery_opts) { {dat:'ssh://path/to/dat', email:"archivist@example.com", identity:"my_identity", host:"myhost", password:"mypass", pool_id:22, model_id:45} }
  let(:bindery_model) { Cocupu::Model.new("fields"=>[{"id"=>"101", "code"=>"url"}, {"id"=>"102", "code"=>"count"}, {"id"=>"102", "code"=>"retweets"}, {"id"=>"102", "code"=>"total_tweets"}, {"id"=>"102", "code"=>"text"}, {"id"=>"102", "code"=>"source_urls"}]) }
  let(:dat) { Dat::Repository.new(dir: 'dat_repo') }
  
  before do
    allow(described_class).to receive(:bindery_opts).and_return(bindery_opts)
  end
  
  describe '#publish_from_dat' do
    before do
      expect(Cocupu).to receive(:start).with("archivist@example.com", "mypass", 80, "myhost")
    end
    it 'publishes to bindery dat repo and then tells bindery pool to update its index' do
      expect(dat).to receive(:push).with(remote: 'ssh://path/to/dat')
      expect(Cocupu::PoolIndex).to receive(:update).with(pool_id: 22, index_name:'live', source: { dat: { from: 'commitRef1', to: 'commitRef2' } })
      described_class.publish_from_dat(dat, start_at:'commitRef1', stop_at:'commitRef2')
    end
  end

end