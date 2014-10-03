#
# Cluster Tweets
#
# => This runtime goes through the Twitterers collection and clusters a user's tweets.
# => Importantly, it embeds the cluster into the tweet on save.
#

#This is the default, this could be incorporated into a specific gem? config? something...

require_relative '../config.rb'

if __FILE__ == $0
	
	results = Twitterer.where(:tweet_count.lte => 500, :flag.ne => "newest cluster run")

	count = results.count
	puts "Found #{count} results" 

	results.each_with_index do |user, index|
		begin
			puts user.handle
			user.process_tweets_to_clusters
			user.flag = "newest cluster run"
		rescue => e
			puts "Error!"
			puts e.backtrace
			user.flag = "clustering error"
		end
		user.save

		if (index%100).zero?
			puts "-------Processed #{index} / #{count}------------"
		end
	end
end