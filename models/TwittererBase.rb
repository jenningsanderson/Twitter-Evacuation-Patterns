# Basic Twitterer Model
#
# This is the most basic Twitterer.  It strictly relates Users to Tweets

require 'mongoid'

Mongoid.load("../config/mongoid.yml", :epicanalytics)

class TwittererBase

  #Define as mongoid document with many tweets
  include Mongoid::Document
  embeds_many :tweets

  #Define User fields
  field :id_str, type: String
  field :handle, type: String
  field :account_created, type: Date

  attr_reader :id_str, :tweets
  attr_writer :tweets #Need to be able to write tweets as well.


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
