#
# TweetBase Model
#

class TweetBase

  attr_reader :id_str, :text, :user_id_str, :handle, :created_at, :coordinates

  alias_method :date, :created_at
  
  #The Tweet is an embedded document for a Twitterer
  include MongoMapper::EmbeddedDocument

  #Keys for MM
  key :id_str, 			String
  key :text, 			  String
  key :user, 			  String
  key :handle, 		  String
  key :date, 			  Time
  key :coordinates, Hash

  # Given a bson_tweet as returned from Mongo (or parsed via JSON),
  # It creates a (basic) tweet object (args is a bson object)
  def initialize(args)
    @id_str      = args["id_str"]
    @text        = args["text"]
    @user_id_str = args["user"]["id_str"]
    @handle      = args["user"]["screen_name"]
    @created_at  = args["created_at"]
    @coordinates = args["coordinates"]

    post_initialize(args)
  end

  #Placeholder post_initialize function
  def post_initialize(args)
   nil
  end

  #To be implemented if there is an issue parsing data
  def ensure_proper_date(args)
    nil
  end

end
