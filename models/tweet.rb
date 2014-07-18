'''
Tweet Model.  A stripped version of a tweet with just the necesseties.
'''

require 'mongo_mapper'
require 'active_model'
require 'georuby'

class Tweet

  #Using MongoMapper for Strength
  include MongoMapper::EmbeddedDocument

  key :id_str, 			String
  key :text, 				String
  key :user, 				String
  key :handle, 			String
  key :date, 				Time
  key :coordinates, Hash


  def initialize(bson_tweet)
    @id_str = bson_tweet["id"]
    @text   = bson_tweet["text"]
    @user   = bson_tweet["user"]["id_str"]
    @handle = bson_tweet["user"]["screen_name"]
    @date   = bson_tweet["created_at"]
    @coordinates = bson_tweet["coordinates"]
  end

  def as_epic_kml(style=nil)
    {:time     => @date,
     :style    => style,
     :geometry => GeoRuby::SimpleFeatures::Point.from_x_y(
       @coordinates["coordinates"][0],
       @coordinates["coordinates"][1] ),
     :name     => @handle,
     :desc     =>
     %Q{ Name: #{@handle}
     Text: #{@text}}
    }
  end
end
