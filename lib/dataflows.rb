# EXAMPLE USING DATAFLOWS
# Process a day's data, mapping & reducing tweets to urls. Then concatenate that with the existing trending_urls.json dataset and reduce the concatenated data to produce a cumulative url history
cat data/20150212/2015_02_12/*.json | wu-local map_and_reduce_tweets_to_urls | cat trending_urls.json | wu-local reduce_to_cumulative_url_history


# Process a day's data, mapping & reducing tweets to json describing urls. 
Wukong.dataflow(:map_and_reduce_tweets_to_urls) do
  from_json | map_tweets_to_urls | sort(on: "url") | reduce_urls(include_debug_info: true) | sort(on: "weighted_count")
end


# Reduce the input data (json describing urls) to produce a single cumulative history for all urls appearing in the dataset
Wukong.dataflow(:reduce_to_cumulative_url_history) do
  from_json | sort(on: "url") | reduce_urls_to_cumulative_history | sort(on: "cumulative_total_tweets", numeric: true, reverse: true, accumulate_history: true)
end