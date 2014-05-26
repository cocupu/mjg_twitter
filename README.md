# Installation

Needs to be run with rubygems version before 2.0.0 (ie. 1.8.10).  See https://github.com/infochimps-labs/wukong-hadoop/issues/4

# Scripts

`./script/download_data_and_compile_report`

# Examples of using wu-hadoop to run the extractor

 Run all the files with data for from 2013_12_15 through twitter_url_extractor.rb then sort numerically on the _total_tweets_ field.  Write the result to 20131215-linkReport.json
`cat data/20131215/json/20131215-20140115_f3a6rxbkax_2013_12_15*.json | bundle exec wu-hadoop --from=json lib/twitter_url_extractor.rb --mode=local | wu-local sort --on=total_tweets --numeric --reverse > NEW-linkReport.json`

Use wukong-hadoop to analyze a text file using the mapper & reducer defined in the given Ruby file.  Run locally (instead of on hadoop.)  
`bundle exec wu-hadoop hadoop-examples/word_count.rb --mode=local --input=data/howl.txt `

Use wukong-hadoop to parse a json file using the mapper & reducer defined in the given Ruby file.  Run it locally.  
`bundle exec wu-hadoop --from=json twitter_url_extractor.rb --mode=local --input=data/gnip_twitter_2013_12_15_00_00.json`

