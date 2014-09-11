require 'spec_helper'

describe Gnip::Searcher do
  let(:now) { DateTime.now}
  let(:default_rules) { Gnip::Searcher.default_rules }
  let(:sample_query_params) { {query:default_rules, from:(now-1).strftime("%Y%m%d%H%M"), to:now.strftime("%Y%m%d%H%M"), max:500} }
  let(:internal_query_params) { {query:default_rules,publisher:"twitter",maxResults:500,fromDate:(now-1).strftime("%Y%m%d%H%M").to_i,toDate:now.strftime("%Y%m%d%H%M").to_i } }
  let(:r1) { {id:"result1",postedTime:"2008-06-25T09:28:27.000Z"} }
  let(:r2) { {id:"result2",postedTime:"2008-06-25T09:28:28.000Z"} }
  let(:r3) { {id:"result3",postedTime:"2008-06-25T09:28:29.000Z"} }
  let(:r4) { {id:"result3",postedTime:"2008-06-25T09:28:30.000Z"} }

  let(:response_with_next_token1) { Yajl::Encoder.encode({next:"token1",results:[r1,r2]})}
  let(:response_with_next_token2) { Yajl::Encoder.encode({next:"token2",results:[r3,r4]})}
  let(:response_without_next_token) { Yajl::Encoder.encode({results:[r2]})}

  it "should search activities" do
    expect(Gnip::SearchService).to receive(:http_post).with(Gnip::SearchService.search_endpoint, Yajl::Encoder.encode(internal_query_params)).and_return(response_with_next_token1)
    expect(Gnip::SearchService).to receive(:http_post).with(Gnip::SearchService.search_endpoint, Yajl::Encoder.encode(internal_query_params.merge(next:"token1"))).and_return(response_with_next_token2)
    expect(Gnip::SearchService).to receive(:http_post).with(Gnip::SearchService.search_endpoint, Yajl::Encoder.encode(internal_query_params.merge(next:"token2"))).and_return(response_without_next_token)
    expect( subject.run_search(sample_query_params) ).to eq([r2,r1])
    expect( subject.resume_search).to eq([r4,r3])
    expect( subject.resume_search).to eq([r2])
    expect( subject.resume_search).to be_nil
  end
  it "should search counts"
  it "should cache query params" do
    expect(Gnip::SearchService).to receive(:http_post).and_return(response_without_next_token)
    subject.run_search(sample_query_params)
    expect(subject.query_params).to eq(sample_query_params)
  end
  describe "resume" do
    it "should resume previous search" do
      expect(Gnip::SearchService).to receive(:http_post).and_return(response_with_next_token1)
      subject.run_search(sample_query_params)
      expect(subject.more_results?).to be true
      expect(subject.next_token).to eq("token1")
      expect(subject.query_params[:next]).to eq("token1")
      expect(subject).to receive(:run_search).with(sample_query_params.merge(next:"token1"))
      subject.resume_search
    end
    it "should return nothing if there are no more results to retrieve" do
      expect(Gnip::SearchService).to receive(:http_post).and_return(response_without_next_token)
      subject.run_search(sample_query_params)
      expect(subject.more_results?).to be false
      expect(subject.next_token).to be_nil
      expect(subject).to_not receive(:run_search)
      subject.resume_search
    end
  end

end