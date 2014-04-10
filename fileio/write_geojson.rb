'''
Write geojson from a mongo collection
'''

require 'mongo'
require 'json'
require 'optparse'

class GeoJSONWriter
  attr_reader :filename

  def initialize(filename)
    @filename = filename.dup #Getting weird frozen error...
    unless @filename =~ /\.geojson$/
      @filename << '.geojson'
    end
    @open_file = File.open(@filename, 'w')
  end

  def write_header
    @open_file.write "{\"type\" : \"FeatureCollection\", \"features\" :["
  end

  def write_feature(geometry, properties)
    @open_file.write "{"
    @open_file.write "\"type\" : \"Feature\", "
    @open_file.write "\"geometry\" : #{geometry.to_json},"
    @open_file.write "\"properties\" : #{properties.to_json}"
    @open_file.write "},"
  end

  def write_footer
    #Close the file and then truncate the last comma
    @open_file.close()
    File.truncate(@filename, File.size(@filename) - 1) #Remove the last comma

    #Open the file again and close the object
    File.open(@filename,'a') do |file|
      file.write(']}')
    end
  end

end #end class












if __FILE__ == $0
  options = OpenStruct.new
  opts = OptionParser.new do |opts|
    opts.banner = "Usage: ruby write_geojson.rb -c COLLECTION -f FILE [-l LIMIT]"
    opts.separator "\nSpecific options:"

    opts.on("-c", "--collection Collection",
            "Name of Collection"){|v| options.collection = v }
    opts.on("-f", "--filename OutFile",
            "Name of Output file"){|v| options.filename = v }
    opts.on("-l", "--limit [LIMIT]",
            "[Optional] Limit of documents to parse"){|v|
              v ||= 500000
              options.limit = v.to_i }
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end
  opts.parse!(ARGV)
  unless options.collection and options.filename
    puts opts
    exit
  end

  puts "Calling the GeoJSON writer:"
  puts "limit: #{options.limit}, (500000 is default)"
  puts "Outfile: #{options.filename}"
  puts "Collection: #{options.collection}"

  puts "Connecting to Mongo"
  mongo_conn = Mongo::MongoClient.new
  DB = mongo_conn['sandygeo']
  COLL = DB[options[:collection]]
  cursor = COLL.find({},{:limit=>options.limit})

  unless options.filename =~ /\.geojson$/
    options.filename << '.geojson'
  end

  #Write tweets
  tweets = options.filename.gsub('.','_tweets.')
  file = GeoJSONWriter.new(tweets)
  file.write_header
  cursor.each do |item|
    coords = item["geometry"]["coordinates"]
    props = {:handle=>item["handle"],
             :user_id=>item["id"]}
    coords.each_with_index do |coords, i|
      props[:text] = item["tweets"][i]["text"]
      props[:created_at] = item["tweets"][i]["created_at"]
      geometry = {:type=>"Point", :coordinates=>coords}
      file.write_feature(geometry, props)
    end
  end
  file.write_footer

  #Reset the cursor
  cursor.rewind!

  #Write Paths
  paths = options.filename.gsub('.','_paths.')
  file = GeoJSONWriter.new(paths)
  file.write_header
  cursor.each do |item|
      props = { :handle => item["handle"],
                :user_id => item["id"],
                :tweet_count =>item["tweet_count"]}
      file.write_feature(item["geometry"], props)
  end
  file.write_footer
end
