require 'rgeo-shapefile'
require 'geo_ruby'
require 'geo_ruby/shp4r/shp'
require 'mongo'
require 'pp'


'''
This class makes a shapefile from tweets
'''
class Tweet_Shapefile
  attr_reader :file_name
  attr_accessor :fields, :shapefile

  def initialize(file_name)
    unless file_name =~ /\.shp$/
      file_name << '.shp'
    end
    @file_name = file_name
    @fields = {
      :usr_id_str=>['C',11],
      :handle=>['C',20],
      :text=>['C',140],
      :time=>['D',30],
      :loc =>['C',50],
      :hashtags=>['C',140],
      :urls=>['C',140],
      :time=>['C',30]}
  end

  def create_point_shapefile
    fields = []
    @fields.each do |k,v|
      fields << GeoRuby::Shp4r::Dbf::Field.new(k.to_s,v[0],v[1])
    end
    @shapefile = GeoRuby::Shp4r::ShpFile.create(@file_name, GeoRuby::Shp4r::ShpType::POINT,fields)
  end

  def create_line_shapefile
    fields = []
    fields << GeoRuby::Shp4r::Dbf::Field.new("Handle",'C',20)
    fields << GeoRuby::Shp4r::Dbf::Field.new("Tweets",'N',10)
    @shapefile = GeoRuby::Shp4r::ShpFile.create(@file_name, GeoRuby::Shp4r::ShpType::POLYLINE,fields)
  end

  def open_transaction
    @shapefile.transaction do |tr|
      yield tr
    end
  end

  def add_point(p)
    @shapefile.transaction do |tr|
      tr.add(GeoRuby::Shp4r::ShpRecord.new(
        GeoRuby::SimpleFeatures::Point.from_x_y(p[:coords][1],p[:coords][0]),
        :handle.to_s => p[:user_name],
        :text.to_s => p[:text],
        :time.to_s => p[:time],
        :hashtags.to_s => p[:hashtags],
        :loc.to_s => p[:location],
        :urls.to_s => p[:urls]))
    end
  end

  def add_line(points, tweet_data)
    @shapefile.transaction do |tr|
      tr.add(GeoRuby::Shp4r::ShpRecord.new(
        GeoRuby::SimpleFeatures::LineString.from_points(points),
        "Handle"=>tweet_data[:handle].join(','),
        "Tweets"=>tweet_data[:tweets]))
    end
  end

  def method_missing(method_name)
    @shapefile.instance_eval "#{method_name}"
  end
end


#Global variables
sandy = '/Users/Shared/Sandy/geo_extract.json'
max   = 750

if __FILE__ == $0
  if ARGV[0]
    max = ARGV[0].to_i
  end
  puts "Running Tweet JSON to Shapefile, Parsing limit: #{max or 'none'}."

  # define the file reader
  t = Tweet_JSON_Reader.new(sandy, max)

  t.import_to_mongo

  # make the shapefile
  # tweet_shp = Tweet_Shapefile.new('sandy_tweets_sample')
  # tweet_shp.create_point_shapefile

  #Add points to the file
  # counter=0
  # t.tweets.each do |tweet|
  # 	tweet_shp.add_point(tweet)
  # 	counter+=1
  # 	if counter % 500 == 0
  # 		puts counter
  # 	end
  # end
  # tweet_shp.close
end

#
# GeoRuby::Shp4r::ShpFile.open('../lab3/data/interestAreas.shp') do |shp|
# 	shp.each do |shape|
# 		geom = shape.geometry #a GeoRuby SimpleFeature
# 			puts "BOUNDING BOX: #{geom.bounding_box.inspect }\n"#I can get bounding box, but I can't calculate area?
# 		att_data = shape.data #a Hash
# 		puts "Attribute data: #{att_data.inspect}"
# 		shp.fields.each do |field|
# 			puts "Field: #{field.inspect}"
# 			puts att_data[field.name]
# 		end
# 	end
# end
