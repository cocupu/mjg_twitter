class ReportPublisher

  attr_writer :publish_to
  attr_accessor :message

  def publish_reports(paths_to_reports)
    FileUtils.cp paths_to_reports, publish_to
    message = "Published #{paths_to_reports.length} reports to #{publish_to}"
  end

  def publish_to
    @publish_to ||= "/opt/cocupu/public/mjg_twitter"
    begin
      FileUtils::mkdir_p @publish_to
    rescue
      @publish_to = "./output/reports"
      FileUtils::mkdir_p @publish_to
    end
  end
end