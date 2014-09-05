#Main requirements
require 'google_drive'
require 'yaml'

require_relative 'g_drive_functions'

#Configuration 
config,credentials = read_config

session = GoogleDrive.login(credentials[''], password)

class GoogleDriveYAMLParser

	attr_accessor :google_drive_data

	def initialize(username=nil, password=nil, site_config)
		@session = GoogleDrive.login(username,password)
		@site_config = site_config
	end

	def read_sheet(key, sheet, object_type, parameters) #That is, name of workbook and then sheet title

		ws = @session.spreadsheet_by_key