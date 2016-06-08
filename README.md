# MapKit plugin for iOS
=================================

You can install this plugin with cordova CLI

    cordova plugin add <Local Path to MapKit Plugin>
	
Follow the instructions that are displayed after you install the plugin.


Sample usage code
-----------------
```js
var app = {
    showMap: function() {
        var pins = [
            {
                lat: 49.28115,
                lon: -123.10450,
                title: "A Cool Title",
                snippet: "A Really Cool Snippet",
                icon: mapKit.iconColors.HUE_ROSE
            },
            {
                lat: 49.27503,
                lon: -123.12138,
                title: "A Cool Title, with no Snippet",
                icon: {
                    type: "asset",
                    resource: "www/img/max.png", //an image in the asset directory
                    pinColor: mapKit.iconColors.HUE_VIOLET //iOS only
                }
            },
            {
                lat: 49.28286,
                lon: -123.11891,
                title: "Awesome Title",
                snippet: "Awesome Snippet",
                icon: mapKit.iconColors.HUE_GREEN
            }
        ];
        var container = document.getElementById("map_canvas");
        var options = {
            mapContainer: container
        };
        mapKit.showMap(function(){
            mapKit.addMapPins(pins, function() {
                console.log('adMapPins success');
            }, function() { 
                console.log('error'); 
            });
        }, function(err){
            alert(JSON.stringify(err));
        }, options);
    },
    hideMap: function() {
        var success = function() {
          console.log('Map hidden');
        };
        var error = function() {
          console.log('error');
        };
        mapKit.hideMap(success, error);
    },
    clearMapPins: function() {
        var success = function() {
          console.log('Map Pins cleared!');
        };
        var error = function() {
          console.log('error');
        };
        mapKit.clearMapPins(success, error);
    },
    changeMapType: function() {
        var success = function() {
          console.log('Map Type Changed');
        };
        var error = function() {
          console.log('error');
        };
        mapKit.changeMapType(mapKit.mapType.MAP_TYPE_SATELLITE, success, error);
    },
    setCoordinate: function() {
        var success = function() {
          console.log('Map Camera Changed');
        };
        var error = function() {
          console.log('error');
        };
        var options = {
            coordinate: {lat: 49.27503, lon: -123.12138},
            zoomLevel: 5,
            animated: true
        };
        mapKit.setLocation(options, success, error);
    },
    getCenterCoords: function() {
        mapKit.getCenterCoords(function(response) {
            alert(JSON.stringify(response));
        }, function(err) {
            console.log(err);
        });
    },
    drawRegion: function() {
        var options = {
            coord: {lat: 49.27503, lon: -123.12138},
            radius: 2000,
            lineColor: {
                red: 0,
                green: 255,
                blue: 0,
                alpha: 1,
            },
            fillColor: {
                red: 0,
                green: 0,
                blue: 255,
                alpha: 0.6
            }
        };
        var success = function() {
          console.log('Drew circle');
        };
        var error = function() {
          console.log('error');
        };
        mapKit.setRegion(options, success, error);
    },
    drawPolyline: function() {
        var pins = [
            {
                lat: 50.28115,
                lon: -121.10450
            },
            {
                lat: 49.27503,
                lon: -123.12138
            },
            {
                lat: 50.28286,
                lon: -124.11891
            }
        ];
        var options = {
            path: pins,
            lineColor: {
                red: 100,
                green: 200,
                blue: 150,
                alpha: 1
            },
            lineWidth: 3
        };
        var success = function() {
          console.log('Drew Polyline');
        };
        var error = function() {
          console.log('error');
        };
        mapKit.drawPolyline(options, success, error);
    },
    drawPolygon: function() {
        var pins = [
            {
                lat: 50.28115,
                lon: -121.10450
            },
            {
                lat: 49.27503,
                lon: -123.12138
            },
            {
                lat: 50.28286,
                lon: -124.11891
            }
        ];
        var options = {
            path: pins,
            strokeColor: {
                red: 100,
                green: 200,
                blue: 150,
                alpha: 1
            },
            fillColor: {
                red: 0,
                green: 100,
                blue: 150,
                alpha: 0.3
            },
            borderWidth: 2
        };
        var success = function() {
          console.log('Drew Polygon');
        };
        var error = function() {
          console.log('error');
        };
        mapKit.drawPolygon(options, success, error);
    },
    getAddress: function() {
        mapKit.getAddressFromCoordinate({
            lat: 49.27503,
            lon: -123.12138
        }, function(response) {
            alert(JSON.stringify(response));
        }, null);
    },
    setMapClickable: function() {
        mapKit.setClickable(false);
    }
};
```
