require 'fileutils'
require 'json'
require 'cocupu'

class ReportPublisher

  attr_writer :publish_to
  attr_accessor :message

  # @option [String] start_at commit reference to start diff from (optional)
  # @option [String] stop_at commit reference to stop diff at (optional)
  def self.publish_from_dat(dat, options={})
    port = bindery_opts[:port] ? bindery_opts[:port] : 80
    Cocupu.start(bindery_opts[:email], bindery_opts[:password], port, bindery_opts[:host])
    puts "publishing from local dat at #{dat.dir} to remote dat at #{bindery_opts[:dat]}"    
    dat.push(remote: bindery_opts[:dat])
    # This assumes that the pool is configured to read from the dat at bindery_opts[:dat]
    if options[:start_at]
      source_params = {dat: {from: options[:start_at]}}
      source_params[:dat][:to] = options[:stop_at] if options[:stop_at]
    else  
      source_params = :dat 
    end
    puts "updading databindery pool index at http://#{bindery_opts[:host]}:#{bindery_opts[:port]}/api/v1/pools/#{bindery_opts[:pool]}}"
    Cocupu::PoolIndex.update(pool_id: bindery_opts[:pool_id], index_name: 'live', source: source_params)
    message = "Published data to http://#{bindery_opts[:host]}:#{bindery_opts[:port]}/api/v1/pools/#{bindery_opts[:pool]}"
  end

  def self.bindery_opts
    @bindery_opts ||= {:email => config["email"], :password => config["password"], :identity => config["identity"], :pool_id => config["pool_id"], :model_id => config["model_id"], :dat => config["dat"], :port => config["port"], :host => config["host"]}
  end

  def self.config
    @config ||= load_config
  end

  def self.load_config
    environment = ENV['environment'].nil? ? "development" : ENV['environment']
    bindery_yml_path = File.dirname(__FILE__)+'/../config/databindery.yml'
    bindery_yml = YAML.load(File.read(bindery_yml_path))
    config = bindery_yml[environment] || {}
  end

end