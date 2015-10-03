require 'active_support'
require "active_support/core_ext"
require 'yaml'
autoload :Gnip, File.dirname(__FILE__)+'/gnip'
autoload :GnipHptDownloader, File.dirname(__FILE__)+'/gnip_hpt_downloader'
autoload :ReportPublisher, File.dirname(__FILE__)+'/report_publisher'
autoload :BaseRunner, File.dirname(__FILE__)+'/runners/base_runner'
autoload :ExtractionRunner, File.dirname(__FILE__)+'/runners/extraction_runner'
autoload :UrlDatasetReducerRunner, File.dirname(__FILE__)+'/runners/url_dataset_reducer_runner'
autoload :UsesBlacklist, File.dirname(__FILE__)+'/concerns/uses_blacklist'


