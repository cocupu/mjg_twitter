require 'fileutils'
require 'json'
require 'cocupu'

class ReportPublisher

  attr_writer :publish_to
  attr_accessor :message

  # @example
  #   paths_to_reports = ["/tmp/reports/foo1.json", "/tmp/reports/foo2.json"]
  #   bindery_opts = {email:"archivist@example.com", identity:"my_identity", pool:"the_pool", model_id:45}
  #   publish_report_to_databindery(paths_to_reports, bindery_opts)
  def publish_reports(paths_to_reports)
    port = bindery_opts[:port] ? bindery_opts[:port] : 80
    Cocupu.start(bindery_opts[:email], bindery_opts[:password], port, bindery_opts[:host])
    paths_to_reports.each do |path_to_report|
      puts "Publishing #{path_to_report} to DataBindery"
      publish_report_to_databindery(path_to_report, bindery_opts)
      #convert_ndj_to_json(path_to_report)
    end
    FileUtils.cp paths_to_reports, publish_to
    message = "Published #{paths_to_reports.length} reports to #{publish_to} and #{bindery_opts[:identity]}/#{bindery_opts[:pool]} on DataBindery"
  end

  # @example
  #   publish_report_to_databindery("/tmp/reports/foo.json", email:"archivist@example.com", identity:"my_identity", pool:"the_pool", model_id:45)
  def publish_report_to_databindery(path_to_report, bindery_opts)
    file = File.open(path_to_report)
    urls = []
    file.each_line do |line|
      begin
        urls << JSON.parse(line)
      rescue => e
        puts "Bad line: "+ line
      end
    end
    Cocupu::Node.import({'identity'=>bindery_opts[:identity], 'pool'=>bindery_opts[:pool], "model_id"=>bindery_opts[:model_id], "data"=>urls})
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

  def bindery_opts
    @bindery_opts ||= {:email => config["email"], :password => config["password"], :identity => config["identity"],:pool => config["pool"], :model_id => config["model_id"], :port => config["port"], :host => config["host"]}
  end

  # Replaces newlines with commas.  Wraps the entire file's contents with square brackets.
  def convert_ndj_to_json(path_to_report)
    tmp_path =  path_to_report+".tmp"
    %x(printf '%s' "[" |cat - #{path_to_report} | tr '\n' ',' | sed '$s/,$/]/' > #{tmp_path})
    %x(mv #{tmp_path} #{path_to_report})
  end

  def config
    @config ||= load_config
  end

  def load_config
    environment = ENV['environment'].nil? ? "development" : ENV['environment']
    bindery_yml_path = File.dirname(__FILE__)+'/../config/databindery.yml'
    bindery_yml = YAML.load(File.read(bindery_yml_path))
    config = bindery_yml[environment] || {}
  end

end