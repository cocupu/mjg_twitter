require 'spec_helper'
require 'json'
require File.dirname(__FILE__)+'/../../lib/twitter_url_extractor'

"It should be matching individual words or keywords in a URL only."
"If you match SVG|CSS3|HTML5 then look behind and ahead and don't see a Space, dash, end of the tweet or punctuation (period, comma, quotes) on either side then dump the result."
# DUMP:
# http://t.co/KF07BSVGKe
# http://t.co/KF07BSVcsv
# thecsvanthology
# 
# KEEP:
# the-csv-anthology
# thecsv anthology
# the.csv anthology
# the csv.anthology
# thecsv,

# reg.test("I love this thing about SVG. http://foo.com/article"); // true
# reg.test("This is awesome http://super-awesome-svg.com"); // true
# reg.test("I <3 this css3 button thing http://codepen.com/abcdefg"); // true
# reg.test("This is a thing we are testing. It should not match this http://t.co/ifesVgief"); // false
# reg.test("Boogy buggy booger. It should not match this http://t.co/ewfijCSs3few"); // false

describe :mapper do
  let(:input_file) { File.open(File.dirname(__FILE__)+'/../sample_data/gnipSampleTweets.json') }
  let(:records) { input_file.to_a.map {|l| JSON.parse(l)} }
  it_behaves_like 'a processor', :named => :mapper
  it "should pass through the relevant fields" do
    # expected = {"url" => @record1["gnip"]["urls"].first["expanded_url"].downcase, "posted_time"=>@record1["postedTime"], "retweets"=>@record1["retweetCount"], "body"=>@record1["body"], "source_urls"=>@record1["gnip"]["urls"].first["url"]}
    expected = {"url"=>"https://web.archive.org/web/20070916144913/http://wp.netscape.com/newsref/pr/newsrelease67.html","posted_time"=>"2013-12-15T21:39:04.000Z","retweets"=>274,"body"=>"RT @samth: Today in 1995: \"NETSCAPE AND SUN ANNOUNCE JAVASCRIPT, THE OPEN, CROSS-PLATFORM OBJECT SCRIPTING LANGUAGE\" https://t.co/DPDngGu4UR","source_urls"=>"https://t.co/DPDngGu4UR"}
    processor.given(records.first).should emit(expected.to_json)
  end
  it "should filter records" do
    processor.given(records.first).should emit(1).records
    processor.given(records[1]).should emit(1).records
    processor.given(records[2]).should emit(0).records
    processor.given(records[3]).should emit(0).records
    processor.given(records[4]).should emit(0).records
    processor.given(records[5]).should emit(1).records
    processor.given(records[6]).should emit(1).records
    processor.given(records[7]).should emit(0).records
    processor.given(records[8]).should emit(0).records
    processor.given(records[9]).should emit(0).records
  end
end

describe :reducer do
  it_behaves_like 'a processor', :named => :reducer
end