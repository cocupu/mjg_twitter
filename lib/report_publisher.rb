class ReportPublisher

  attr_writer :publish_to

  def publish_reports(paths_to_reports)
    FileUtils.cp paths_to_reports, publish_to
    puts "Published #{paths_to_reports.length} reports to #{publish_to}"
  end

  def publish_to
    @publish_to ||= "/opt/cocupu/public/mjg_twitter"
  end
end