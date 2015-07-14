$(document).ready(function(){

  var p=d3.scale.category10();
  var s=d3.scale.ordinal();

  function prettyPrintTweetOnMap(feature, layer) {
    var html = ""
    Object.keys(feature.properties).forEach(function(label){
      if (label=="time"){
        html += "<strong>"+label.charAt(0).toUpperCase() + label.slice(1)+"*</strong>: "+local_date( feature.properties[label] ) +"<br>"
      }else{
        html += "<strong>"+label.charAt(0).toUpperCase() + label.slice(1)+"</strong>: "+feature.properties[label]+"<br>"
      }
    })
    layer.bindPopup(html);
  }

  function local_date(string){
    return moment.tz(new Date(string),"America/New_York").format('llll')
  }

  //Call the map
  var map = L.map('frankenstorm_map', {scrollWheelZoom: false}).setView([51.505, -0.09], 13);
  map.on('focus', function() { map.scrollWheelZoom.enable(); });

  // add an OpenStreetMap tile layer
  var tiles = L.tileLayer('http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://cartodb.com/attributions">CartoDB</a>'
  }).addTo(map);
  //
  var tweets = undefined

  $.getJSON("/Twitter-Evacuation-Patterns/assets/geojson/frankenstorm_apocalypse_checkins.geojson", function(data, err){
    console.log(data)
    var pts = L.geoJson(data,{
      onEachFeature : prettyPrintTweetOnMap,
      pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, {
          radius: Math.sqrt(feature.properties.count),
          color: p(Math.sqrt(feature.properties.count)),
          weight: 1,
          opacity: 0.8,
          fillOpacity: 0.8
        });
      }
    })
    pts.addTo(map)
    map.fitBounds(pts)
  })
  // var sliderControl = L.control.sliderControl({position: "topright", layer: tweets, follow:5, rezoom:10});

  // map.addControl(sliderControl);

  //And initialize the slider
  // sliderControl.startSlider();


})
