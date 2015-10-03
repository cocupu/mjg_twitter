require 'json'
require 'uri'
require 'cgi'
lib_dir = File.expand_path(File.dirname(__FILE__)+"../..")
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require 'concerns/uses_blacklist'

# extract url references from tweet data
Wukong.processor(:map_tweets_to_urls) do
  include UsesBlacklist

  REJECT_SHORTENED_IF = [/svg/i, /css/i, /D3JS/i]
  ACCEPT_SHORTENED_IF_EXPANDED_HAS = [/css/i,/svg/i]
  REJECT_EXPANDED_IF = [/instagram.com\/p/,/\/photo\//,
    /cSS/,/cSs/,/csS/,/Css/,/CSs/,/CsS/,/sVG/,/sVg/,/svG/,/Svg/,/SVg/,/SvG/, /.jpg$/, /.gif$/, /.svg$/, /.png$/]
  ACCEPT_IF_BODY_HAS = [/(\bcss3|html5|svg|SVG|HTML5|CSS\b)+|https?:\/\/(www.)?\w+.\w+\/(-css3|html5|svg-)/i]

  field :invert_filters, String, default:false

  def process record
    url_entities =  record.fetch("gnip",{}).fetch("urls", [])
    if !url_entities.empty? && validate_record(record)
      if url_entities.length > 1
        # evaluate entities individually in a more strict fashion to keep only the good ones from each tweet
        # This filters out things like links to images that were included in a tweet that has a valid URL
        filtered_entities = url_entities.select {|url_entity| validate_entity(url_entity) }
        if filtered_entities.empty?
          # puts "WARN: filtered all entities out of #{url_entities}.  It looked like good content, but all of the associated URLs failed filters."
        end
        url_entities = filtered_entities   
      end
      url_entities.each do |url_entity|
        unless url_entity["expanded_url"].nil?
          extracted = {"url" => normalize_url(url_entity["expanded_url"]), "posted_time"=>record["postedTime"], "retweets"=>record["retweetCount"], "body"=>record["body"], "source_urls"=>url_entity["url"]}
          yield extracted.to_json
        end
      end
    end
  end
  
  def validate_record(record)    
    unless record.fetch("gnip", {}).fetch("language", {"value"=>"en"})["value"] == "en"
      return false 
    end

    result = true
    
    if match_against(record["body"],REJECT_EXPANDED_IF)
      result = false
    elsif record.fetch("gnip",{}).fetch("urls", []).length == 1 && contains_blacklisted_urls?(record)
      result = false
    elsif match_against(tweet_body_minus_urls(record),ACCEPT_IF_BODY_HAS)
      result = true 
    else
      url_entities_from(record).each do |url_entity|
        if result
          result = validate_entity(url_entity, record) 
        end
      end
    end
    if invert_filters
      return !result
    else
      return result
    end
  end
  
  # returns true if the entity is valid.  Returns false if entity is invalid
  def validate_entity(url_entity, record=nil)
    valid = true
    
    if matches_blacklist?(normalize_url(url_entity["expanded_url"]))
      return false
    elsif match_against(url_entity["expanded_url"],REJECT_EXPANDED_IF)
      return false
    elsif match_against(url_entity["url"],REJECT_SHORTENED_IF)
      if match_against(url_entity["expanded_url"],ACCEPT_SHORTENED_IF_EXPANDED_HAS)
        return true
      else  
        return false
      end
    else
      return true
    end
  end
  
  def match_against(field_value,expressions)
    matched = false
    expressions.each do |expr|
      if expr.match(field_value)
        matched = true
      end
    end
    return matched
  end
  
  def tweet_body_minus_urls(record)
    body_minus_urls = record["body"]
    url_entities_from(record).each do |url_entity|
      body_minus_urls = body_minus_urls.gsub(url_entity["url"],"").gsub(url_entity["expanded_url"],"")  
    end
    return body_minus_urls      
  end
  
  def contains_blacklisted_urls?(record)
    result = false
    url_entities_from(record).each do |url_entity|
      if matches_blacklist?(normalize_url(url_entity["expanded_url"]))
        result = true
      end
    end
    return result
  end
  
  def url_entities_from(record)
    url_entities = []
    url_entities += record.fetch("gnip", {}).fetch("urls", [])
    url_entities += record.fetch("object",{}).fetch("twitter_entities", {}).fetch("urls", [])
    return url_entities
  end

  def normalize_url(url)
    uri = URI.parse(URI.encode(url))
    components = Hash[uri.component.map { |key| [key, uri.send(key)] }]
    components.delete(:port) if [443,80].include?(components[:port])
    components[:host].downcase!
    if uri.query
      hquery = CGI::parse(uri.query)
      new_hquery = hquery.select {|k,v| !k.include?("utm_")}
      new_query = new_hquery.empty? ? nil : URI.encode_www_form(new_hquery)
      components.merge!({path: uri.path, query: new_query})
    end
    new_uri = URI::Generic.build(components)
    return URI.decode(new_uri.to_s).gsub(/\/$/, "")
  end
end