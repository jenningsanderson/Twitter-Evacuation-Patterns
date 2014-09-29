#
# We'll see if this goes anywhere... but I think we could learn a lot by setting up 
#  a network with a user's clusters and weighting edges appropriately?
#
# Look at extending the Ruby Graph Library Here...
#
#

#Eventually, I will pull this out into it's own GEM?
class Network #Inherit from RGL?

	def initialize(args)
		nil
	end
end


class ClusterNetwork < Network
	def initialize(args)
		super(args)
	end
end