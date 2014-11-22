# Basic Twitterer Model
#
# This is the most basic Twitterer.  It strictly relates Users to Tweets

require 'mongo_mapper'

require 'models/tweet' #Require the tweet

class TwittererBase
  
  #Define as mongoid document with many tweets
  include MongoMapper::Document
  set_collection_name "twitterers"
  
  many :tweets

  #Define User fields
  key :id_str,          String
  key :handle,          String
  key :account_created, Time    #Currently not implemented

  attr_reader :id_str

  def initialize(args)
    @id_str          = args[:id_str]
    @account_created = args[:account_created]
    @handle          = nil

    #A user's tweets are embedded in Mongo, but can be passed in as an array, if already processed
    @tweets          = args[:tweets] || []

    post_initialize(args)
  end

  def post_initialize(args)
    nil
  end

  def handle
    if @handle
      return @handle
    else
      return process_handle
    end
  end

  #A very basic handle processing function.  Ideally a user's first handle
  # and last hanle are the same, so that's their handle, otherwise, we'll
  # concatenate the two handles and call it good.
  def process_handle
    if tweets.first.handle == tweets.last.handle
      @handle = tweets.first.handle
    else
      @handle = tweets.first.handle + ", " + tweets.last.handle
    end
    @handle
  end

  def sanitized_handle
    return tweets.first.handle
  end

  def tweet_count
    tweets.count
  end

  def add_tweet(tweet)
    tweets << tweet
  end

  def sort_tweets_by_date
    tweets = @tweets.sort_by{|tweet| tweet.created_at}
  end

end
