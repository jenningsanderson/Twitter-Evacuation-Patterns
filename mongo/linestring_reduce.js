db.usertracks.drop();

var mapFunc = function(){
	emit(this.user.id_str, this.coordinates.coordinates);
};

var reduceFunc = function(keyUserId, valuesGeoCoordinates){
	reducedVal = {coords : [], numPoints : 0, geo : {}}

	valuesGeoCoordinates.forEach( function(item) {
		reducedVal.coords.push(item);
		reducedVal.numPoints += 1;
	});

	return reducedVal
};

var finalizeFunc = function (key, reducedVal) {
	if (reducedVal.numPoints == 1){
		reducedVal.geo = {"type" : "Point", "coordinates" : reducedVal.coords};
	}else{
		reducedVal.geo = {"type" : "LineString", "coordinates" : reducedVal.coords};
	}
	return reducedVal;
};

t.mapReduce(mapFunc, reduceFunc, { out : "usertracks", finalize: finalizeFunc, jsMode : true, sort: {"user.id_str" : 1}});
db.usertracks.ensureIndex({"value.geo" : "2dsphere"});