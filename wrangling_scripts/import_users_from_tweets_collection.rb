# Connects to the current SandyGeo Edited Tweets database and then creates the
# twitterers collection based on the users from these tweets.


require 'mongo_mapper'

require_relative '../models/twitterer'
require_relative '../models/tweet'

#Static Setup
MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

conn = Mongo::MongoClient.new('epic-analytics.cs.colorado.edu')
db = conn['sandygeo']
coll = db['geo_tweets']

# limit = 10000000 #Hopefully an arbitrarily high limit

# puts "Running the User Import for #{limit} users"
# sandy_tweets = SandyMongoClient.new(limit=limit)

# existing_ids = Twitterer.distinct("id_str")

# puts "There are #{existing_ids.length} distinct users in the collection already"

# distinct_users = sandy_tweets.get_distinct_users

# puts "There are #{distinct_users.length} in the entire tweet collection"

# to_import = distinct_users - existing_ids

# puts "There are #{to_import.length} user ids left to import"

# puts "Iterating over the cursor and building more defined people objects"

#to_import = [ "10296692", "101937602", "10947242", "11089882", "112914465", "115402829", "11702052", "123905093", "12967532", "132016851", "133031798", "138040179", "14239599", "14308508", "145231158", "14570815", "146062518", "147070682", "14850313", "153988612", "15416112", "159657272", "159875851", "16227947", "16296246", "16303325", "16362685", "16638650", "16676499", "16824104", "16856879", "16975334", "17004113", "17162311", "172119315", "17638843", "17893558", "17913519", "18040825", "18113822", "187092357", "18837581", "18902267", "19304992", "19368410", "19409508", "209151977", "20940614", "21155077", "21359940", "21714240", "222895392", "226425184", "226428781", "226847420", "22833365", "22961538", "23120005", "237073998", "24128194", "24252370", "24583446", "24633201", "248387386", "261502505", "267723397", "27363375", "281832935", "28288155", "291910836", "29906317", "30088983", "30586066", "30868217", "310171149", "31107395", "313352511", "32254092", "34613882", "357905303", "360411897", "374592699", "384918074", "408930460", "43468317", "435878875", "437093226", "43847317", "442948981", "469339691", "470431443", "471720776", "49846765", "50041345", "50109029", "5147551", "5237281", "54096848", "54249904", "545476724", "561466624", "5730902", "575876070", "5947152", "6149582", "64252487", "6434092", "6585382", "68336363", "68478069", "73632124", "738012205", "76447685", "779106277", "7851542", "84723809", "867212690", "873918324", "9626672", "97135532"]
#to_import = ["9626672", "97135532"]

to_import.each_with_index do |uid, index|

  this_user = Twitterer.create( {:id_str => uid} )

  coll.find({"user.id_str" => uid}).each do |tweet|
    this_user.tweets << Tweet.new( tweet )
  end

  if (index%10).zero?
    print "..#{index}"
  end

  this_user.save
end

puts "\n-----------\n"
