#Ensure we're using the correct version of the gems
require 'rubygems'
require 'bundler/setup'
require 'parallel'

env  = ARGV[0] || 'serverlocal'
geo  = ARGV[1] || 'gem'
LIMIT   = 100
PROCESSES = (ARGV[2] || '2').to_i

require_relative '../movement_derivation_controller'
#Initialization:
runtime = TwitterMovementDerivation.new(
  environment: env,
  geo: geo,
  factory: 'global'
)


# ids = Twitterer.where({tweets: {'$size' => {'$gt' => 10}}, unclustered_percentage: nil}).each.collect{|t| t._id}
# puts "Found #{ids.count} ids"

# Twitterer.all.each do |user|
#   if user.tweets.count < 50 and user.tweets.count >
#     puts user
#   end
# end

# res = Parallel.map(ids.first(20)) do |id|
#   #
#   # Make a new everything for this process; then perhaps even split this into further threads?
#   #
#   # load('movement_derivation_controller.rb')
#   runtime = TwitterMovementDerivation.new(
#     environment: env,
#     geo: geo,
#     factory: 'global'
#   )
#
#   puts id
#
#   user = Twitterer.find(id)
#   puts user.handle
#   unless user.tweets.count == 0
#     puts user.handle
#     begin
#       user.process_tweets_to_clusters
#       user.save
#     rescue => e
#       puts "Something bad happened on #{user.handle}"
#       next
#     end
#     puts "-------FINISHED #{user.handle}-----------"
#   end
# end
