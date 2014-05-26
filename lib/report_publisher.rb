class ReportPublisher

  attr_writer :publish_to

  def publish_reports(paths_to_reports)
    FileUtils.cp paths_to_reports,
  end

  def publish_to
    @publish_to ||= "/opt/cocupu/public/mjg_twitter"
  end
end