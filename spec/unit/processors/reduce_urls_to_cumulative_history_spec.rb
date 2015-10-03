require 'spec_helper'
require 'json'

describe :reduce_urls_to_cumulative_history do
  let(:input_file) { File.open(File.dirname(__FILE__)+'/../../sample_data/sample_combined_linkreports.json') }
  let(:mapper_output) { input_file.to_a.map {|l| JSON.parse(l)} }
  it_behaves_like 'a processor', :named => :reduce_urls_to_cumulative_history
  it "groups by URL, accumulates total_tweets and calculates weighted_count" do
    expected = ['{"url":"http://betalist.com:80/startups/code4startup","appeared_on":["2014-08-26","2015-02-12"],"first_appearance":"2014-08-26","last_posted_time":"2015-02-12T18:11:40.000Z","last_total_tweets":250,"last_count":22,"last_retweets":70,"last_weighted_count":290,"cumulative_total_tweets":743,"source_urls":["http://source.1","http://new.url.1","http://new.url.2"],"text":["NEW TEXT"]}',
               '{"url":"https://github.com/jquery/jquery.com/issues/88#issuecomment-72400007","appeared_on":["2015-02-12"],"first_appearance":"2015-02-12","last_posted_time":"2015-02-12T09:43:15.000Z","last_total_tweets":4814,"last_count":7,"last_retweets":4807,"last_weighted_count":4877,"cumulative_total_tweets":4814,"source_urls":["https://t.co/zEQf6F54p6","https://t.co/JH3QXm0VHS"],"text":["SOME TEXT"]}',
               '{"url":"http://www.dhteumeuleu.com/apparently-transparent","appeared_on":["2015-02-12"],"first_appearance":"2015-02-12","last_posted_time":"2015-02-12T12:00:37.000Z","last_total_tweets":1978,"last_count":66,"last_retweets":1912,"last_weighted_count":2572,"cumulative_total_tweets":1978,"source_urls":["http://t.co/v2ZmZEZA69"],"text":["SOME TEXT"]}',
               '{"url":"https://medium.com/@iojs/io-js-and-a-node-js-foundation-4e14699fb7be","appeared_on":["2015-02-12"],"first_appearance":"2015-02-12","last_posted_time":"2015-02-12T15:07:37.000Z","last_total_tweets":1162,"last_count":75,"last_retweets":1087,"last_weighted_count":1837,"cumulative_total_tweets":1162,"source_urls":["https://t.co/mUBs3l2IZd"],"text":["SOME TEXT"]}',
               '{"url":"http://davidwalsh.name/eslint","appeared_on":["2015-02-12"],"first_appearance":"2015-02-12","last_posted_time":"2015-02-12T18:11:40.000Z","last_total_tweets":763,"last_count":59,"last_retweets":704,"last_weighted_count":1294,"cumulative_total_tweets":763,"source_urls":["http://t.co/fBrOFojLtY","http://t.co/nVPVQoMOYH"],"text":["SOME TEXT"]}']
    expect(processor.given(*mapper_output)).to emit(*expected)
  end
end