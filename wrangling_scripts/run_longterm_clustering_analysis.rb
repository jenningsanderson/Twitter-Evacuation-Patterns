require_relative '../movement_derivation_controller'

env  = ARGV[0] || 'server'
geo  = ARGV[1] || 'gem'
runtime = TwitterMovementDerivation.new(
  environment: env,
  geo: geo,
  factory: 'global'
)

require 'parallel'

LIMIT   = 100
PROCESSES = (ARGV[2] || '2').to_i

alpha = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']

res = Parallel.map(alpha.first(PROCESSES)) do |letter|
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
