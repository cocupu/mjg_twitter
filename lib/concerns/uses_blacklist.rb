module UsesBlacklist
  
  def blacklist
    @blacklist ||= load_blacklist
  end
  
  # Returns true if content matches anything in the blacklist
  def matches_blacklist?(content)
    matches = false
    blacklist_regexp.each do |expr|
      if expr.match(content)
        matches = true
        puts "#{content} matched #{expr.inspect}"
        break
      end
    end
    return matches
  end
  
  
  # Returns an array of regular expressions representing the blacklist
  def blacklist_regexp
    blacklist.map do |match_string| 
      match_string = match_string.gsub('/','\/').gsub('.','\.')
      /#{match_string}/
    end
  end
  

  def load_blacklist
    blacklist_yml_path = File.dirname(__FILE__)+'/../../config/blacklist.yml'
    blacklist_yml = YAML.load(File.read(blacklist_yml_path))
    return blacklist_yml
  end
  
  
end