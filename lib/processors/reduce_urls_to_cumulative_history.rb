require 'json'

Wukong.processor(:reduce_urls_to_cumulative_history, Wukong::Processor::Accumulator) do
  
  attr_accessor :has_updates, :last_posted_time, :last_total_tweets, :new_total_tweets, :last_count, :last_retweets, :last_weighted_count, :cumulative_total_tweets, :text, :source_urls, :appeared_on, :recurrance, :num_consecutive_days
  
  field :accumulate_history, String, default:false
  
  # Group records based on matching url values
  def get_key(record)
    record["url"]
  end
  
  def start record
    self.cumulative_total_tweets = 0 
    self.num_consecutive_days = nil
    self.last_total_tweets = 0
    self.source_urls = []
    self.appeared_on = []  
    self.has_updates = false  
  end
  
  def accumulate record
    self.source_urls += Array(record["source_urls"]) if record["source_urls"]
    if record["posted_time"]
      self.has_updates = true
      self.cumulative_total_tweets += record["total_tweets"]
      self.appeared_on << record["date"] unless self.appeared_on.include? record["date"]
      self.last_posted_time = record["posted_time"]
      self.new_total_tweets = record["total_tweets"]
      self.last_count = record["count"]
      self.last_retweets = record["retweets"]
      self.text = record["text"]
      self.last_weighted_count = last_count*10+last_retweets
    else
      self.cumulative_total_tweets += record["cumulative_total_tweets"] if record["cumulative_total_tweets"]
      self.appeared_on += record["appeared_on"] if record["appeared_on"]
      self.last_total_tweets = record["last_total_tweets"]
    end
  end
  
  def finalize
    # Unless accumulate_history == true, only return records that were actually updated by this reduce operation
    if has_updates || accumulate_history
      json = {
        url: key, 
        rank: RankingCalculator.rank(self),
        appeared_on: appeared_on.sort,
        first_appearance: appeared_on.sort.first,
        last_posted_time: last_posted_time, 
        last_total_tweets: new_total_tweets,
        cumulative_total_tweets: cumulative_total_tweets,
        consecutive_days: count_consecutive_days,
        trend_direction: trend_direction,
        last_count: last_count,
        last_retweets: last_retweets,
        last_weighted_count: last_weighted_count,
        source_urls: source_urls,
        text: text,
        ranking_algorithm_version: RankingCalculator::VERSION
      }
      json[:recurrance] = true if recurrance
      yield JSON.generate(json)
    end
  end
  
  def trend_direction
    if num_consecutive_days == 1
      new_total_tweets
    else
      new_total_tweets - last_total_tweets
    end
  end
  
  def count_consecutive_days
    return self.num_consecutive_days unless self.num_consecutive_days.nil?
    count = 0
    appeared_on.sort.reverse_each do |date_string|
      d = Date.parse date_string
      count += 1 
      break unless appeared_on.include?((d-1).to_s)
    end
    self.recurrance = true if appeared_on.length > count
    self.num_consecutive_days = count
  end
      
end
