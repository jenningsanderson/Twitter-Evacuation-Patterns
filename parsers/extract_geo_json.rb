require 'json'

class JSON_Parser

  def initialize(file_in, file_out)
    @in_stream  = File.open(file_in, 'r')
    @out_stream = File.open(file_out,'a')
  end

  def write_geo_tweets
    geo_count = 0
    @in_stream.each do |line|
      tweet = JSON.parse(line.chomp)
      if tweet['coordinates']
        @out_stream.write(tweet.to_json)
        @out_stream.write("\n")
        geo_count += 1
        if geo_count.modulo(100).zero?
          puts "Found #{geo_count}, #{tweet['user']['screen_name']}: #{tweet['text']}"
        end
      end
    end
    puts "Found #{geo_count} geo-tagged tweets"
  end

end

if __FILE__ == $0
  file_in  = ARGV[0]
  file_out = ARGV[1]

  parser = JSON_Parser.new(file_in, file_out)
  parser.write_geo_tweets
end
