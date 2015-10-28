module Dat
  class Repository
    attr_accessor :dir

    # @param [String] dir directory where the dat repository is stored
    def initialize(options={})
      dir = File.expand_path options[:dir]
      @dir = dir
    end

    def init
      FileUtils.mkdir_p dir
      run_command "dat init --path=#{dir} --no-prompt --json"
    end

    def status
      run_and_parse_response "dat status --json"
    end

    def forks
      run_and_parse_response "dat forks --json"
    end

    def import(options = {:file => nil, :data => nil, :dataset => nil, :key => nil, :message => nil})
      file = options[:file]
      data = options[:data]
      dataset = options[:dataset]
      key = options[:key]
      message = options[:message]
      raise ArgumentError, "You must provide either a file or (string) data" unless data || file
      command =  "dat import"
      if data
        command = "#{data} | dat import -"
      else
        command = "dat import #{file}"
      end

      command << " -d #{dataset}"
      command << " -k #{key}" if key
      command << " -m \"#{message}\"" if message
      command << " --json"

      run_command command
    end
    
    # @return [String] the output of the dat export
    def export(options={})
      dataset = options[:dataset]
      write_to = options[:write_to]
      if write_to
        run_command "dat export -d #{dataset} > #{write_to}"
      else
        run_command "dat export -d #{dataset}"
      end
    end

    def replicate(options={})
      remote = options[:remote]
      run_command "dat replicate #{remote} --json"
    end

    def push(options={})
      remote = options[:remote]
      run_command "dat push #{remote} --json"
    end

    def pull(options={})
      remote = options[:remote]
      run_command "dat pull #{remote} --json"
    end

    # the commit hashes in chronological order -- most recent commits are listed last
    def commit_hashes
      log.map {|entry| entry['version']}
    end

    # return dat log in json form
    # the json is sorted in chronological order, so the most recent commits are listed last
    def log
      run_and_parse_response "dat log --json"
    end

    def diff(ref1, ref2=nil)
      run_and_parse_response "dat diff --json #{ref1} #{ref2}"
    end

    private

    # Run dat command
    # @example
    #   run_command "dat log --json"
    def run_command(command)
      Dir.chdir(dir) { %x(#{command}) }
    end

    def run_and_parse_response(command)
      raw_json = run_command(command) 
      if raw_json.include?("\n")
        parse_ndj(raw_json)
      else
        JSON.parse(raw_json)
      end
    end

    def parse_ndj(ndj_json)
      ndj_json.split("\n").map {|json_string| JSON.parse(json_string) }
    end
  end
end