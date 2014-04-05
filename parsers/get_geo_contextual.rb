'''
This script will look in the following directory to match a list of users

1. Connect to Mongo
2. Get the users we want (from the usertracks db)
3. Make the call to the contextual file, parse it, get only the geotagged tweet.
'''

require '../tweet_io'
require 'bson'
require 'date'
require 'time'

#/home/kena/geo_user_collection

#/home/kena/geo_user_collection/geo1/user_data/
# This goes through to geo6

class UserContextualCollection
  attr_accessor :session
  attr_reader   :root_path

  @@root_path = "/home/kena/geo_user_collection/"
  @@session = nil

  def initialize(user)
    #Get the subcategory
    if user[0] =~ /[[:alpha:]]/
      alph = user[0].downcase
    else
      alph = 'non'
    end

    @user = user.downcase

    (1..6).to_a.map!{|num| "geo#{num}"}.each do |section|
      if File.exists? "#{@@root_path}#{section}/user_data/#{alph}/#{@user}-contextual.json"
        @file_path = "#{@@root_path}#{section}/user_data/#{alph}/#{@user}-contextual.json"
        @in_stream  = File.open(@file_path,'r')
        break
      end
    end
  end

  def read_stream
    begin
      geo_count = 0
      @in_stream.each do |line|
        tweet = JSON.parse(line.chomp)
        if tweet['coordinates']

          this_session.collection.insert(tweet)

          geo_count += 1
          if geo_count.modulo(200).zero?
            puts "Found #{geo_count}, #{tweet['user']['screen_name']}: #{tweet['text']}"
          end
        end
      end
      puts "----------Total Tweets for #{@user}: #{geo_count}---------------\n"
    rescue
      p $!
      puts "Stream may not have existed for: #{@user}"
    end
  end

end #end UserContextualCollection Class


def get_users
  return false
end


if __FILE__ == $0
  puts "Running Contextual Extract for Users"

  #Open the Mongo connection for this session
  this_session = SandyMongoClient.new(limit=nil, db_name='sandygeo', coll='edited_tweets')
  user_screen_names = this_session.collection.distinct("user.screen_name").first(10)

  puts "Found #{user_screen_names.length} distinct screen_names in edited_tweeets"

  UserContextualCollection.session = this_session

  user_screen_names.each do |user|
    puts "User: #{user}"
    stream = UserContextualCollection.new(user, session)
    stream.read_stream
  end

end
