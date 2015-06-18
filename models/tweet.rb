#Would like to kill these two requirements
require 'active_model'
require 'georuby'


#A Tweet Object.
#
#
#
class Tweet
  #Used for DBScan Clustering
  attr_accessor :cluster, :visited

  #Extend the MongoMapper EmbeddedDocument
  include MongoMapper::EmbeddedDocument

  #Make the Tweet GeoAware
  include EpicGeo::GeoTweet

  #Variables to be saved to Mongo
  key :id_str, 			String
  key :text, 				String
  key :user, 				String
  key :handle, 			String
  key :date, 				Time
  key :coordinates, Hash
  key :cluster,     Integer

  attr_accessor :coding

  # Given a bson_tweet as returned from Mongo (or parsed via JSON),
  # It creates a (basic) tweet object
  def initialize(bson_tweet)
    attr_reader :id_str, :text, :user, :handle, :coordinates,
    @id_str = bson_tweet["id_str"]
    @text   = bson_tweet["text"]
    @user   = bson_tweet["user"]["id_str"]
    @handle = bson_tweet["user"]["screen_name"]
    @date   = bson_tweet["created_at"]
    @coordinates = bson_tweet["coordinates"]
  end

  #Corrects for the time zone
  def date
    @date.getlocal(-6*3600)
  end

  #To write the tweet to a kml file from epic-geo,
  # it must be formatted as follows:
  def as_epic_kml(style=nil)
    {:time     => date,
     :style    => style,
     :geometry => GeoRuby::SimpleFeatures::Point.from_x_y(
       coordinates["coordinates"][0],
       coordinates["coordinates"][1] ),
     :name     => nil, #Setting name to nil because otherwise it's hard to see
     :desc     =>
     %Q{#{handle}<br />
        #{text}<br />
        #{date}}
    }
  end

  #Return the tweet as a hash in valid geojson for storing as a complete feature in a GeoJSON file.
  def as_geojson
    {:type=>"Feature", :properties=>{:time=>date.iso8601, :text=>text}, :geometry=>coordinates}
  end
end
