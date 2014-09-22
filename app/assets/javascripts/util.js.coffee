window.util ||= {}
window.util.toRadians = toRadians = (x) -> x * Math.PI / 180

window.util.getDistance = getDistance = (latLng1, latLng2) ->
  google.maps.geometry.spherical.computeDistanceBetween(latLng1, latLng2)

window.util.toMiles = (km) -> km * 0.621371192237334
window.util.formatDec = (dec) -> ((dec * 10)|0) / 10
