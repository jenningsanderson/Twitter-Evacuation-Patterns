require_relative '/Users/jenningsanderson/Dropbox/OSM/osm-history/ruby/kml_writer_helper'
require 'mongo'
require 'georuby'
require 'geo_ruby/kml'




def write_tweets_kml(filename, cursor, db, title='KML FILE')
  puts "Attempting to write a kml file... this is new"

  file = KMLAuthor.new(filename)
  file.write_header(title)
  #file.generate_random_styles(5)
  file.write_3_bin_styles

  cnt = 0
  cursor.each_with_index do |user, i|
    cnt+=1


    this_user = {:name=>user['handle'], :folders=>[]}
    tweets = {:name=>"Tweets", :features=>[]}
    paths  = {:name=>"Paths", :features=>[]}
    random = rand(5) #Set a random color for this user

    user['tweets'].each_with_index do |tweet, j|
      coords = user['geometry']['coordinates'][j]
      link = nil
      unless tweet['entities']['urls'].empty?
        link = tweet['entities']['urls'][0]['expanded_url']
      end

      date = tweet['created_at']

      if date < Time.new(2012,10,27)
        style = '#before'
      elsif date < Time.new(2012,11,1)
        style = '#during'
      else
        style = '#after'
      end

      tweets[:features] << {
        :name => '',
        :geometry => GeoRuby::SimpleFeatures::Point.from_x_y(coords[0],coords[1]),
        :time => tweet['created_at'],
        :style => style,
        :link  => link,
        :desc => %Q{Time:  #{tweet['created_at']}<br />
                    User:  #{user['handle']}<br />
                    Text:  #{tweet['text']}}
      }
      if j+1 < user['tweets'].length
        line_coords = [coords, user['geometry']['coordinates'][j+1]]
        paths[:features] << {
          :name =>"TweetPath",
          :style =>"#r_style_#{random}",
          :geometry=> GeoRuby::SimpleFeatures::LineString.from_coordinates(line_coords),
          :time =>user['tweets'][j+1]['created_at']
        }
      end
    end

    this_user[:folders] << paths << tweets

    file.write_folder(this_user)

    if (i%10).zero?
      puts "Processed #{i} users"
    end
  end
  file.write_footer
  puts "Found #{cnt} users"
end





if __FILE__ == $0
  options = OpenStruct.new
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: ruby kml_output.rb -c COLLECTION  -f FILENAME [-l LIMIT]"
      opts.separator "\nSpecific options:"
      opts.on("-c", "--collection Collection Name",
              "Name of Collection (edited_tweets, userpaths)"){|v| options.c = v }
      opts.on("-f", "--filename Output Filename",
              "Name of output file"){|v| options.filename = v }
      opts.on("-l", "--limit [LIMIT]",
              "[Optional] Limit of users to parse"){|v| options.limit = v.to_i }
      opts.on("-t", "--title [TITLE]",
              "[Optional] Give a title for the KML document"){|v| options.title = v }
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end
    opts.parse!(ARGV)
    unless options.c and options.filename
      puts opts
      exit
    end
    options.limit ||= 100000

    mongo_conn = Mongo::MongoClient.new
    DB = mongo_conn['sandygeo']
    COLL = DB[options.c]


    identified_users = ['Max_Not_Mark','xxBang_Bang','leroyjabari','molly_mcgregor',
      'noreanc','BxMixPapii90','GreggTavella','ElCrupi','Aescano','Tofiquee',
      'AbieT90','LBL4Life1','inthewordsofkim','dev_thompson495','Ko0lgoSh', 'iKhoiBui']


    query = COLL.find({'handle' => {'$in'=>identified_users}}).first(options.limit)

    puts "Processing #{query.count()} Users"

    #write_user_bounding_envelopes(options.filename, uids, options.db)
    #write_user_changesets(options.filename, uids, options.db)
    write_tweets_kml(options.filename, query, options.db, title=options.title)

  end
