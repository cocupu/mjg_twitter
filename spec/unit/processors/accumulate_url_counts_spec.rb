require 'spec_helper'
require 'json'

describe :accumulate_url_counts do
  let(:input_file) { File.open(File.dirname(__FILE__)+'/../../sample_data/mapper_output_sample.json') }
  let(:mapper_output) { input_file.to_a.map {|l| JSON.parse(l)} }
  it_behaves_like 'a processor', :named => :accumulate_url_counts
  it "groups by URL, accumulates total_tweets and calculates weighted_count" do
    expected = ['{"url":"http://blog.tonicdev.com/2015/09/30/embedded-tonic.html","weighted_count":20,"count":2,"retweets":0,"total_tweets":2,"posted_time":"2015-10-01T17:56:09.000Z","date":"2015-10-01"}',
               '{"url":"http://clientlogin.dityapps.com/mobile/?appcode=vstreamtv","weighted_count":10,"count":1,"retweets":0,"total_tweets":1,"posted_time":"2015-10-01T17:56:36.000Z","date":"2015-10-01"}',
               '{"url":"http://jlongster.com/Using-Immutable-Data-Structures-in-JavaScript","weighted_count":11,"count":1,"retweets":1,"total_tweets":2,"posted_time":"2015-10-01T17:56:50.000Z","date":"2015-10-01"}',
               '{"url":"http://www.billyourinetszgj.cu.cc/page-68201/710241","weighted_count":10,"count":1,"retweets":0,"total_tweets":1,"posted_time":"2015-10-01T17:56:04.000Z","date":"2015-10-01"}',
               '{"url":"http://www.techtya.com/bbc-finally-ditching-adobe-flash-in-favor-of-html5-for-iplayer-video-playback-1969249","weighted_count":320,"count":32,"retweets":0,"total_tweets":32,"posted_time":"2015-10-01T17:56:09.000Z","date":"2015-10-01"}',
               '{"url":"https://medium.com/@tibbb/how-we-created-an-immersive-street-walk-experience-with-a-gopro-and-javascript-f442cf8aa2dd","weighted_count":10,"count":1,"retweets":0,"total_tweets":1,"posted_time":"2015-10-01T17:56:50.000Z","date":"2015-10-01"}']
    expect(processor.given(*mapper_output)).to emit(*expected)
  end
end