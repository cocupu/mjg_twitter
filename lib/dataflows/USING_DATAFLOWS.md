# EXAMPLE USING DATAFLOWS
Process a day's data, mapping & reducing tweets to urls. Then concatenate that with the existing trending_urls.json dataset and reduce the concatenated data to produce a cumulative url history

  $ cat data/20150212/2015_02_12/*.json | wu-local map_and_reduce_tweets_to_urls | cat trending_urls.json | wu-local reduce_to_cumulative_url_history
