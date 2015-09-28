base_path = "/home/kena/geo_user_collection/"
subdirs   = ['geo1','geo2','geo3','geo4','geo5','geo6']

#Once in a directory, do this:
def get_jsons(dir)
  files = Dir[ File.join(dir, '**', '*') ].reject { |p| File.directory? p }
  files.select{|x| x.end_with?(".json")}
end


#Run the main runtime

if __FILE__ == $0

  subdirs.each do |subdir|
    json_files = get_jsons(base_path+subdir).first(200)

    puts json_files
  end

end
