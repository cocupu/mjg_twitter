require 'yaml'
module UsesBlacklist
  
  def blacklist
    @blacklist ||= load_blacklist_terms
  end
  
  def blacklisted_urls
    @blacklist_urls ||= load_blacklisted_urls
  end
  
  # Returns true if content matches anything in the blacklist
  def matches_blacklist?(content)
    if blacklisted_urls.include?(content)
      return true
    else
      matches = false
      blacklist_regexp.each do |expr|
        if expr.match(content)
          matches = true
          puts "#{content} matched #{expr.inspect}"
          break
        end
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
  

  def load_blacklist_terms
    blacklist_yml_path = File.dirname(__FILE__)+'/../../config/blacklist.yml'
    blacklist_yml = YAML.load(File.read(blacklist_yml_path))
    return blacklist_yml
  end
  
  def load_blacklisted_urls
    blacklist_yml_path = File.dirname(__FILE__)+'/../../config/blacklisted_urls.yml'
    blacklist_yml = YAML.load(File.read(blacklist_yml_path))
    return blacklist_yml
  end
  
  
end