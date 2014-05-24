require 'spec_helper'
require 'json'

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

describe :twitter_url_mapper do
  it_behaves_like 'a processor', :named => :twitter_url_mapper
  it "should filter records" do
    json_file = File.open(File.dirname(__FILE__)+'/../sample_data/2013_12_15_08_40_activities.json')
    processor.given(JSON.parse(json_file.readline)).should emit(6).records
  end
end

describe :twitter_url_reducer do
  it_behaves_like 'a processor', :named => :twitter_url_reducer
end