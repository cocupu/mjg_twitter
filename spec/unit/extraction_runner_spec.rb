require 'spec_helper'

describe ExtractionRunner do
  let(:source_dir_path) {File.dirname(__FILE__)+'/../sample_data/20131215'}
  let(:subject) {ExtractionRunner.new(source_dir_path:source_dir_path, start_date:"20131227", end_date:"20131228")}
  describe "process" do
    it "should process all of the files corresponding to the given dates"
    it "should reduce/group urls properly"
  end
end
