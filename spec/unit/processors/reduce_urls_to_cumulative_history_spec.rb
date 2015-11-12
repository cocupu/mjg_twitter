require 'spec_helper'
require 'json'

describe :reduce_urls_to_cumulative_history do
  let(:input_file) { File.open(File.dirname(__FILE__)+'/../../sample_data/sample_combined_linkreports.json') }
  let(:mapper_output) { input_file.to_a.map {|l| JSON.parse(l)} }
  let(:input_json) { mapper_output }
  let(:the_processor) { processor(:reduce_urls_to_cumulative_history) }
  subject { the_processor.given(*input_json).json_output }

  it_behaves_like 'a processor', :named => :reduce_urls_to_cumulative_history
  it "groups by URL, accumulates total_tweets and calculates weighted_count" do
    expected = [{"url"=>"http://betalist.com:80/startups/code4startup", "rank"=>15, "appeared_on"=>["2014-08-26", "2015-02-12"], "first_appearance"=>"2014-08-26", "last_posted_time"=>"2015-02-12T18:11:40.000Z", "last_total_tweets"=>250, "cumulative_total_tweets"=>743, "consecutive_days"=>1, "trend_direction"=>250, "last_count"=>22, "last_retweets"=>70, "last_weighted_count"=>290, "source_urls"=>["http://source.1", "http://new.url.1", "http://new.url.2"], "text"=>["NEW TEXT"], "ranking_algorithm_version"=>"1.0.0", "recurrance"=>true},
               {"url"=>"https://github.com/jquery/jquery.com/issues/88#issuecomment-72400007", "rank"=>290, "appeared_on"=>["2015-02-12"], "first_appearance"=>"2015-02-12", "last_posted_time"=>"2015-02-12T09:43:15.000Z", "last_total_tweets"=>4814, "cumulative_total_tweets"=>4814, "consecutive_days"=>1, "trend_direction"=>4814, "last_count"=>7, "last_retweets"=>4807, "last_weighted_count"=>4877, "source_urls"=>["https://t.co/zEQf6F54p6", "https://t.co/JH3QXm0VHS"], "text"=>["SOME TEXT"], "ranking_algorithm_version"=>"1.0.0", "recurrance"=>true},
               {"url"=>"http://www.dhteumeuleu.com/apparently-transparent", "rank"=>266, "appeared_on"=>["2015-02-12"], "first_appearance"=>"2015-02-12", "last_posted_time"=>"2015-02-12T12:00:37.000Z", "last_total_tweets"=>1978, "cumulative_total_tweets"=>1978, "consecutive_days"=>1, "trend_direction"=>1978, "last_count"=>66, "last_retweets"=>1912, "last_weighted_count"=>2572, "source_urls"=>["http://t.co/v2ZmZEZA69"], "text"=>["SOME TEXT"], "ranking_algorithm_version"=>"1.0.0", "recurrance"=>true},
               {"url"=>"https://medium.com/@iojs/io-js-and-a-node-js-foundation-4e14699fb7be", "rank"=>202, "appeared_on"=>["2015-02-12"], "first_appearance"=>"2015-02-12", "last_posted_time"=>"2015-02-12T15:07:37.000Z", "last_total_tweets"=>1162, "cumulative_total_tweets"=>1162, "consecutive_days"=>1, "trend_direction"=>1162, "last_count"=>75, "last_retweets"=>1087, "last_weighted_count"=>1837, "source_urls"=>["https://t.co/mUBs3l2IZd"], "text"=>["SOME TEXT"], "ranking_algorithm_version"=>"1.0.0", "recurrance"=>true},
               {"url"=>"http://davidwalsh.name/eslint", "rank"=>133, "appeared_on"=>["2015-02-12"], "first_appearance"=>"2015-02-12", "last_posted_time"=>"2015-02-12T18:11:40.000Z", "last_total_tweets"=>763, "cumulative_total_tweets"=>763, "consecutive_days"=>1, "trend_direction"=>763, "last_count"=>59, "last_retweets"=>704, "last_weighted_count"=>1294, "source_urls"=>["http://t.co/fBrOFojLtY", "http://t.co/nVPVQoMOYH"], "text"=>["SOME TEXT"], "ranking_algorithm_version"=>"1.0.0", "recurrance"=>true}]
    expect(the_processor.given(*input_json)).to emit_json(*expected)
  end
  describe "trend direction" do
    context "when this is a first appearance" do
      let(:input_json) { [{"url"=>"http://www.example.com/1234", "count"=>2, "retweets"=>1500, "total_tweets"=>1502, "posted_time"=>"2015-10-01T18:11:40.000Z", "date"=>"2015-10-01", "text"=>["TEXT"], "source_urls"=>["http://t.co/Xbg6VG1EEv"]}] }
      let(:expected_json) { [base_expected_json] }
      it "records the current total_count" do
        expect(subject.first["trend_direction"]).to eq(1502)
      end
    end
    context "when this is a first re-appearance" do
      let(:input_json) { [{"url"=>"http://www.example.com/1234", "count"=>67, "retweets"=>1100, "total_tweets"=>1167, "posted_time"=>"2015-10-01T18:11:40.000Z", "date"=>"2015-10-01", "text"=>["TEXT"], "source_urls"=>["http://t.co/Xbg6VG1EEv"]},
                          {"url"=>"http://www.example.com/1234", "appeared_on"=>["2013-08-02"], "first_appearance"=>"2013-08-02", "last_posted_time"=>"2015-09-30T18:11:40.000Z", "last_total_tweets"=>763, "cumulative_total_tweets"=>763, "source_urls"=>["http://t.co/fBrOFojLtY"], "text"=>["SOME TEXT"]}] }      
      it "records the current total_count" do
        expect(subject.first["trend_direction"]).to eq(1167)
      end
    end
    context "when count is going up" do
      let(:input_json) { [{"url"=>"http://www.example.com/1234", "count"=>67, "retweets"=>1100, "total_tweets"=>1167, "posted_time"=>"2015-10-01T18:11:40.000Z", "date"=>"2015-10-01", "text"=>["TEXT"], "source_urls"=>["http://t.co/Xbg6VG1EEv"]},
                          {"url"=>"http://www.example.com/1234", "appeared_on"=>["2015-09-30"], "first_appearance"=>"2015-09-30", "last_posted_time"=>"2015-09-30T18:11:40.000Z", "last_total_tweets"=>763, "cumulative_total_tweets"=>763, "source_urls"=>["http://t.co/fBrOFojLtY"], "text"=>["SOME TEXT"]}] }
      it "records the sum of the previous total_count and the new one (positive number)" do
        expect(subject.first["trend_direction"]).to eq(1167-763)
      end    
    end
    context "when count is going down" do
      let(:input_json) { [{"url"=>"http://www.example.com/1234", "count"=>12, "retweets"=>100, "total_tweets"=>112, "posted_time"=>"2015-10-01T18:11:40.000Z", "date"=>"2015-10-01", "text"=>["TEXT"], "source_urls"=>["http://t.co/Xbg6VG1EEv"]} ,
                          {"url"=>"http://www.example.com/1234", "appeared_on"=>["2015-09-30"], "first_appearance"=>"2015-09-30", "last_posted_time"=>"2015-09-30T18:11:40.000Z", "last_total_tweets"=>763, "cumulative_total_tweets"=>763, "source_urls"=>["http://t.co/fBrOFojLtY"], "text"=>["SOME TEXT"]}] }
      it "records the sum of the previous total_count and the new one (negative number)" do
        expect(subject.first["trend_direction"]).to eq(112-763)
      end
    end
  end
  context "consecutive days" do
    let(:input_json) { [{"url"=>"http://www.example.com/1234", "count"=>12, "retweets"=>100, "total_tweets"=>112, "posted_time"=>"2015-10-01T18:11:40.000Z", "date"=>"2015-10-01", "text"=>["TEXT"], "source_urls"=>["http://t.co/Xbg6VG1EEv"]},
                        {"url"=>"http://www.example.com/1234", "appeared_on"=>["2015-09-28", "2015-09-29", "2015-09-30"], "consecutive_days"=>"3", "first_appearance"=>"2015-09-30", "last_posted_time"=>"2015-09-30T18:11:40.000Z", "last_total_tweets"=>763, "cumulative_total_tweets"=>763, "source_urls"=>["http://t.co/fBrOFojLtY"], "text"=>["SOME TEXT"]}] }
    it "records the number of consecutive days that the URL has appeared" do
      expect(subject.first["consecutive_days"]).to eq(4)
    end
    context "when the URL has appeared more than the current run of consecutive appeareances" do
      let(:input_json) { [{"url"=>"http://www.example.com/1234", "count"=>12, "retweets"=>100, "total_tweets"=>112, "posted_time"=>"2015-10-01T18:11:40.000Z", "date"=>"2015-10-01", "text"=>["TEXT"], "source_urls"=>["http://t.co/Xbg6VG1EEv"]},
                          {"url"=>"http://www.example.com/1234", "appeared_on"=>["2013-08-02"], "first_appearance"=>"2013-08-02", "last_posted_time"=>"2015-09-30T18:11:40.000Z", "last_total_tweets"=>763, "cumulative_total_tweets"=>763, "source_urls"=>["http://t.co/fBrOFojLtY"], "text"=>["SOME TEXT"]} ] }
      it "marks the URL as recurring" do
        expect(subject.first["consecutive_days"]).to eq(1)
        expect(subject.first["recurrance"]).to eq(true)
      end
    end
  end
  
  
  
end