require 'spec_helper'

require_relative '../models/twitterer'

describe Twitterer do

	before :all do 
		MongoMapper.connection = Mongo::Connection.new# (Local)
		MongoMapper.database = 'sandygeo'
	end

	it "Can access the Geo Functions" do
		user = Twitterer.where(handle: "iKhoiBui").first

		puts user.tweets.first.inspect
	end
end