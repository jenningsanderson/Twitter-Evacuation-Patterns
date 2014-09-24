# TweetBase Model
#
# The basic superclass for all tweets
#

require 'mongoid'

class TweetBase

  attr_reader :id_str, :text, :user_id_str, :handle, :created_at, :coordinates

  alias_method :created_at, :date
  #Setup as a MongoID document embedded in a Twitterer
  include Mongoid::Document
  embedded_in :Twitterer

  #Fields
  field :id_str, 			type: String
  field :text, 				type: String
  field :user, 				type: String
  field :handle, 			type: String
  field :date, 				type: Time
  field :coordinates, type: Hash

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

  def post_initialize(args)
    nil
  end

  #To be implemented if there is an issue parsing data
  def ensure_proper_date(args)
    nil
  end

  #If a user has a handle with a space in it or a comma, just replace those with an underscore
  def sanitized_handle
    handle.gsub(/(\s+|,)/,"_")
  end

end
