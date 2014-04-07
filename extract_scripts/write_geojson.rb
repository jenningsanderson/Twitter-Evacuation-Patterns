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

  def write_geojson
    File.open(@filename, 'w') do |file|
      file.write("{\"type\" : \"FeatureCollection\", \"features\" :[")
      @cursor.each do |object|
        type = object["type"]
        geometry = object["geometry"].to_json
        properties = object["handle"].to_json
        file.write("{\"type\" : \"#{type}\", \"geometry\" : #{geometry},")
        file.write("\"properties\" : {\"handle\" : #{properties} } }")
        if @cursor.has_next?
          file.write(",\n")
        end
      end
    file.write(']}')
  end
  end


end #Class


if __FILE__ == $0
  limit = 500000
  filename = 'testgeojson.geojson'
  collection = 'userpath_lt20'

  args = ARGV.join(" ")+" "

  limit_string = args.scan(/limit=\d+/i).first
  unless limit_string.nil?
    limit=limit_string.gsub!('limit=','').to_i
  end

  coll_string = args.scan(/coll=[a-zA-z0-9_]+\s/i).first
  unless coll_string.nil?
    collection=coll_string.gsub!('coll=','').strip
  end

  filename_string = args.scan(/name=.+\s+/i).first
  unless filename_string.nil?
    filename=filename_string.gsub!('name=','').strip
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

  puts "Writing the File"
  file = GeoJSONAuthor.new(filename, cursor)
  file.write_geojson
end
