# Source: https://github.com/gnip/search-api-rails-demo/blob/master/lib/gnip/search_service.rb
require 'base64'
require 'rest-client'
require 'yajl'

module Gnip
  class SearchException < StandardError; end
  class InvalidSearchException < StandardError; end
  class SearchService
    
    def self.activities_for(query, args={})
      json = activities_search(query, args)
      results = parse_activities json
    end

    def self.activities_search(args)
      query_params = {query:args[:query], publisher: 'twitter', maxResults: 100}
      query_params[:maxResults] = args[:max] if args[:max]
      query_params[:fromDate], query_params[:toDate] = datestamp_range(args[:from], args[:to]) if args.values_at(:from, :to).all?
      query_params[:next] = args[:next] if args[:next]
      response = http_post(self.search_endpoint, Yajl::Encoder.encode(query_params))
      Yajl::Parser.new(symbolize_keys: true).parse(response)
    end

    def self.counts_for(query, args={})
      args[:query] = query
      json = counts_search(args)
      parsed_counts = parse_counts(json)
      {
          point_interval: 3600000,
          point_start: DateTime.iso8601(parsed_counts.first[:timePeriod]).to_time.to_i * 1000,
          data: parsed_counts.map { |r| r[:count] }
      }
    end

    def self.counts_search(args)
      query_params = {query: args[:query], publisher: 'twitter', bucket: 'hour'}
      query_params[:bucket] = args[:bucket] if args[:bucket]
      query_params[:fromDate], query_params[:toDate] = datestamp_range(args[:from], args[:to]) if args.values_at(:from, :to).all?
      response = http_post(self.count_endpoint, Yajl::Encoder.encode(query_params))
      Yajl::Parser.new(symbolize_keys: true).parse(response)
    end
    
    
    def self.account
      gnip_config[:account]
    end
    
    def self.stream_name
      gnip_config[:stream_name]
    end
    
    def self.search_endpoint
      "https://search.gnip.com/accounts/#{account}/search/#{stream_name}.json"
    end
    
    def self.count_endpoint
      "https://search.gnip.com/accounts/#{account}/search/#{stream_name}/counts.json"
    end

    def self.gnip_config
      @gnip_config ||= {:account => config["account"], :username => config["username"], :password => config["password"], :stream_name => config["stream_name"]}
    end
    
    private

    def self.datestamp_range(from, to)
      from_datestamp = DateTime.iso8601(from).to_time.utc.strftime('%Y%m%d%H%M').to_i
      to_datestamp = [DateTime.iso8601(to).to_time.utc.strftime('%Y%m%d%H%M').to_i, DateTime.now.strftime('%Y%m%d%H%M').to_i].min
      [from_datestamp, to_datestamp]
    end

    def self.retrieve_paginated(query_params)
      response = http_post(self.search_endpoint, Yajl::Encoder.encode(query_params))
      json = parse_json(response)
      results = parse_activities json
      if json.has_key?(:next)
        results += self.retrieve_paginated(query_params.merge(next:json[:next]))
      end
      results.sort! { |a, b| b[:postedTime] <=> a[:postedTime] }
    end

    # If API responds with a 429 'Too Many Requests', Waits sleep_time, then repeats the HTTP post. Will repeat attempts up to max_attempts times.
    def self.throttled_http_post(url, data, sleep_time=4, max_attempts=5, current_attempt=1)
      begin
        self.http_post(url, data)
      rescue => e
        if e.respond_to?(:response) && !e.response.nil?
          if e.respond_to?(:response) && e.response.code == 429
            current_attempt += 1
            if current_attempt < max_attempts
              sleep sleep_time
              self.throttled_http_post(url, data, sleep_time, max_attempts, current_attempt)
            else
              raise SearchException.new("Search API rate limit exceeded.  Attempted to resume #{max_attempts} times, waiting #{sleep_time} between requests, but still failing.")
            end
          else
            raise SearchException.new("Search API returned HTTP #{e.response.code}.\nREQUEST:\nURL: #{url}\nPOST DATA: #{data}\nRESPONSE CODE: #{e.response.code}\nRESPONSE: #{e.response}\n")
          end
        else
          raise e
        end
      end
    end

    def self.http_post(url, data)
      begin
        RestClient::Request.new(method: :post, url: url, user: gnip_config[:username], payload: data,
                                password: gnip_config[:password], timeout: 30, open_timeout: 30,
                                headers: {content_type: :json, accept: :json}).execute
      rescue SocketError => se
        raise Gnip::SearchException.new("SocketError: #{se.message}")
      rescue => e
        if e.respond_to?(:response)
          unless e.response.nil?
            if e.response.code == 422
              raise InvalidSearchException.new parse_error(e.response)
            else
              raise e
            end
          end
        else
          raise e
        end
      end
    end

    def self.parse_activities(json)
      obj = parse_json(json)
      obj[:results].sort! { |a, b| b[:postedTime] <=> a[:postedTime] }
    rescue Yajl::ParseError => e
      raise Gnip::SearchException.new("Could not parse JSON from /activities: #{e.message}.\nJSON:\n#{json}\n")
    end

    def self.parse_counts(json)
      obj = parse_json(json)
      obj[:results].sort! { |a, b| a[:postedTime] <=> b[:postedTime] }
    rescue Yajl::ParseError => e
      raise Gnip::SearchException.new("Could not parse JSON from /counts endpoint: #{e.message}.\nJSON:\n#{json}\n")
    end

    def self.parse_error(json)
      parser = Yajl::Parser.new(symbolize_keys: true)
      obj = parser.parse json
      obj[:error][:message]
    rescue Yajl::ParseError => e
      raise Gnip::SearchException.new("Could not parse error JSON: #{e.message}.\nJSON:\n#{json}\n")
    end

    def self.parse_json(json)
      if json.kind_of?(Hash)
        return json
      else
        parser = Yajl::Parser.new(symbolize_keys: true)
        return parser.parse json
      end
    end
    
    def self.config
      @config ||= load_config
    end

    def self.load_config
      gnip_yml_path = File.dirname(__FILE__)+'/../../config/gnip.yml'
      ::YAML.load(File.read(gnip_yml_path))
    end
    
  end
end

