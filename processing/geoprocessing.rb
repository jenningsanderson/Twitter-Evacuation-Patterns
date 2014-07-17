#This file will hold a series of algorithms for determining different pieces of information for a user

#This is strictly for processing.  These methods should not make outside calls

#Algorithm adopted from Andrew Hardin's C# function.
def find_median_point(points_array)
	x = []
	y = []
	points_array.each do |point|
		x << point[0]
		y << point[1]
	end
	x.sort!
	y.sort!
	if (points_array.length % 2).zero?
		mid = x.length/2
		return [ (x[mid]+x[mid-1]) /2.0, (y[mid]+y[mid-1])/2.0]
	else
		mid = x.length/2
		return [x[mid],y[mid]]
	end
end


def find_shelter_location(points_array, times)

	#Use the timestamp with the points in order to build a pattern.
	#Bin size will have to be determined automatically?

	#This part depends on regularity among a user

	#=> Split the times up by histogram, all depends on how many we have.

	unless times.sort == times
		exit(0)
	end

	full_window = times.last - times.first

	bin_size = full_window/(times.count/3) #Should have at least 3 tweets per bin?

	#Need to do a bit more brainstorming on this one


	#Build the bins, then put the indices into the times (don't care about day?)
end


#For testing purposes
if __FILE__ == $0
	test_points = [[0,0],[5,5],[3,3],[2,2],[4,4]]
	print find_median_point(test_points)

end
