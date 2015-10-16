# Base class for Runners
class BaseRunner

  attr_accessor :output_directory, :start_date, :end_date
  
  def process
    # implement this in subclasses
  end
  
  def default_output_directory
    Dir.pwd+"/output"
  end
  
  def default_output_file
    "/#{Date.today.strftime("%Y_%m_%d")}-processed.json"
  end
  
  def destination_path
    File.join(output_directory, default_output_file)
  end
  
  def output_directory
    @output_directory ||= default_output_directory
  end
  
  def dates_to_process
    start_date.upto(end_date)
  end
  
  def start_date
    @start_date ||= DateTime.strptime(today_string, "%Y%m%d")
  end
  
  def end_date
    @end_date ||= DateTime.strptime(today_string, "%Y%m%d") 
  end
  
  def today_string
    @today_string ||= Time.now.strftime("%Y%m%d")
  end
  
end
