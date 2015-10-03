require 'json'

Wukong.processor(:mapper) do
  def process record
    yield record.to_json
  end
end


Wukong.processor(:reducer, Wukong::Processor::Accumulator) do
  
  attr_accessor :has_updates, :last_posted_time, :last_total_tweets, :last_count, :last_retweets, :last_weighted_count, :cumulative_total_tweets, :text, :source_urls, :appeared_on
  
  field :accumulate_history, String, default:false
  
  # Group records based on matching url values
  def get_key(record)
    record["url"]
  end
  
  def start record
    self.cumulative_total_tweets = 0 
    self.source_urls = []
    self.appeared_on = []  
    self.has_updates = false  
  end
  
  def accumulate record
    self.source_urls += record["source_urls"] if record["source_urls"]
    if record["posted_time"]
      self.has_updates = true
      self.cumulative_total_tweets += record["total_tweets"]
      self.appeared_on << record["date"] unless self.appeared_on.include? record["date"]
      self.last_posted_time = record["posted_time"]
      self.last_total_tweets = record["total_tweets"]
      self.last_count = record["count"]
      self.last_retweets = record["retweets"]
      self.text = record["text"]
      self.last_weighted_count = last_count*10+last_retweets
    else
      self.cumulative_total_tweets += record["cumulative_total_tweets"]
      self.appeared_on += record["appeared_on"]
    end
  end
  
  def finalize
    # Only return records that were actually updated by this reduce operation
    if has_updates || accumulate_history
      yield JSON.generate({
        url: key, 
        appeared_on: appeared_on.sort,
        first_appearance: appeared_on.sort.first,
        last_posted_time: last_posted_time, 
        last_total_tweets: last_total_tweets,
        last_count: last_count,
        last_retweets: last_retweets,
        last_weighted_count: last_weighted_count,
        cumulative_total_tweets: cumulative_total_tweets,
        source_urls: source_urls,
        text: text
      })
    end
  end
      
end
