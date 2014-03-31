//db.usertracks.drop();

var mapFunc = function () {
	//Groups users with their coordinates
	emit(this.user.id_str, this.geo.coordinates);
};

var reduceFunc = function(keyUserId, valuesGeoCoordinates) {
	reducedVal = {coords : [], numPoints : 0, geo : {}}
	
	if (valuesGeoCoordinates[1].length==2){
		for (var idx = 0; idx < valuesGeoCoordinates.length; idx++) {
    		reducedVal.coords.push(valuesGeoCoordinates[idx]);
        	reducedVal.numPoints += 1;
        }
    }else{
    	reducedVal.numPoints = 1;
    }
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

//t.mapReduce(mapFunc, reduceFunc, { out : "usertracks", finalize: finalizeFunc, query : {"user.id_str":"100062671"}});

//db.usertracks.find().pretty();