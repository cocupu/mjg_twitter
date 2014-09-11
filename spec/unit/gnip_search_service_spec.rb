require 'spec_helper'

describe Gnip::SearchService do
  let(:now) { DateTime.now}
  let(:default_rules) { Gnip::Searcher.default_rules }
  let(:query_params) { {query:default_rules,publisher:"twitter",maxResults:500,fromDate:(now-1).strftime("%Y%m%d%H%M").to_i,toDate:now.strftime("%Y%m%d%H%M").to_i } }
  let(:r1) { {id:"result1",postedTime:"2008-06-25T09:28:27.000Z"} }
  let(:r2) { {id:"result2",postedTime:"2008-06-25T09:28:28.000Z"} }
  let(:r3) { {id:"result3",postedTime:"2008-06-25T09:28:29.000Z"} }
  let(:response_with_next_token) { Yajl::Encoder.encode({next:"token1",results:[r1,r2,r3]})}
  let(:response_without_next_token) { Yajl::Encoder.encode({results:[r1,r2,r3]})}

  it "should read GNIP credentials from config/gnip.yml" do
    expect(Gnip::SearchService.gnip_config).to eq( {:account => "MJGInternational", :username => "marc@mjg.in", :password =>"boopass", :stream_name => "prod"} )
    expect(Gnip::SearchService.account).to eq "MJGInternational"
    expect(Gnip::SearchService.stream_name).to eq "prod"
    expect(Gnip::SearchService.search_endpoint).to eq "https://search.gnip.com/accounts/MJGInternational/search/prod.json"
    expect(Gnip::SearchService.count_endpoint).to eq "https://search.gnip.com/accounts/MJGInternational/search/prod/counts.json"
  end
  
  it "should retrieve full set of paginated results" do
    pending "decided to take a different route WRT paginated results"
    expect(Gnip::SearchService).to receive(:http_post).with(Gnip::SearchService.search_endpoint, Yajl::Encoder.encode(query_params)).and_return(response_with_next_token)
    expect(Gnip::SearchService).to receive(:http_post).with(Gnip::SearchService.search_endpoint, Yajl::Encoder.encode(query_params.merge(next:"token1"))).and_return(response_with_next_token, response_with_next_token, response_without_next_token)
    results = Gnip::SearchService.activities_for(default_rules, from:(now-1).strftime("%Y%m%d%H%M"), to:now.strftime("%Y%m%d%H%M"), max:500)
    results.count.should == 9
    results.map {|r| r[:id]}.should == ["result3","result3","result3","result2","result2","result2","result1","result1","result1"]
  end

  it "should wait and resume rate-limited requests" do
    expect(Gnip::SearchService).to receive(:sleep).with(4)
    limit_exceeded_response = double("response", code:429, message:"Rate limit exceeded")
    rate_limit_exceeded_exception = RestClient::Exception.new(limit_exceeded_response, 429)
    throttled_request = double("throttled request")
    expect(throttled_request).to receive(:execute).and_raise(rate_limit_exceeded_exception)
    good_request = double("good request")
    expect(good_request).to receive(:execute)

    expect(RestClient::Request).to receive(:new).and_return(throttled_request, good_request)
    Gnip::SearchService.send(:throttled_http_post, Gnip::SearchService.search_endpoint, Yajl::Encoder.encode(query_params) )
  end
end