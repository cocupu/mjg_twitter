require 'spec_helper'

describe ReportPublisher do
  let(:bindery_opts) { {email:"archivist@example.com", identity:"my_identity", host:"myhost", password:"mypass", pool:"the_pool", model_id:45} }
  let(:bindery_model) { Cocupu::Model.new("fields"=>[{"id"=>"101", "code"=>"url"}, {"id"=>"102", "code"=>"count"}, {"id"=>"102", "code"=>"retweets"}, {"id"=>"102", "code"=>"total_tweets"}, {"id"=>"102", "code"=>"text"}, {"id"=>"102", "code"=>"source_urls"}]) }

  describe "publish_reports" do
    it "should publish to DataBindery" do
      allow(subject).to receive(:bindery_opts).and_return(bindery_opts)
      paths_to_reports = [fixture_file_path("linkReport-10items.json"), fixture_file_path("linkReport-10items.json")]
      expect(Cocupu).to receive(:start).with("archivist@example.com", "mypass", 80, "myhost")
      paths_to_reports.each do |path_to_report|
        expect(subject).to receive(:publish_report_to_databindery).with(path_to_report, bindery_opts)
        # expect(subject).to receive(:convert_ndj_to_json).with(path_to_report)
      end
      subject.publish_reports(paths_to_reports)
    end
  end

  describe "publish_report_to_databindery" do
    before do
      allow(Cocupu::Model).to receive(:load).with(bindery_opts[:model_id]).and_return(bindery_model)
    end
    it "should batch import the items from json file" do
      path_to_report = fixture_file_path("linkReport-10items.json")
      file = File.open(path_to_report)
      urls = []
      file.each_line do |line|
        urls << JSON.parse(line)
      end
      converted_data = bindery_model.convert_data_keys(urls)
      expect(Cocupu::Node).to receive(:import).with('identity'=>bindery_opts[:identity], 'pool'=>bindery_opts[:pool], "model_id"=>bindery_opts[:model_id], "data"=>converted_data)
      subject.publish_report_to_databindery(path_to_report, bindery_opts)
    end
  end
end