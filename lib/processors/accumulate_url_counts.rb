require 'json'

# Count url references, accumulating info like tweet_counts, etc. 
# Yields one JSON line for each URL that appears in the input data
#  JSON contains url, count, retweets and total tweets.  Example:
#   {"url":"http://nyti.ms/1eaCmuG","count":1,"retweets":95,"total_tweets":96}
#  If you set +include_debug_info+ to true, you also get :text of the original tweets and :source_urls
Wukong.processor(:accumulate_url_counts, Wukong::Processor::Accumulator) do

  attr_accessor :count, :retweets, :text, :source_urls, :posted_time, :date, :the_record

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
    self.posted_time = record["posted_time"]
    begin
      date = Date.parse(record["posted_time"])
      self.date = date
    rescue
      # do nothing
    end
    unless self.text.include? record["body"]
      self.text << record["body"] #unless self.text.include? record["body"]
    end
    unless self.source_urls.include? record["source_urls"]
      self.source_urls << record["source_urls"] #unless self.source_urls.inlcude? record["source_urls"]
    end
  end

  def finalize
    if  include_debug_info
      to_return = {url:key, weighted_count:count*10+retweets, count:count, retweets:retweets, total_tweets:count+retweets, posted_time: posted_time, date:date, text:text, source_urls:source_urls}
    else
      to_return = {url:key, weighted_count:count*10+retweets, count:count, retweets:retweets, total_tweets:count+retweets, posted_time: posted_time, date:date}
    end
    yield JSON.generate(to_return)
  end
end