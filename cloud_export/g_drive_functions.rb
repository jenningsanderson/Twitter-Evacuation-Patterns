require 'YAML'

def read_config
	config = YAML::load(File.open('_config.yml'))
	if File.exists?(config['credentials'])
		puts "Loading credentials from config location"
			credentials = YAML::load(File.open(config['credentials']))
		else
	end

	return config,credentials
end