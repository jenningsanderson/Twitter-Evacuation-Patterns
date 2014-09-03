#Sandbox 2 for running locally on server

require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'active_support/deprecation'
require 'mongo_mapper'

require_relative '../models/twitterer'
require_relative '../models/tweet'

MongoMapper.connection = Mongo::Connection.new('epic-analytics.cs.colorado.edu')
MongoMapper.database = 'sandygeo'

ml_output = File.open("/home/kevin/Documents/Epic/Evacuation/ML/ml_input", "w")
ann_input = File.open("/home/kevin/Documents/Epic/Evacuation/Annotations/evac_ann")
user_list = File.open("/home/kevin/Documents/Epic/Evacuation/Annotations/users")

def p_and_r (stats, category)
  correct = 0.0
  false_pos = 0.0
  false_neg = 0.0
  for s in stats
    ann = s[1][0]
    pred = s[1][1]
    if ann == pred and ann == category
      correct += 1
    elsif ann != pred and ann == category
      false_neg += 1
    elsif ann != pred and pred == category
      false_pos += 1
    end
  end

  prec = correct / (correct + false_pos)
  rec = correct / (correct + false_neg)
  f1 = 2 / ((1/prec)+(1/rec))
  return {"precision"=>prec, "recall"=>rec, "f1"=>f1}
end

def counts(stats)
  total = 0
  count = 0
  total_anns = Hash.new
  for item in stats
    if not item[1].include? nil
      ann = item[1][0]
      pred = item[1][1]
      if pred == 2
        count += 1
      end
      if total_anns.include? ann
        total_anns[ann] += 1
      else
        total_anns[ann] = 1
      end
      total += 1
    end
  end
  puts "count of 2 : " + count.to_s
  return [total, total_anns]
end

users = user_list.readlines().map{|x| x.strip}

results = Twitterer.where(
  :hazard_level_before.lt=>100
)
puts results.count

annotation_data = Array.new
ann_input_data = ann_input.readlines()
for line in ann_input_data.slice(1, ann_input_data.length)
  data = line.split(",")
  if data[0].length > 0
    if data[1] == "1"
      evac = 2
    elsif data[2] == "1"
      evac = 1
    elsif data[3] == "1"
      evac = 0
    end
    annotation_data.push(line.split(",")[0] + " " + evac.to_s)
  end
end


#for i in [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
  stats = Hash.new
  num = 0
  results.each_with_index do |user, index|
    num += 1
    puts "count : " + num.to_s
    user.movement_analysis(1, 19)
    #for user_annotation in annotation_data
    #  if user_annotation.split()[0] == user.handle and user_annotation.split()[1] != "0"
    #    user_ann = user_annotation.split()[1].to_i
        
        if not user.unclassifiable
          if user.evac_conf > user.sip_conf
            stats[user.handle] = [0, 2]
          else
            stats[user.handle] = [0, 1]
          end
        else
          stats[user.handle] = [0, 0]
        end
        #ml_output.write(user.handle + " " + user.movement_analysis.join(" ") + " " + user_annotation.split()[1] + "\n")       
      #end  
    #end
  end

  data = p_and_r(stats, 2)
  counts(stats)
  #puts "Shelter weight : " + i.to_s + " Evac weight : " + (10-i).to_s + " Stats : " + p_and_r(stats, 2).to_s  
#  puts i.to_s + " " + data["precision"].to_s + " " + data["recall"].to_s + " " + data["f1"].to_s
#end
