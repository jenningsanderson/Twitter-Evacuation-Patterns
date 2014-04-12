'''
Write geojson file per document
'''

require 'mongo'
require 'optparse'
require './write_geojson'


if __FILE__ == $0
  options = OpenStruct.new
  opts = OptionParser.new do |opts|
    opts.banner = "Usage: ruby write_user_tweets_geojson.rb -c COLLECTION -f DIRECTORY [-l LIMIT]"
    opts.separator "\nSpecific options:"

    opts.on("-c", "--collection Collection",
            "Name of Collection"){|v| options.collection = v }
    opts.on("-f", "--directory Output",
            "Name of Output Directory"){|v| options.directory = v }
    opts.on("-l", "--limit [LIMIT]",
            "[Optional] Limit of documents (users) to parse"){|v|
              v ||= 500000
              options.limit = v.to_i }
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end
  opts.parse!(ARGV)
  unless options.collection and options.directory
    puts opts
    exit
  end

  puts "Calling the GeoJSON writer:"
  puts "limit: #{options.limit}, (500000 is default)"
  puts "Directory: #{options.directory}"
  puts "Collection: #{options.collection}"

  unless Dir.exists? options.directory
    Dir.mkdir options.directory
  end

  puts "Connecting to Mongo"
  mongo_conn = Mongo::MongoClient.new
  DB = mongo_conn['sandygeo']
  COLL = DB[options[:collection]]
  cursor = COLL.find({},{:limit=>options.limit})

  cursor.each do |item|

    userfile = options.directory+'/'+item["handle"]+".geojson"
    file = GeoJSONWriter.new(userfile)
    file.write_header
    file.add_options({:handle=>item["handle"], :id=>item["id"], :tweet_count=>item["tweet_count"]})

    item["features"].each do |feature|
      file.write_feature(feature["feature"], feature["properties"])
    end

    file.write_footer
  end
end
