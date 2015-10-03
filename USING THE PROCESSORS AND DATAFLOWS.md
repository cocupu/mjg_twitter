# Using the Processors and Dataflows

## Dataflows
Dataflows Tie together the Processors for you

### Using the map_and_reduce_tweets_to_urls dataflow

    $ cat data/20150212/2015_02_12/*.json | bundle exec wu-local lib/dataflows/map_and_reduce_tweets_to_urls.rb > 20150212_urls_from_tweets.json`

### Using the reduce_to_cumulative_url_history dataflow
Concatenate the urls extracted from 20150212 with existing trending_urls dataset & use the dataflow to reduce them to a new cumulative dataset  

    $ cat 20150212_urls_from_tweets.json trending_urls.json | bundle exec wu-local lib/dataflows/reduce_to_cumulative_url_history.rb > trending_urls_updated.json


### Example: using both dataflows together
Process a day's data, mapping & reducing tweets to urls. Then concatenate that with the existing trending_urls.json dataset and reduce the concatenated data to produce a cumulative url history. Note: you could pipe the output from the first flow directly into the second flow, but we want to catenate it with the existing trending_urls dataset, which would cause a broken pipe error.

    $ cat data/20150212/2015_02_12/*.json | bundle exec wu-local lib/dataflows/map_and_reduce_tweets_to_urls.rb > 20150212-linkReport.json

.. then ...

    $ cat 20150212-linkReport.json trending_urls.json | bundle exec wu-local lib/dataflows/reduce_to_cumulative_url_history.rb > trending_urls_updated.json

## Processors
Processors are where the magic happens.  Each processor performs a piece of the flow.

The Flow: **cat** | **map** | **sort** | **reduce** | **sort** again | **cat** cumulative data | **reduce** cumulative data

**cat** the input GNIP data

    $ cat data/20150212/2015_02_12/*.json

**map** tweets to urls with **`map_tweets_to_urls`** processor  

    $ bundle exec wu-local lib/processors/map_tweets_to_urls.rb --from=json

**sort**/group the urls (_Note: wu-hadoop's default sorting algorithm was not doing this properly. That's part of why these scripts use regular wu-local and Wukong dataflows instead of wu-hadoop._)

    $ bundle exec wu-local sort --on="url"

**reduce** the url data, accumulating info about each url with **`accumulate_url_counts`** processor  

    $ bundle exec wu-local lib/processors/accumulate_url_counts.rb --from=json --include_debug_info

**sort** by weighted count  

    $ bundle exec wu-local sort --on=weighted_count --numeric --reverse 

**cat** those processed results together with existing dataset  

    $ cat {json output from previous processors} trending_urls.json

**reduce** the dataset with the **`reduce_urls_to_cumulative_history`** processor

    $ bundle exec wu-local sort --on="url" | bundle exec wu-local lib/processors/reduce_urls_to_cumulative_history.rb --from=json

**sort** for readability  

    $ bundle exec wu-local sort --on=cumulative_total_tweets --numeric --reverse