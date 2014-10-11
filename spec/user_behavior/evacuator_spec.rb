#
# Testing functions for Evacuation Behavior
#
#
#
require 'spec_helper'

describe UserBehavior do

	before :all do
		@users = Twitterer.where(:base_cluster_risk=>20)
	end

	it "Can determine the distance between a user's base and storm cluster" do 
		user = @users.first

		puts "#{user.handle} \n\tHome: #{user.base_cluster}"

		storm_cluster = user.during_storm_cluster

		puts "\tStorm: #{storm_cluster}"

		distance = user.base_cluster_point.distance(user.cluster_as_point(storm_cluster))/1000

		puts "\tDistance: #{distance}"
	end

	xit "Can develop a movement profile for a user" do 

		user = @users.first

		user.two_days_tweets.each do |t|
			puts t.cluster
		end

	end

	it "Can determine if a user may have evacuated" do
		evacs = 0
		sips  = 0
		@users.each do |user|
			if user.evacuated?
				evacs +=1
				puts user.sanitized_handle
				
			else
				sips += 1
			end
		end
		puts "Evacuators: #{evacs}"
		puts "SIPS: #{sips}"
	end

end