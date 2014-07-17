require 'spec_helper'

describe ReportPublisher do
  let(:bindery_opts) { {email:"archivist@example.com", identity:"my_identity", host:"myhost", password:"mypass", pool:"the_pool", model_id:45} }

  describe "publish_reports" do
    it "" do
      allow(subject).to receive(:bindery_opts).and_return(bindery_opts)
      paths_to_reports = [fixture_file_path("linkReport-10items.json"), fixture_file_path("linkReport-10items.json")]
      expect(Cocupu).to receive(:start).with("archivist@example.com", "mypass", 80, "myhost")
      paths_to_reports.each do |path_to_report|
        expect(subject).to receive(:publish_report_to_databindery).with(path_to_report, bindery_opts)
        expect(subject).to receive(:convert_ndj_to_json).with(path_to_report)
      end
      subject.publish_reports(paths_to_reports)
    end
  end

  describe "publish_report_to_databindery" do
    it "should create DataBindery node from each line in report" do
      path_to_report = fixture_file_path("linkReport-10items.json")
      expect(Cocupu::Node).to receive(:new).exactly(10).times.and_return(double("Node", save:true))
      subject.publish_report_to_databindery(path_to_report, bindery_opts)
    end
  end
end