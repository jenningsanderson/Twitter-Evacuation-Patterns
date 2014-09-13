require 'yaml'

def read_config
	config = YAML::load(File.open('_config.yml'))
	if File.exists?(config['credentials'])
		print "Loading credentials from config location..."
			credentials = YAML::load(File.open(config['credentials']))
		else
	end
	print "done\n"
	return config,credentials
end
