class ReportPublisher

  attr_writer :publish_to
  attr_accessor :message

  def publish_reports(paths_to_reports)
    paths_to_reports.each do |path_to_report|
      convert_ndj_to_json(path_to_report)
    end
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

  # Replaces newlines with commas.  Wraps the entire file's contents with square brackets.
  def convert_ndj_to_json(path_to_report)
    tmp_path =  path_to_report+".tmp"
    %x(printf '%s' "[" |cat - #{path_to_report} | tr '\n' ',' | sed '$s/,$/]/' > #{tmp_path})
    %x(mv #{tmp_path} #{path_to_report})
  end
end