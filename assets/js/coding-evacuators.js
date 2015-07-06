$(document).ready(function(){

  var p=d3.scale.category10();
  var s=d3.scale.ordinal();

  function prettyPrintTweetOnMap(feature, layer) {
    var html = ""
    Object.keys(feature.properties).forEach(function(label){
      html += "<strong>"+label.charAt(0).toUpperCase() + label.slice(1)+"</strong>: "+feature.properties[label]+"<br>"
    })
    layer.bindPopup(html);
  }

  function getUrlVars(variable){
    var query = window.location.search.substring(1);
    var vars = query.split("&");
    for (var i=0;i<vars.length;i++) {
      var pair = vars[i].split("=");
      if(pair[0] == variable){return pair[1];}
    }
    return('just_teevo');
  }

  //Call the map
  var map = L.map('map', {scrollWheelZoom: false}).setView([51.505, -0.09], 13);
  map.on('focus', function() { map.scrollWheelZoom.enable(); });

  // add an OpenStreetMap tile layer
  var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);
  //

  var user = getUrlVars("user");


  $.getJSON("/Twitter-Evacuation-Patterns/assets/geojson/coded_users/"+user+".geojson", function(data, err){
    // console.log(data)
    var tweets = L.geoJson(data,{
      onEachFeature : prettyPrintTweetOnMap,
      pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, {
          radius: feature.properties.cluster>-1? 8:3,
          fillColor: p(feature.properties.cluster),
          color: "#000",
          weight: feature.properties.cluster>0? 1:0.5,
          opacity: 1,
          fillOpacity: feature.properties.cluster>-1? 0.8:0.5
        });
      }
    })
    tweets.addTo(map)

    var sliderControl = L.control.sliderControl({position: "topright", layer: tweets, follow:5, rezoom:10});

    map.addControl(sliderControl);

    //And initialize the slider
    sliderControl.startSlider();

    map.fitBounds(tweets)

  })
})
