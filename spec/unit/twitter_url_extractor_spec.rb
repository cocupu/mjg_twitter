require 'spec_helper'
require 'json'

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