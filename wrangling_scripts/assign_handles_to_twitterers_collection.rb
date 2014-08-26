'''
A simple script to assign handles to the users
'''
require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'active_support/deprecation'
require 'mongo_mapper'

require 'mongo_mapper'

require_relative '../models/twitterer'
require_relative '../models/tweet'


#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

user = Twitterer.where(:id_str => "40888536").first

user.handle = "JLawMiamiDoll"

puts user.handle

user.save

# puts "Found #{results.count} users without handles"

# results.each_with_index do |user, i|
# 	puts user.id_str
# 	handles = []
# 	begin

# 		puts handles
		
# 		user.handle = "JLawMiamiDoll"
# 		user.save

# 		puts user.handle

# 		if (i%100).zero?
# 			print "#{i}.."
# 		end
# 	rescue => e 
# 		puts "Ahh!  An error occured with user: #{user.handle}"
# 		puts $!
# 		puts e.backtrace
# 		next
# 	end
# end