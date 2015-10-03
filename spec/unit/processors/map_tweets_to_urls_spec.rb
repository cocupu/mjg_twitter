require 'spec_helper'
require 'json'
# require File.dirname(__FILE__)+'/../../lib/twitter_url_extractor'

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


describe :map_tweets_to_urls do
  let(:input_file) { File.open(File.dirname(__FILE__)+'/../../sample_data/gnipSampleTweets.json') }
  let(:records) { input_file.to_a.map {|l| JSON.parse(l)} }
  it_behaves_like 'a processor', :named => :map_tweets_to_urls
  it "should pass through the relevant fields" do
    # expected = {"url" => @record1["gnip"]["urls"].first["expanded_url"].downcase, "posted_time"=>@record1["postedTime"], "retweets"=>@record1["retweetCount"], "body"=>@record1["body"], "source_urls"=>@record1["gnip"]["urls"].first["url"]}
    expected = {"url"=>"https://web.archive.org/web/20070916144913/http://wp.netscape.com/newsref/pr/newsrelease67.html","posted_time"=>"2013-12-15T21:39:04.000Z","retweets"=>274,"body"=>"RT @samth: Today in 1995: \"NETSCAPE AND SUN ANNOUNCE JAVASCRIPT, THE OPEN, CROSS-PLATFORM OBJECT SCRIPTING LANGUAGE\" https://t.co/DPDngGu4UR","source_urls"=>"https://t.co/DPDngGu4UR"}
    expect(processor.given(records.first)).to emit(expected.to_json)
  end
  it "should strip utm_ values from urls" do
    expected = {"url"=>"https://blahblah.com","posted_time"=>"2014-08-27T15:39:13.000Z","retweets"=>312,"body"=>"RT @vidtok: #HTML5 built, Sign up for a free trial of @vidtok live video chat. Use promo code \"TW2014\" for an extra 10% off. http://t.co/w7", "source_urls"=>"http://t.co/w7cjXaZewJ"}
    expect(processor.given(records[10])).to emit(expected.to_json)
  end
  it "should preserve case variation in urls" do
    expected = {"url"=>"http://haxiomic.github.io/GPU-Fluid-Experiments/html5","posted_time"=>"2014-11-18T21:39:04.000Z","retweets"=>876,"body"=>"Wow, this is neat - and beautiful http://t.co/ITcw3JKGqV Fluid dynamics simulator using HTML5 \u0026amp; WebGL, GPLv3 #freesoftware", "source_urls"=>"http://t.co/ITcw3JKGqV"}
    expect(processor.given(records[13])).to emit(expected.to_json)
  end
  it "should keep the records we want" do
    expect(processor.given(records.first)).to emit(1).records
    expect(processor.given(records[1])).to emit(1).records
    expect(processor.given(records[5])).to emit(1).records
    expect(processor.given(records[6])).to emit(1).records
    expect(processor.given(records[15])).to emit(1).records
  end
  it "should filter out false matches on css, svg, etc." do
    expect(processor.given(records[2])).to emit(0).records
    expect(processor.given(records[3])).to emit(0).records
    expect(processor.given(records[4])).to emit(0).records
    expect(processor.given(records[7])).to emit(0).records
    expect(processor.given(records[8])).to emit(0).records
  end
  it "should reject non-english tweets" do
    expect(processor.given(records[9])).to emit(0).records
  end
  it "should filter per-url when record has multiple urls" do
    # Should not emit the url "http://twitter.com/8Grids/status/501170066730520576/photo/1", but should emit the url "http://8grids.com/portfolio/peak-wordpress-theme"
    expected = {"url"=>"http://wp.netscape.com/newsref/pr/newsrelease67.html","posted_time"=>nil,"retweets"=>274,"body"=>"This tweet has two urls but only one is good!  #HTML5 #CSS3 http://t.co/30yTwXoz","source_urls"=>"http://t.co/R3akWujGaB"}
    puts records[11]
    expect(processor.given(records[11])).to emit(expected.to_json)
  end
  it "filters out urls that match the blacklisted patterns" do
    expect(processor.given(records[12])).to emit(0).records
  end
  it "filters out urls that have been specifically blacklisted" do
    expect(processor.given(records[14])).to emit(0).records
  end
end