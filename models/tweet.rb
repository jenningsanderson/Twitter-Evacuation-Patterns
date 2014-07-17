'''
Tweet Model.  A stripped version of a tweet with just the necesseties.
'''

require 'mongo_mapper'
require 'active_model'

class Tweet

  #Using MongoMapper for Strength
  include MongoMapper::EmbeddedDocument

  key :id_str, 			String
  key :text, 				String
  key :user, 				String
  key :handle, 			Array
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
end
