lib_dir = File.expand_path(File.dirname(__FILE__)+"../..")
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require 'mjg_twitter_tools'

# Reduce the input data (json describing urls) to produce a single cumulative history 
# for all urls appearing in the dataset.
#
# This example concatenates the urls in `20150212_urls_from_tweets.json` with existing 
# `trending_urls.json` dataset & use the dataflow to reduce them to a new cumulative dataset
# @example 
#   `cat 20150212_urls_from_tweets.json trending_urls.json | wu-local lib/dataflows/reduce_to_cumulative_url_history.rb > trending_urls_updated.json`
#
# Note: The dataflow sorts the input json by url so that url entries will be grouped 
# properly by the reducer. This allows you to cat together multiple datasets as input. 
Wukong.dataflow(:reduce_to_cumulative_url_history) do
  from_json | sort(on: "url") | reduce_urls_to_cumulative_history | sort(on: "cumulative_total_tweets", numeric: true, reverse: true, accumulate_history: true)
end