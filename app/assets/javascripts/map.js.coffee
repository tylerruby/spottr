$ ->
  handler = Gmaps.build('Google')
  handler.buildMap {
    provider: {},
    internal: {id: 'map'}
  }, ->
    marker = handler.addMarker
      "lat":  window.latitude,
      "lng":  window.longitude,
      "infowindow": "Current Location"
    handler.map.centerOn(marker)
    # handler.addMarkers(#{raw @hash.to_json});
    handler.getMap().setZoom(14)
