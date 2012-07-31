/*!
 * jQuery UI Google Map 3.0-rc
 * http://code.google.com/p/jquery-ui-map/
 * Copyright (c) 2010 - 2012 Johan Säll Larsson
 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
 *
 * Depends:
 *		jquery.ui.map.js
 */
(function(a){a.extend(a.ui.gmap.prototype,{displayDirections:function(a,b,c){var d=this,e=this.get("services > DirectionsService",new google.maps.DirectionsService),f=this.get("services > DirectionsRenderer",new google.maps.DirectionsRenderer);b&&f.setOptions(b),e.route(a,function(a,b){b==="OK"?(f.setDirections(a),f.setMap(d.get("map"))):f.setMap(null),c(a,b)})},displayStreetView:function(a,b){this.get("map").setStreetView(this.get("services > StreetViewPanorama",new google.maps.StreetViewPanorama(this._unwrap(a),b)))},search:function(a,b){this.get("services > Geocoder",new google.maps.Geocoder).geocode(a,b)}})})(jQuery);