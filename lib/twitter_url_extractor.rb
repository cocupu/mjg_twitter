require 'json'
require 'uri'
require 'cgi'
# Returns a report on how many times each URL has been tweeted.
# Yields JSON containing key, count, retweets and total tweets.  Example:
#   {"key":"http://nyti.ms/1eaCmuG","count":1,"retweets":95,"total_tweets":96}
Wukong.processor(:mapper) do
  REJECT_SHORTENED_IF = [/svg/i, /css/i, /D3JS/i]
  ACCEPT_SHORTENED_IF_EXPANDED_HAS = [/css/i,/svg/i]
  REJECT_EXPANDED_IF = [/instagram.com\/p/,/\/photo\//,
    /cSS/,/cSs/,/csS/,/Css/,/CSs/,/CsS/,/sVG/,/sVg/,/svG/,/Svg/,/SVg/,/SvG/, /.jpg$/, /.gif$/, /.svg$/, /.png$/]
  ACCEPT_IF_BODY_HAS = [/(\bcss3|html5|svg|SVG|HTML5|CSS\b)+|https?:\/\/(www.)?\w+.\w+\/(-css3|html5|svg-)/i]

  field :invert_filters, String, default:false

  def process record
    # url_entities =  record.fetch("object",{}).fetch("twitter_entities", {}).fetch("urls", [])
    url_entities =  record.fetch("gnip",{}).fetch("urls", [])
    if !url_entities.empty? && validate_record(record)
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
    # if match_against(record["body"],ACCEPT_IF_BODY_HAS)
    #   return true
    # end
    result = true
    if match_against(record["body"],REJECT_EXPANDED_IF)
      result = false
    else
      record.fetch("gnip", {}).fetch("urls", []).each do |url_entity|
        if result
          result = validate_entity(url_entity, record) 
        end
      end
      record.fetch("object",{}).fetch("twitter_entities", {}).fetch("urls", []).each do |url_entity|
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
  def validate_entity(url_entity, record)
    valid = true
    body_minus_urls = record["body"].gsub(url_entity["url"],"").gsub(url_entity["expanded_url"],"")  
    if match_against(body_minus_urls,ACCEPT_IF_BODY_HAS)
      return true
    end
    if match_against(url_entity["expanded_url"],REJECT_EXPANDED_IF)
      return false
    elsif match_against(url_entity["url"],REJECT_SHORTENED_IF)
      body_minus_short_url = record["body"].gsub(url_entity["url"],"")
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

Wukong.processor(:reducer, Wukong::Processor::Accumulator) do

  attr_accessor :count, :retweets, :text, :source_urls, :posted_time, :date

  field :include_debug_info, String, default:false
  
  # Group records based on matching url values
  def get_key(record)
    record["url"]
  end
  
  def start record
    self.count = 0
    self.retweets = 0
    self.text = []
    self.source_urls = []
  end
  
  def accumulate record
    self.count += 1
    self.retweets += record["retweets"].to_i
    self.text << record["body"] unless self.text.include? record["body"]
    self.source_urls << record["source_urls"] unless self.source_urls.inlcude? record["source_urls"]
    self.posted_time = record["posted_time"]
    self.date = Date.parse(record["posted_time"])
  end

  def finalize
    if  include_debug_info
      to_return = {url:key, count:count, retweets:retweets, total_tweets:count+retweets, posted_time: posted_time, date:date, text:text, source_urls:source_urls}
    else
      to_return = {url:key, count:count, retweets:retweets, total_tweets:count+retweets, posted_time: posted_time, date:date}
    end
    yield JSON.generate(to_return)
  end
end
