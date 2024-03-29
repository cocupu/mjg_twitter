require 'spec_helper'

describe UsesBlacklist do
  class UsesBlacklistTestClass
    include UsesBlacklist
  end
  
  subject { UsesBlacklistTestClass.new }
  
  describe "matches_blacklist?" do
    it "returns true if the content matches anything in the blacklist" do
      expect( subject.matches_blacklist?("http://connect.talentnow.com") ).to eq true
      expect( subject.matches_blacklist?("besturl.es/urlcontent") ).to eq true

      ["http://connect.talentnow.com","besturl.es/urlcontent","http://8grids.com/portfolio/peak-wordpress-theme/"].each do |blacklisted_content|
        expect( subject.matches_blacklist?(blacklisted_content) ).to eq true
      end
    end
    it "returns true if the content is in blacklisted_urls" do
      ["https://vidtok.com","http://www.abc.net.au/radionational/programs/shorthistoryofvideogames/podcasts/svg-4/5938378"].each do |blacklisted_content|
        expect( subject.matches_blacklist?(blacklisted_content) ).to eq true
      end
      ["http://iamajin.blogspot.in/2014/11/when-gifs-serve-javascript.html","http://js1k.com/2014-dragons/details/1951"].each do |clean_content|
        expect( subject.matches_blacklist?(clean_content) ).to eq false
      end
    end
    it "returns false if the content does not match anything in the blacklist" do
      ["poppycock","blather","http://blog.nodejs.org/2015/02/06/node-v0-12-0-stable", "https://web.archive.org/web/20070916144913/","http://wp.netscape.com/newsref/pr/newsrelease67.html/"].each do |clean_content|
        expect( subject.matches_blacklist?(clean_content) ).to eq false
      end
    end
  end
  
end
