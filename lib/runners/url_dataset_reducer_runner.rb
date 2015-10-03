require 'fileutils'
require 'date'
class UrlDatasetReducerRunner < BaseRunner
  
  def process
    puts "Merging urls from #{expression_for_files_to_import} into #{output_dataset_path}"
    FileUtils::mkdir_p output_directory
    puts "Importing data from #{output_dataset_path} into dat repository at #{dat_repository_path}"
    
    %x(cat #{expression_for_files_to_import} | bundle exec wu-hadoop #{reducer_path} #{reducer_flags} | wu-local sort --on=cumulative_total_tweets --numeric --reverse > #{destination_path})
  end
  
  private
  
  def default_output_directory
    Dir.pwd+"/output/tmp/reducer"
  end
  
  def default_output_file
    "/#{Date.today.strftime("%Y_%m_%d")}-merged.json"
  end
  
  def reducer_path
    File.join(File.dirname(__FILE__),"url_dataset_reducer.rb")
  end
  
  def reducer_flags
    '--mode=local --from=json'
  end

  
end
