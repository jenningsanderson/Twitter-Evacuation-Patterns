# Tweet Model
#
# The Tweet Model is an embedded document of the Twitterer Class.
#

require 'mongo_mapper'
require 'active_model'
require 'georuby'
require 'rgeo'

class Tweet

  @@geo_factory = RGeo::Geographic.simple_mercator_factory

  #A Tweet can be accessed as an RGEO point object
  attr_reader :point

  attr_accessor :cluster, :visited

  #Extend the MongoMapper EmbeddedDocument
  include MongoMapper::EmbeddedDocument

  key :id_str, 			String
  key :text, 				String
  key :user, 				String
  key :handle, 			String
  key :date, 				Time
  key :coordinates, Hash

  #Given a bson_tweet as returned from Mongo (or parsed via JSON),
  # It creates a tweet object
  def initialize(bson_tweet)
    @id_str = bson_tweet["id"]
    @text   = bson_tweet["text"]
    @user   = bson_tweet["user"]["id_str"]
    @handle = bson_tweet["user"]["screen_name"]
    @date   = bson_tweet["created_at"]
    @coordinates = bson_tweet["coordinates"]
  end

  #In order to call the tweet.point instance, it must be defined
  def as_point
    @point = @@geo_factory.point(
          @coordinates["coordinates"][0],
          @coordinates["coordinates"][1])
  end

  def items
    self.as_point
  end

  #To write the tweet to a kml file from epic-geo,
  # it must be formatted like so.
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
end
