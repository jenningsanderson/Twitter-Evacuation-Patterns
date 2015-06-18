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

  //Call the map
  var clusteringMap = L.map('clustering_map', {scrollWheelZoom: false}).setView([51.505, -0.09], 13);
  clusteringMap.on('focus', function() { clusteringMap.scrollWheelZoom.enable(); });

  // add an OpenStreetMap tile layer
  var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(clusteringMap);
  //

  $.getJSON("/Twitter-Evacuation-Patterns/assets/geojson/iKhoiBui_tweets_with_clusters.geojson", function(data, err){
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
    tweets.addTo(clusteringMap)
    clusteringMap.fitBounds(tweets)
  })

  //Call the map
  var allInBox = L.map('all_in_bounding_box', {scrollWheelZoom: false}).setView([51.505, -0.09], 13);
  allInBox.on('focus', function() { allInBox.scrollWheelZoom.enable(); });

  // add an OpenStreetMap tile layer
  var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(allInBox);
  //

  var markers = new L.MarkerClusterGroup();
  $.getJSON("/Twitter-Evacuation-Patterns/assets/geojson/base_risk_lt_100.geojson", function(data, err){
    // console.log(data)
    var users = L.geoJson(data,{
      onEachFeature : function(feature, layer){
        layer.bindPopup(feature.properties.handle.toString());
      },
      pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, {
          radius: 3,
          fillColor: "#F00",
          color: "#000",
          weight: 1,
          opacity: 0.8,
          fillOpacity: 0.8
        });
      }
    })
    markers.addLayer(users)
    allInBox.addLayer(markers)
    allInBox.fitBounds(markers)
  })


  //Call the map
  var coastalUsers = L.map('coastal_users', {scrollWheelZoom: false}).setView([51.505, -0.09], 13);
  coastalUsers.on('focus', function() { coastalUsers.scrollWheelZoom.enable(); });

  // add an OpenStreetMap tile layer
  var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(coastalUsers);
  //

  $.getJSON("/Twitter-Evacuation-Patterns/assets/geojson/base_risk_lt_50.geojson", function(data, err){
    // console.log(data)
    var riskUsers = L.geoJson(data,{
      onEachFeature : function(feature, layer){
        layer.bindPopup(feature.properties.handle.toString());
      },
      pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, {
          radius: 3,
          fillColor: feature.properties.coded? "#00F" : "#F00",
          color: "#000",
          weight: 1,
          opacity: 0.8,
          fillOpacity: feature.properties.coded? .8 : .5
        });
      }
    })
    riskUsers.addTo(coastalUsers)
    coastalUsers.fitBounds(riskUsers)
  })

  //Call the map
  var codedUsers = L.map('coded_users', {scrollWheelZoom: false}).setView([51.505, -0.09], 13);
  codedUsers.on('focus', function() { codedUsers.scrollWheelZoom.enable(); });

  // add an OpenStreetMap tile layer
  var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(codedUsers);
  //

  $.getJSON("/Twitter-Evacuation-Patterns/assets/geojson/coded_users_locations.geojson", function(data, err){
    // console.log(data)
    var codedUsersLayer = L.geoJson(data,{
      onEachFeature : function(feature, layer){
        layer.bindPopup(feature.properties.handle.toString());
      },
      pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, {
          radius: 3,
          fillColor: "#00F",
          color: "#000",
          weight: 1,
          opacity: 0.8,
          fillOpacity: 0.8
        });
      }
    })
    codedUsersLayer.addTo(codedUsers)
    codedUsers.fitBounds(codedUsersLayer)
  })


  //Call the map
  var riskLevels = L.map('risk_levels', {scrollWheelZoom: false}).setView([51.505, -0.09], 13);
  riskLevels.on('focus', function() { riskLevels.scrollWheelZoom.enable(); });

  // add an OpenStreetMap tile layer
  var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(riskLevels);
  //

  var riskLayers = {}
  var bounds = undefined
  $.getJSON("/Twitter-Evacuation-Patterns/assets/geojson/affected_boundaries.geojson", function(data, err){
    data.features.forEach(function(feature){
      // console.log(feature)
      var layer = L.geoJson(feature,{
        onEachFeature : function(feature, layer){
          layer.bindPopup("<strong>Name</strong>: " + feature.properties["Name"] + "<br><strong>Risk:</strong> "+feature.properties["Risk"]);
          }
        })
      riskLayers[feature.properties["Name"]] = layer
      layer.addTo(riskLevels)
      bounds = layer.getBounds()
    });
    // console.log(riskLayers)
    L.control.layers(null, riskLayers).addTo(riskLevels);
    riskLevels.fitBounds(bounds)
  })


  //Call the map
  var riskLevelByUser = L.map('risk_level_by_user', {scrollWheelZoom: false}).setView([39, -90], 8);
  riskLevelByUser.on('focus', function() { riskLevelByUser.scrollWheelZoom.enable(); });

  // add an OpenStreetMap tile layer
  var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(riskLevelByUser);
  //

  layers = {
    "NJ_Users" : L.geoJson().addTo(riskLevelByUser),
    "Coastal-2k" : L.geoJson().addTo(riskLevelByUser),
    "Coastal-4k" : L.geoJson().addTo(riskLevelByUser)
  }
  $.getJSON("/Twitter-Evacuation-Patterns/assets/geojson/base_risk_38.geojson", function(data, err){
    console.log(data)
    layers["NJ_Users"].addData(data,{
      onEachFeature : function(feature, layer){
        layer.bindPopup(feature.properties.handle.toString());
      },
      pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, {
          radius: 3,
          fillColor: feature.properties.coded? "#00F" : "#F00",
          color: "#000",
          weight: 1,
          opacity: 0.8,
          fillOpacity: feature.properties.coded? .8 : .5
        });
      }
    })
  })
  $.getJSON("/Twitter-Evacuation-Patterns/assets/geojson/base_risk_39.geojson", function(data, err){
    console.log(data)
    layers["Coastal-2k"].addData(data,{
      onEachFeature : function(feature, layer){
        layer.bindPopup(feature.properties.handle.toString());
      },
      pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, {
          radius: 3,
          fillColor: feature.properties.coded? "#00F" : "#F00",
          color: "#000",
          weight: 1,
          opacity: 0.8,
          fillOpacity: feature.properties.coded? .8 : .5
        });
      }
    })
  })
  $.getJSON("/Twitter-Evacuation-Patterns/assets/geojson/base_risk_40.geojson", function(data, err){
    console.log(data)
    layers["Coastal-4k"].addData(data,{
      onEachFeature : function(feature, layer){
        layer.bindPopup(feature.properties.handle.toString());
      },
      pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, {
          radius: 3,
          fillColor: feature.properties.coded? "#00F" : "#F00",
          color: "#000",
          weight: 1,
          opacity: 0.8,
          fillOpacity: feature.properties.coded? .8 : .5
        });
      }
    })
  })

  L.control.layers(null, layers).addTo(riskLevelByUser)
  // riskLevelByUser.fitBounds(layers["NJ_Users"])


})
