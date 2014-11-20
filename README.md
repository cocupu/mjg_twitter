# Installation

Needs to be run with rubygems version before 2.0.0 (ie. 1.8.10).  See https://github.com/infochimps-labs/wukong-hadoop/issues/4

To download the code and run the tests:
```
git clone git@github.com:FrontendMasters/twitter_url_analyzer.git
cd twitter_url_analyzer
bundle install
[MODIFY config/databindery.yml and config/gnip.yml with your credentials]
rake spec
```

# Scripts

To download the day's data, run the analyzer on it, and publish the resulting report, run this on the command line:
`$ ./script/url_analyzer --full`
or
`$ ./script/url_analyzer --download --extract --publish`

If you want to work with specific dates, provide a start date and end date in `%Y%m%d` format
`$ ./script/url_analyzer --extract --publish --start 20131215 --end 20140108`

By default, the analyzer assumes that you're using data from the current day's GNIP job. If you're using data from another day, use the `--gnip_report_date` flag
`$ ./script/url_analyzer --extract --gnip_report_date 20131215`


# Examples of using wu-hadoop to run the extractor

*Note:* The download_data_and_compile_report script runs this for you.  Also, if you want to call this process from Ruby code, you should look at the ExtractionRunner class.

 Run all the files with data for from 2013_12_15 through twitter_url_extractor.rb then sort numerically on the _total_tweets_ field.  Write the result to 20131215-linkReport.json
`cat data/20131215/json/20131215-20140115_f3a6rxbkax_2013_12_15*.json | bundle exec wu-hadoop --from=json lib/twitter_url_extractor.rb --mode=local --include_debug_info | wu-local sort --on=total_tweets --numeric --reverse > 20131215-NEWlinkReport.json`

Use wukong-hadoop to analyze a text file using the mapper & reducer defined in the given Ruby file.  Run locally (instead of on hadoop.)  
`bundle exec wu-hadoop hadoop-examples/word_count.rb --mode=local --input=data/howl.txt `

Use wukong-hadoop to parse a json file using the mapper & reducer defined in the given Ruby file.  Run it locally.  
`bundle exec wu-hadoop --from=json lib/twitter_url_extractor.rb --mode=local --input=./data/sample/json/20131215-20140115_f3a6rxbkax_2013_12_15_11_20_activities.json > TEST-report.json`

## Options

`--invert_filters`   To invert the content filters, making the analyzer return all of the _rejects_ instead of all of the valid content
`--include_debug_info`  Includes a fuller record of the source data in each json entry of the link report

Example:
`bundle exec wu-hadoop --from=json lib/twitter_url_extractor.rb --mode=local --input=./data/sample/json/20131215-20140115_f3a6rxbkax_2013_12_15_11_20_activities.json --invert_filters --include_debug_info | wu-local sort --on=total_tweets --numeric --reverse > RejectedWithDebugInfo-linkReport.json`
