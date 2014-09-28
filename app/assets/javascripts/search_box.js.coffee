$ ->
  onMapPage = $('#map').length > 0

  return if onMapPage

  searchInput = document.getElementById('place-search')
  searchBox = new google.maps.places.SearchBox(searchInput)
  google.maps.event.addListener searchBox, 'places_changed', ->
    places = searchBox.getPlaces()
    return if places.length == 0
    place = places[0]
    console.log(place)
    if localStorage
      localStorage.
        setItem('latitude', place.geometry.location.lat())
      localStorage.
        setItem('longitude', place.geometry.location.lng())
      localStorage.
        setItem('zoom', 10)
      window.location.pathname = "/"

