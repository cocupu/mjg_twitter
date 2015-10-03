# Base class for Runners
class BaseRunner

  attr_accessor :output_directory
  
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
  
end
