lib_dir = File.expand_path(File.dirname(__FILE__)+"../..")
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require 'mjg_twitter_tools'

# Returns a report on how many times each URL has been tweeted.
# Yields JSON containing key, count, retweets and total tweets.  Example:
#   {"key":"http://nyti.ms/1eaCmuG","count":1,"retweets":95,"total_tweets":96}
#
# Processes tweet data, mapping tweets to urls 
#  * extract url references from tweet data
#  * count url references, accumulating info like tweet_counts, etc. 
# 
# @example Process a day's data, mapping & reducing tweets to urls.
#   `cat data/20150212/2015_02_12/*.json | bundle exec wu-local lib/dataflows/map_and_reduce_tweets_to_urls.rb > 20150212_urls_from_tweets.json`
Wukong.dataflow(:map_and_reduce_tweets_to_urls) do
  from_json | map_tweets_to_urls | sort(on: "url") | from_json | accumulate_url_counts(include_debug_info: true) | sort(on: "weighted_count", numeric: true, reverse: true)
end