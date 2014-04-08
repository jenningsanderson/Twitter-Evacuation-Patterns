'''

Write geojson from a mongo collection

'''

require 'mongo'
require 'json'

class GeoJSONAuthor

  attr_reader :filename

  def initialize(filename, cursor)
    @filename = filename
    @cursor   = cursor
  end

  def reset_cursor
    @cursor.rewind!
  end

  def write_geojson_paths
    File.open(@filename+'_path.geojson', 'w') do |file|
      file.write("{\"type\" : \"FeatureCollection\", \"features\" :[\n")
      @cursor.each do |object|
        type = object["type"]
        geometry = object["geometry"].to_json
        handle = object["handle"].to_json
        file.write("{\"type\" : \"#{type}\", \"geometry\" : #{geometry},")
        file.write("\"properties\" : {\"handle\" : #{handle} } }")
        if @cursor.has_next?
          file.write(",\n")
        end
      end
      file.write(']}')
    end
  end

  def write_geojson_tweets
    File.open(@filename+'_tweets.geojson', 'w') do |file|
      file.write("{\"type\" : \"FeatureCollection\", \"features\" :[")
      @cursor.each do |object|
        handle = object["handle"].to_json
        coords = object["geometry"]["coordinates"]
        coords.each_with_index do |point,i|
          file.write("{\"type\" : \"Feature\",
            \"geometry\" : {
            \"type\" : \"Point\",
            \"coordinates\" : #{point} },")
          tweet_data = object["tweets"][i]
          file.write("\"properties\" :{
            \"handle\" : #{handle},
            \"created_at\" : #{tweet_data.delete('created_at').to_json},
            \"text\" : #{tweet_data.delete('text').to_json},
            \"place\": #{tweet_data.delete('place.fullname').to_json},
            \"metadata\" : #{tweet_data.to_json}
            }}")
          if i < (coords.count-1)
            file.write(',')
          end
        end
        if @cursor.has_next?
          file.write(",")
        end
      end
      file.write(']}')
    end
  end
end #Class


if __FILE__ == $0
  unless ARGV[0] and ARGV[1]
    puts %Q{
      Invoke this scirpt in the following way:

      ruby write_geojson.rb $COLLECTION $FILENAME [limit=X]

      This script will write two files:
        1. $FILENAME_paths.geojson
        2. $FILENAME_tweets.geojson

      The optional limit argument will choose the first X users.
    }
  else
    limit = 500000
    collection = ARGV[0]
    filename   = ARGV[1]

    limit_string = ARGV.join.scan(/limit=\d+/i).first
    unless limit_string.nil?
      limit=limit_string.gsub!('limit=','').to_i
    end

    puts "Calling the GeoJSON writer:"
    puts "limit: #{limit}"
    puts "Outfile: #{filename}"
    puts "Collection: #{collection}"

    puts "Connecting to Mongo"
    mongo_conn = Mongo::MongoClient.new
    DB = mongo_conn['sandygeo']
    COLL = DB[collection]
    cursor = COLL.find({},{:limit=>limit})

    file = GeoJSONAuthor.new(filename, cursor)
    puts "Writing Paths"
    file.write_geojson_paths
    file.reset_cursor
    puts "Writing Tweets"
    file.write_geojson_tweets
  end
end
