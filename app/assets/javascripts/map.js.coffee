$ ->
  mapZoom = 12
  mapLatitude = window.latitude
  mapLongitude = window.longitude
  currentMarker = null

  onMapPage = $('#map').length > 0
  return unless onMapPage

  # localstorage thing
  checkLocalStorage = ->
    try
      window['localStorage'] != null
    catch e
      return false
  localStorageSupported = checkLocalStorage()

  if localStorageSupported
    mapLatitude = +localStorage.getItem('latitude') || mapLatitude
    mapLongitude = +localStorage.getItem('longitude') || mapLongitude
    mapZoom = +localStorage.getItem('zoom') || mapZoom

  # map initialization
  handler = Gmaps.build('Google')
  handler.buildMap {
    provider: {},
    internal: {id: 'map'}
  }, =>
    marker = handler.addMarker
      "lat":  window.latitude,
      "lng":  window.longitude,
      "infowindow": "Current Location"

    currentMarker = marker.getServiceObject()

    latLng = new google.maps.LatLng(mapLatitude, mapLongitude)
    handler.map.centerOn(latLng)
    handler.getMap().setZoom(mapZoom)
    bindEvents()

  # search input
  searchInput = document.getElementById('place-search')
  searchBox = new google.maps.places.SearchBox(searchInput)

  # go home button
  $('#current-location').click ->
    if window.navigator.geolocation
      navigator.geolocation.getCurrentPosition (position) ->
        moveToLocation(position.coords.latitude, position.coords.longitude)
    else
      moveToLocation(window.latitude, window.longitude)

  moveToLocation = (lat, lng) ->
    latLng = new google.maps.LatLng(lat, lng)
    currentMarker.setPosition(latLng)
    handler.map.centerOn(latLng)
    handler.getMap().setZoom(12)

  # SOME CONFIG VARIABLES
  DEFAULT_PLACES_LIMIT = 20
  fetchPlacesLimit = DEFAULT_PLACES_LIMIT
  DEFAULT_DISHES_LIMIT = 20
  fetchDishesLimit = DEFAULT_DISHES_LIMIT

  ######################################
  # EVENTS HANDLING
  ######################################
  bindEvents = ->
    google.maps.event.addListener handler.getMap(),
      'bounds_changed', onBoundsChange
    google.maps.event.addListener searchBox,
      'places_changed', onPlacesSearch

  boundsLock = false
  onBoundsChange = ->
    # preventing this func from being called to often
    unless boundsLock
      boundsLock = true
      setTimeout (->
        boundsLock = false), 100

      # saving variables in localStorage
      if localStorageSupported
        latLng = handler.getMap().getCenter()
        latitude = latLng.lat()
        longitude = latLng.lng()
        zoom = handler.getMap().getZoom()

        localStorage.setItem('latitude', latitude)
        localStorage.setItem('longitude', longitude)
        localStorage.setItem('zoom', zoom)

      # getting bounds and changing places
      newBounds = handler.getMap().getBounds()
      southWest = newBounds.getSouthWest()
      northEast = newBounds.getNorthEast()
      params =
        swlat: southWest.lat(),
        swlng: southWest.lng(),
        nelat: northEast.lat(),
        nelng: northEast.lng()
      fetchPlacesLimit = DEFAULT_PLACES_LIMIT
      fetchDishesLimit = DEFAULT_DISHES_LIMIT
      fetchPlaces(params)

   onPlacesSearch = ->
     places = searchBox.getPlaces()
     return if places.length == 0
     place = places[0]
     if onMapPage
       handleFoundPlace(place)

   handleFoundPlace = (place) ->
      handler.getMap().setCenter(place.geometry.location)
      handler.getMap().setZoom(12)


  ######################################
  # API CALLS
  ######################################

  PLACES_URL = '/api/places.json'
  DISHES_URL = '/api/menu_items.json'
  cachedFetchParams = {}

  fetchPlaces = (params) ->
    # cache params in order to be able
    # to call fetchPlaces w/o arguments
    if params
      cachedFetchParams = params
    else
      params = cachedFetchParams

    params = _.extend(params,
      limit: fetchPlacesLimit,
      time_mode: $('.date-mode-select').attr('data-mode'),
      cuisine_type: $('.cuisine-select').attr('data-mode'),
    )

    url = "#{PLACES_URL}?#{$.param(params)}"
    $.getJSON url, (data) =>
      updateMarkers(data.places)
      window.updatePlaceTableRows(data.places, data.total)

    params = _.extend(params, limit: fetchDishesLimit)
    url = "#{DISHES_URL}?#{$.param(params)}"
    $.getJSON url, (data) =>
      window.updateDishTableRows(data.menu_items, data.total)

  ######################################
  # MARKERS LOGIC
  ######################################

  # create marker icon
  mkMarkerIcon = (number, color) ->
    "images/mapicons/#{color}/number_#{number}.png"

  # Some storage for drawing places algorithm
  markers = {} # place.id: marker format

  updateMarkers = (places) ->
    existingIds = _.keys markers
    placeIds = _.map places, (p) -> p.id

    # step one: remove invisible markers
    idsToRemove = _.filter existingIds, (id) ->
      !_.contains(placeIds, id)

    markersToRemove = _.pick markers, idsToRemove
    _.each markersToRemove, (marker) ->
      marker.setMap(null)

    _.each markers, (val, key) ->
      delete markers[key] if _.contains(markersToRemove, key)

    # step two: add some markers to the map
    _.each places, (p) -> addMarker(p)

    # step three: enumerate markers
    _.each places, (place, index) ->
      rank = index + 1
      markers[place.id].rank = rank
      markers[place.id].set "icon", mkMarkerIcon(rank, "red")

  DEFAULT_MARKER_COLOR = "ff0000"
  activeInfoWindow = null
  openInfoWindow = (marker) ->
  addMarker = (place) ->
    map = handler.getMap()
    existingIds = _.keys markers
    unless _.contains(existingIds, place.id)
      position = new google.maps.LatLng(place.latitude, place.longitude)
      infoWindow = new google.maps.InfoWindow
        content: """
          <h5>#{place.title}</h5>
          <img src="#{place.image_url}">
        """
        disableAutoPan: true
      marker = new google.maps.Marker
        icon: mkMarkerIcon(0, "red")
        position: position
        map: map,
        placeId: place.id
        infoWindow: infoWindow

      markers[place.id] = marker
      google.maps.event.addListener marker, 'click', ->
        window.location.href = "/places/#{place.id}"

      google.maps.event.addListener marker, 'mouseover', ->
        activeInfoWindow.close() if activeInfoWindow
        infoWindow.open(map,marker)
        activeInfoWindow = infoWindow
        marker.set("icon", mkMarkerIcon(marker.rank, "purple"))
        selector = "#place-#{place.id}"
        $(selector).addClass("highlight")
        $('#places-table').parent().scrollTo(selector)

      google.maps.event.addListener marker, 'mouseout', ->
        activeInfoWindow.close() if activeInfoWindow
        marker.set("icon", mkMarkerIcon(marker.rank, "red"))
        $("#place-#{place.id}").removeClass("highlight")


  ######################################
  # TABLE BUTTONS EVENT HANDLING
  ######################################

  onPlacesRowMouseEnter = ->
    id = ($ @).attr('data-id')
    marker = markers[id]
    google.maps.event.trigger marker, 'mouseover'
    $(@).addClass('highlight')

  onPlacesRowMouseLeave = ->
    id = ($ @).attr('data-id')
    marker = markers[id]
    google.maps.event.trigger marker, 'mouseout'
    $(@).removeClass('highlight')

  onLoadMorePlacesClick = ->
    fetchPlacesLimit += DEFAULT_PLACES_LIMIT
    fetchPlaces()
    false

  onDishesRowMouseEnter = ->
    id = ($ @).attr('data-place-id')
    marker = markers[id]
    google.maps.event.trigger marker, 'mouseover'
    $(@).addClass('highlight')

  onDishesRowMouseLeave = ->
    id = ($ @).attr('data-place-id')
    marker = markers[id]
    google.maps.event.trigger marker, 'mouseout'
    $(@).removeClass('highlight')

  onLoadMoreDishesClick = ->
    fetchDishesLimit += DEFAULT_DISHES_LIMIT
    fetchPlaces()
    false

  $('#places-table').on('mouseenter', 'tr', onPlacesRowMouseEnter)
  $('#places-table').on('mouseleave', 'tr', onPlacesRowMouseLeave)
  $('.js-more-places').on('click', onLoadMorePlacesClick)
  $('#dishes-table').on('mouseenter', 'tr', onDishesRowMouseEnter)
  $('#dishes-table').on('mouseleave', 'tr', onDishesRowMouseLeave)
  $('.js-more-dishes').on('click', onLoadMoreDishesClick)

  ######################################
  # TABLE TOP CONTROLS LOGIC
  ######################################
  $('.date-mode-select').on 'change', ->
    setTimeout fetchPlaces, 50

  $('.cuisine-select').on 'change', ->
    setTimeout fetchPlaces, 50
