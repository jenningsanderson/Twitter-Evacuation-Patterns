#Ensure we're using the correct version of the gems
require 'rubygems'
require 'bundler/setup'
require 'parallel'

env  = ARGV[0] || 'serverlocal'
geo  = ARGV[1] || 'gem'
LIMIT   = 100
PROCESSES = (ARGV[2] || '2').to_i

alpha = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']

res = Parallel.map(alpha.first(PROCESSES)) do |letter|
  #
  # Make a new everything for this process; then perhaps even split this into further threads?
  #
  require_relative '../movement_derivation_controller'
  runtime = TwitterMovementDerivation.new(
    environment: env,
    geo: geo,
    factory: 'global'
  )
  puts "Starting Process: #{letter}"
  Twitterer.where(unclustered_percentage: nil, handle: /^#{letter}/).limit(LIMIT).each do |user|
    unless user.tweets.count == 0
      puts user.handle
      user.process_tweets_to_clusters
      user.save
      puts "-------FINISHED #{user.handle}-----------"
    end
  end
end
