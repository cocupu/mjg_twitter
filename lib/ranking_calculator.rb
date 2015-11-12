class RankingCalculator
  VERSION = '1.0.0'
  
  def self.rank(record)
    # float = (record.last_total_tweets + record.cumulative_total_tweets * 0.05) * decay(record.count_consecutive_days, 1, 6)
    # float.to_i
    combined_score = score_last_day_activity(record) + score_cumulative_activity(record) + score_trend_direction(record)
    decayed_score = combined_score * decay(record.count_consecutive_days, 1, 6)
    decayed_score.to_i
  end
  
  private 
  
  def self.score_last_day_activity(record)
    compress(record.last_total_tweets, 5000, scale: 500).to_i
  end
  
  def self.score_cumulative_activity(record)
    compress(record.cumulative_total_tweets, 30000, scale: 250).to_i
  end
  
  def self.score_trend_direction(record)
    compressed = compress(record.trend_direction.abs, 1500, scale: 250).to_i
    if record.trend_direction > 0
      compressed
    else
      -compressed
    end
  end
  
  def self.compress(value, ceiling, opts={})
    scale = opts.fetch(:scale, 1)
    input = [value, ceiling].min.to_f
    input/ceiling * scale
  end
  
  # decay(15, 1, 6, 0, 0)
  # decay(5, 1, 6, 0, 0)
  def self.decay(value, origin, scale, decay=0.001)
    return decay if value > scale
    1 - (value - origin) / scale.to_f + decay
  end
  
end