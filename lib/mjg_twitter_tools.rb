require 'active_support'
require "active_support/core_ext"
autoload :Gnip, File.dirname(__FILE__)+'/gnip'
autoload :GnipHptDownloader, File.dirname(__FILE__)+'/gnip_hpt_downloader'
autoload :ReportPublisher, File.dirname(__FILE__)+'/report_publisher'
autoload :ExtractionRunner, File.dirname(__FILE__)+'/extraction_runner'


