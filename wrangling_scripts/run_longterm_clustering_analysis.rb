require_relative '../movement_derivation_controller'
require 'parallel'

env  = ARGV[0] || 'local'
geo  = ARGV[1] || 'gem'
runtime = TwitterMovementDerivation.new(
  environment: env,
  geo: geo,
  factory: 'global'
)

LIMIT   = 1000
PROCESSES = ARGV[2].to_i

split = []

res = Twitterer.where(unclustered_percentage: nil).limit(LIMIT)

res.each_slice(LIMIT/PROCESSES) do |group|
  split << group
end

puts split.count

Parallel.map(split) do |group|
  group.each do |user|
    unless user.tweets.count == 0
      puts user.handle
      puts "Calling Cluster"
      user.process_tweets_to_clusters
      puts "Finished Cluster"
      user.save
    end
  end
end
