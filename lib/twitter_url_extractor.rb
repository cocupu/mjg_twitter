require 'json'
# Returns a report on how many times each URL has been tweeted.
# Yields JSON containing key, count, retweets and total tweets.  Example:
#   {"key":"http://nyti.ms/1eaCmuG","count":1,"retweets":95,"total_tweets":96}
Wukong.processor(:mapper) do
  REJECT_SHORTENED_IF = [/svg/i, /css/i, /D3JS/i]
  ACCEPT_SHORTENED_IF_EXPANDED_HAS = [/css/,/CSS/,/svg/, /SVG/]
  REJECT_EXPANDED_IF = [/instagram.com\/p/,/\/photo\//,
    /cSS/,/cSs/,/csS/,/Css/,/CSs/,/CsS/,/sVG/,/sVg/,/svG/,/Svg/,/SVg/,/SvG/]
  ACCEPT_IF_BODY_HAS = [/(\bcss3|html5|svg\b)+|https?:\/\/(www.)?\w+.\w+\/(-css3|html5|svg-)/i]

  field :invert_filters, String, default:false

  def process record
    url_entities = []
    bad_entities = []
    begin
      if record.has_key?("gnip")
        url_entities = record["gnip"]["urls"]
      else
        url_entities = [{"expanded_url"=>"BAD_RECORD",  "retweetCount"=>"0", "body"=>record }]
      end
    end
    if validate_record(record)
      url_entities.each do |url_entity|
        extracted = {"url" => url_entity["expanded_url"], "posted_time"=>record["postedTime"], "retweets"=>record["retweetCount"], "body"=>record["body"], "source_urls"=>url_entity["url"]}
        yield extracted.to_json
      end
    end
  end
  
  def validate_record(record)
    # result = match_against(record["body"],ACCEPT_IF_BODY_HAS)
    unless record.has_key?("gnip") && record["gnip"].has_key?("urls")
      puts "no GNIP urls data"
      return false
    end
    unless record.has_key?("object") && record["object"].has_key?("twitter_entities") && record["object"]["twitter_entities"].has_key?("urls") && record["object"]["twitter_entities"]["urls"]
      puts "no object data"
      return false
    end
    result = true
    if match_against(record["body"],REJECT_EXPANDED_IF)
      result = false
    else
      record["gnip"]["urls"].each do |url_entity|
        if result
          result = validate_entity(url_entity) 
        end
      end
      record["object"]["twitter_entities"]["urls"].each do |url_entity|
        if result
          result = validate_entity(url_entity) 
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
  def validate_entity(url_entity)
    valid = true
    if match_against(url_entity["expanded_url"],REJECT_EXPANDED_IF)
      return false
    elsif match_against(url_entity["url"],REJECT_SHORTENED_IF)
      unless match_against(url_entity["expanded_url"],ACCEPT_SHORTENED_IF_EXPANDED_HAS)
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
end

Wukong.processor(:reducer, Wukong::Processor::Accumulator) do

  attr_accessor :count, :retweets, :text, :source_urls, :posted_time

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
    self.text << record["body"]
    self.source_urls << record["source_urls"]
    self.posted_time = record["posted_time"]
  end

  def finalize
    if  include_debug_info
      to_return = {url:key, count:count, retweets:retweets, total_tweets:count+retweets, posted_time: posted_time, text:text, source_urls:source_urls}
    else
      to_return = {url:key, count:count, retweets:retweets, total_tweets:count+retweets, posted_time: posted_time}
    end
    yield JSON.generate(to_return)
  end
end
