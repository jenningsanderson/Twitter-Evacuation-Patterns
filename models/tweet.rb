# Tweet Model
#
# The Tweet Model is an embedded document of the Twitterer Class.
#

require 'mongo_mapper'
require 'active_model'
require 'georuby'
require 'rgeo'

class Tweet

  #A Tweet can be accessed as an RGEO point object as tweet.point
  @@geo_factory = RGeo::Geographic.simple_mercator_factory

  #Used for DBScan Clustering
  attr_accessor :cluster, :visited

  #Extend the MongoMapper EmbeddedDocument
  include MongoMapper::EmbeddedDocument

  #Variables to be saved to Mongo
  key :id_str, 			String
  key :text, 				String
  key :user, 				String
  key :handle, 			String
  key :date, 				Time
  key :coordinates, Hash

  # Given a bson_tweet as returned from Mongo (or parsed via JSON),
  # It creates a (basic) tweet object
  def initialize(bson_tweet)
    @id_str = bson_tweet["id_str"]
    @text   = bson_tweet["text"]
    @user   = bson_tweet["user"]["id_str"]
    @handle = bson_tweet["user"]["screen_name"]
    @date   = bson_tweet["created_at"]
    @coordinates = bson_tweet["coordinates"]
  end

  #In order to call the tweet.point instance, it must be defined
  def point
    #Return point or define and then return point
    @point ||= @@geo_factory.point(
          @coordinates["coordinates"][0],
          @coordinates["coordinates"][1])
  end

  #To write the tweet to a kml file from epic-geo,
  # it must be formatted as follows:
  def as_epic_kml(style=nil)
    {:time     => @date,
     :style    => style,
     :geometry => GeoRuby::SimpleFeatures::Point.from_x_y(
       @coordinates["coordinates"][0],
       @coordinates["coordinates"][1] ),
     :name     => nil, #Setting name to nil because otherwise it's hard to see
     :desc     =>
     %Q{#{@handle}<br />
        #{@text}<br />
        #{@date}}
    }
  end

  def as_geojson
    {:type=>"Feature", :properties=>{:Time=>@date, :text=>@text},:geometry=>@coordinates}
  end
end
