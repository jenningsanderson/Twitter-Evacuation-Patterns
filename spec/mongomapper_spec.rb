require 'spec_helper'

require_relative '../models/twitterer'

describe Twitterer do

	before :all do 
		MongoMapper.connection = Mongo::Connection.new# (Local)
		MongoMapper.database = 'sandygeo'
	end

	it "Can search the Twitterer collection using MongoMapper" do
		user = Twitterer.where(handle: "iKhoiBui").first

		expect user.tweets.count > 3
	end
end