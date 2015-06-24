require 'models/tweet'

#=Basic Twitterer Model
#
#This is the most basic Twitterer.  It strictly relates Users to Tweets
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
    @handle          = args[:handle]
    @tweets           = args[:tweets]

    post_initialize(args)
  end

  def post_initialize(args)
    nil
  end

  #Helper function
  def handle
    unless @handle.nil?
      process_handle
    end
    @handle
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

  #Get all of a user's contextual stream tweets
  def contextual_stream
    # TODO: collect all geo-tagged tweets from the user's contextual stream
    # this is going to be all of a user's tweets
  end

  #Get all of a user's keyword tweets only
  def keyword_tweets
    # TODO: collect all geo-tagged tweets from just the keyword search
  end

  #If a user has multiple handles, return just the handle used in their first tweet
  def sanitized_handle
    return tweets.first.handle
  end

  #Returns the number of tweets
  def tweet_count
    tweets.count
  end

  #Add a tweet object to this Twitterer's tweets collection
  def add_tweet(tweet)
    tweets << tweet
  end

  #Set & return a user's tweets to be sorted by the Tweet#created_at function
  def sort_tweets_by_date
    tweets = @tweets.sort_by{|tweet| tweet.created_at}
  end

end
