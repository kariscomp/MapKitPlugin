var exec = require('cordova/exec');
   
var MapKit = function() {
	this.mapType = {
		MAP_TYPE_NONE: 0, //No base map tiles.
		MAP_TYPE_NORMAL: 1, //Basic maps.
		MAP_TYPE_SATELLITE: 2, //Satellite maps with no labels.
		MAP_TYPE_TERRAIN: 3, //Terrain maps.
		MAP_TYPE_HYBRID: 4 //Satellite maps with a transparent layer of major streets.
	};

	this.iconColors = {
		HUE_RED: 0.0,
		HUE_ORANGE: 30.0,
		HUE_YELLOW: 60.0,
		HUE_GREEN: 120.0,
		HUE_CYAN: 180.0,
		HUE_AZURE: 210.0,
		HUE_BLUE: 240.0,
		HUE_VIOLET: 270.0,
		HUE_MAGENTA: 300.0,
		HUE_ROSE: 330.0
	};
};

// Returns bound rect of div
function getDivRect(div) {
   if (!div) {
       return;
   }
  
   var rect = div.getBoundingClientRect();
   var divRect = {
       'left': rect.left,
       'top': rect.top,
       'width': rect.width,
       'height': rect.height
   };
   
   return divRect;
}
           
// Returns calculated container size
function calculateContainerOptions(options) {
   if (!options.mapContainer) {
    return options;
   }
   var rect = getDivRect(options.mapContainer);
   options.left = rect.left;
   options.top = rect.top;
   options.width = rect.width;
   options.height = rect.height;
           
   var children = getAllChildren(options.mapContainer);
   var elements = [];
   var elemId, clickable;
   
   for (var i = 0; i < children.length; i++) {
       element = children[i];
       elemId = element.getAttribute("__pluginDomId");
       if (!elemId) {
           elemId = "pgm" + Math.floor(Math.random() * Date.now()) + i;
           element.setAttribute("__pluginDomId", elemId);
       }
       elements.push({
           id: elemId,
           size: getDivRect(element)
       });
       i++;
   }
   options.children = elements;
           
   return options;
}
           
function getAllChildren(root) {
   var list = [];
   var clickable;
   var style, displayCSS, opacityCSS, visibilityCSS;
   var search = function(node) {
       while (node != null) {
           if (node.nodeType == 1) {
               style = window.getComputedStyle(node);
               visibilityCSS = style.getPropertyValue('visibility');
               displayCSS = style.getPropertyValue('display');
               opacityCSS = style.getPropertyValue('opacity');
               if (displayCSS !== "none" && opacityCSS > 0 && visibilityCSS != "hidden") {
                   clickable = node.getAttribute("data-clickable");
                   if (clickable &&
                       clickable.toLowerCase() === "false" &&
                       node.hasChildNodes()) {
                       Array.prototype.push.apply(list, getAllChildren(node));
                   } else {
                       list.push(node);
                   }
               }
           }
           node = node.nextSibling;
       }
   };
   for (var i = 0; i < root.childNodes.length; i++) {
       search(root.childNodes[i]);
   }
   return list;
}
           
// Returns default params, overrides if provided with values
function setDefaults(options) {
	var defaults = {
		left: 0,
		top: 100,
		height: 0,
		width: 0,
		diameter: 1000,
		atBottom: false,
		lat: 49.281468,
		lon: -123.104446
	};

	if (options) {
		for(var i in defaults)
			if(typeof options[i] === "undefined")
				options[i] = defaults[i];
	} else {
		options = defaults;
	}

	return options;
}

MapKit.prototype = {

	showMap: function(success, error, options) {
		options = calculateContainerOptions(options);
		options = setDefaults(options);
		exec(success, error, 'MapKit', 'showMap', [options]);
	},

	addMapPins: function(pins, success, error) {
		exec(success, error, 'MapKit', 'addMapPins', [pins]);
	},

	clearMapPins: function(success, error) {
		exec(success, error, 'MapKit', 'clearMapPins', []);
	},

	hideMap: function(success, error) {
		exec(success, error, 'MapKit', 'hideMap', []);
	},

	changeMapType: function(mapType, success, error) {
		exec(success, error, 'MapKit', 'changeMapType', [mapType ? { "mapType": mapType } :{ "mapType": 0 }]);
	},

	drawPolyline: function(options, success, error) {
		exec(success, error, 'MapKit', 'drawPolylineOverlay', [options]);
	},

	drawPolygon: function(options, success, error) {
		exec(success, error, 'MapKit', 'drawPolygonOverlay', [options]);
	},

	setLocation: function(options, success, error) {
		exec(success, error, 'MapKit', 'setCenterLocation', [options]);
	},

	setRegion: function(options, success, error) {
		exec(success, error, 'MapKit', 'drawRegion', [options]);
	},

	getAddressFromCoordinate: function(options, success, error) {
		exec(success, error, 'MapKit', 'coordToAddress', [options]);
	},

	getCenterCoords: function(success, error) {
		exec(success, error, 'MapKit', 'getCurrentPosition', []);
	},
	
   	setClickable: function(options, success, error) {
   		exec(success, error, 'MapKit', 'setMapClickable', [options]);
   	}

};

module.exports = new MapKit();