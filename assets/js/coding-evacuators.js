$(document).ready(function(){

  var p=d3.scale.category10();
  var s=d3.scale.ordinal();

  var coded_users =  ["GinaBoop21", "4thFloorWalkUp", "acbrush", "1903barisdamci", "aalhaider84", "977wctyJesse", "D_AGOSTINO", "AdieMeshel", "rcrocetti", "acdm", "onacitaveoz", "ccompitiello", "3ltutuykt", "2fritters", "502BIGBLOCK", "JFranxMon", "aby_orozco", "246TiffTiff", "nikkovision", "acdcrocker94", "forero29", "txcoonz", "voudonchilde", "adiesaurus", "abestt", "aaronlugo20", "yogabeth218", "AdamBroitman", "compa_tijero", "37kyle", "12CornersNYC", "ABerneche11", "hatchedit", "aanniemal", "ryryrocketss", "AbdulazizSadeq", "JoeeSmith19", "acordingley", "a13xandraaaa", "WaitingQueen", "danielleleiner", "abr74", "92Hughes92", "brittlizarda", "33amelie", "aidenscott", "5pointbuck", "aceytoso_2", "TravissGraham", "Nikki_DeMarco", "haleyybreen", "abrackin", "DDSethi", "haleighbethhh", "Mac_DA_45", "40Visionz", "b_mazzz", "132Sunshine", "1stFITNESSMC", "CluelessMaven", "adel1196", "aaziz830", "adawood30", "DbLeonor", "bakedtofu", "ActualyAmGeorge", "AdamVanBavel", "workfreelyblog", "HarriBoiii", "brieeellee", "AndeLund", "1Vincent", "Zach_Massari10", "Roze_316", "RedJazz43", "1xr650guy", "lizeeSuX", "4everSeductive", "AmberAAlonzo", "Kessel_Erich2", "adamebnit", "PainFresh6", "according2Drew", "Tyler_Mayer", "Sara_Persiano", "adampdouglas", "ACPressLee", "AdamHedenskog", "Caitles16", "adonatelle", "DJsonatra", "Scott_Gaffney", "GrooDs", "acwelch", "just_teevo", "mynameisluissss", "kcgirl2003"]

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

  coded_users.sort()

  coded_users.forEach(function(userName, idx){
    $('#user_list').append($("<li class='username-in-list'>").text(idx+1 + "_" + userName).click(function(user){
      putUserOnMap(userName)
    }));
  })

  //Call the map
  var map = L.map('map', {scrollWheelZoom: false}).setView([51.505, -0.09], 13);
  map.on('focus', function() { map.scrollWheelZoom.enable(); });

  // add an OpenStreetMap tile layer
  var tiles = L.tileLayer('http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',{
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://cartodb.com/attributions">CartoDB</a>'
  }).addTo(map);
  //
  var tweets = undefined

  function putUserOnMap(user){
    $("#current_user").text(user)
    if (tweets != undefined){
      map.removeLayer(tweets)
    }
    $('#tweet_texts').empty();
    $('#tweet_texts').append($("<tr class='tweet'>")
    .append("<td>Time*</td><td>Text</td><td>Cluster ID</td>"))
    $.getJSON("/Twitter-Evacuation-Patterns/assets/geojson/coded_users/"+user.toLowerCase()+".geojson", function(data, err){
      data.features.forEach(function(t){
        // console.log(data)
        if (t.geometry.type != "LineString" ){
          $('#tweet_texts').append($("<tr class='tweet'>")
            .append("<td>"+local_date( t.properties.time )+"</td><td>"+t.properties.text+"</td><td>"+t.properties.cluster+"</td>")
          )
        }
      })
      tweets = L.geoJson(data,{
        onEachFeature : prettyPrintTweetOnMap,
        pointToLayer: function (feature, latlng) {
          return L.circleMarker(latlng, {
            radius: feature.properties.cluster>-1? 8:3,
            fillColor: p(feature.properties.cluster),
            color: "#FFF",
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
  }
})
