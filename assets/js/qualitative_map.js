$(document).ready(function(){

  //Get the query variable...
  function getQueryVariable(variable)
  {
         var query = window.location.search.substring(1);
         var vars = query.split("&");
         for (var i=0;i<vars.length;i++) {
                 var pair = vars[i].split("=");
                 if(pair[0] == variable){return pair[1];}
         }
         return(false);
  }

  //http://stackoverflow.com/questions/1960473/unique-values-in-an-array
  function onlyUnique(value, index, self) { 
    return self.indexOf(value) === index
  }

  // function updateFilters(){
  //   // Create a filter interface.
  //   for (var i = 0; i < uniqueCodes.length; i++) {
  //     // Create an an input checkbox and label inside.
  //     var item = filters.appendChild(document.createElement('div'));
  //     var checkbox = item.appendChild(document.createElement('input'));
  //     var label = item.appendChild(document.createElement('label'));
  //     checkbox.type = 'checkbox';
  //     checkbox.id = uniqueCodes[i];
  //     checkbox.checked = true;
  //     // create a label to the right of the checkbox with explanatory text
  //     label.innerHTML = uniqueCodes[i];
  //     label.setAttribute('for', uniqueCodes[i]);
  //     // Whenever a person clicks on this checkbox, call the update().
  //     checkbox.addEventListener('change', drawMap);
  //     checkboxes.push(checkbox);
  //   }
  // }

  // add an OpenStreetMap tile layer
  var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  });

  var user = getQueryVariable("user");

  var uniqueCodes = ["Personal","Environment","Sentiment","Preparation","Movement"]
  
  // var filters = document.getElementById('filters'); //List of filters

  //create layers based on this data, then add them individually
  $.getJSON("/Twitter-Evacuation-Patterns/datasets/qualmaps/"+user+".json", function(data) {
    
    for (item in data){
      console.log(item)
    }
  });

  //The draw function
  function drawMap() {
    
    // Run through each checkbox and record whether it is checked. If it is,
    // add it to the object of types to display, otherwise do not.
    // for (var i = 0; i < checkboxes.length; i++) {
    //   if (checkboxes[i].checked) enabled.push([checkboxes[i].id]);
    // }

    //Load the GeoJSON + add to geojson layer
    $.getJSON("/Twitter-Evacuation-Patterns/datasets/qualmaps/"+user+".json", function(data) {
      var geojson = L.geoJson(data, {
        onEachFeature: function (feature, layer) {
          layer.bindPopup(feature.properties['time'] + " : " + feature.properties.text);
          
          //Check if coding is available for this layer
          if (feature.coding != undefined){
            
            //Add these codes
            //codes.push.apply(codes, Object.keys(feature.coding) );

            for (code in uniqueCodes){
              var thisCode = (uniqueCodes[code])
              
              if (feature.coding[thisCode] != undefined){
                layer.setIcon(L.icon({
                  iconUrl: '/Twitter-Evacuation-Patterns/assets/icons/'+feature.coding[thisCode][0]+'.png',
                  iconSize: [25,25]}));
                console.log(thisCode + feature.coding[thisCode])
              }
            }
          }
        }
      });

      //Call the map
      var map = L.map("map").fitBounds(geojson.getBounds());

      //Add baselayer
      tiles.addTo(map);
      
      //Add GeoJSON
      geojson.addTo(map);

      //https://github.com/dwilhelm89/LeafletSlider
      var sliderControl = L.control.sliderControl({
        position: "topright",
        layer: geojson,
        range: true
      });

      var baseMaps = {"Basemap": tiles};
      var overlayMaps = {"Points" : geojson, 
        "Sentiment"  : sentiment,
        "Preparation": preparation,
        "Movement"   : movement,
        "Assessment" : assessment};

      //Add layers control
      L.control.layers(baseMaps, overlayMaps).addTo(map);

      //Make sure to add the slider to the map ;-)
      map.addControl(sliderControl);
      
      //And initialize the slider
      sliderControl.startSlider();
    });
  }
  drawMap();
});