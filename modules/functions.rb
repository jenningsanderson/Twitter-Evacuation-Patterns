#
# Various functions
#
#
#

module CustomFunctions

	def mode(array)
		if array.empty? or array.nil?
			return nil
		else
			#http://stackoverflow.com/questions/412169/ruby-how-to-find-item-in-array-which-has-the-most-occurrences
			array.group_by{|i| i}.max{|x,y| x[1].length <=> y[1].length}[0]
		end
	end

end