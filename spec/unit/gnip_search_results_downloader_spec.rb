require 'spec_helper'

describe ExtractionRunner do
  
  let(:subject) { Gnip::SearchResultsDownloader.new(start_date:"20131227",end_date:"20131228",data_directory:"download_test") }
  describe "download_latest_results" do
    it "should download all activities corresponding to the given dates, writing them to corresponding directories" do
      expect(subject.searcher).to receive(:download_into).with("data/download_test/2013_12_27", query:Gnip::Searcher.default_rules, from:"201312270000", to:"201312280000", max:500)
      expect(subject.searcher).to receive(:download_into).with("data/download_test/2013_12_28", query:Gnip::Searcher.default_rules, from:"201312280000", to:"201312290000", max:500)
      subject.download_latest_results
    end
  end
  it "should expose download_dir_path" do
    expect(subject.download_dir_path).to eq("data/download_test")
  end
  
end
