$ ->
  mapZoom = 14
  mapMode = "places"
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

  navigator.geolocation.getCurrentPosition (position) ->
    window.latitude = position.coords.latitude
    window.longitude = position.coords.longitude

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
    handler.getMap().setZoom(14)

  # SOME CONFIG VARIABLES
  DEFAULT_PLACES_LIMIT = 15
  fetchPlacesLimit = DEFAULT_PLACES_LIMIT
  DEFAULT_DISHES_LIMIT = 15
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
      doFetch(params)

   onPlacesSearch = ->
     places = searchBox.getPlaces()
     return if places.length == 0
     place = places[0]
     if onMapPage
       handleFoundPlace(place)

   handleFoundPlace = (place) ->
      handler.getMap().setCenter(place.geometry.location)
      handler.getMap().setZoom(14)


  ######################################
  # API CALLS
  ######################################

  PLACES_URL = '/api/places.json'
  DISHES_URL = '/api/menu_items.json'
  cachedFetchParams = {}

  tableMode = "places"
  doFetch = (params) ->
    # cache params in order to be able
    # to call doFetch w/o arguments
    if params
      cachedFetchParams = params
    else
      params = cachedFetchParams

    params = _.extend(params,
      limit: fetchPlacesLimit,
      time_mode: $('.date-mode-select').attr('data-mode'),
      cuisine_type: $('.cuisine-select').attr('data-mode'),
      price_range: $('.price-range-select').attr('data-mode')
    )

    if tableMode == "places"
      url = "#{PLACES_URL}?#{$.param(params)}"
      $.getJSON url, (data) =>
        updateMarkers(data.places)
        window.updatePlaceTableRows(data.places, data.total)
    else if tableMode == "dishes"
      params = _.extend(params, limit: fetchDishesLimit)
      url = "#{DISHES_URL}?#{$.param(params)}"
      $.getJSON url, (data) =>
        updateMarkers(data.menu_items)
        window.updateDishTableRows(data.menu_items, data.total)

  ######################################
  # MARKERS LOGIC
  ######################################

  # create marker icon
  mkMarkerIcon = (number, color) ->
    "images/mapicons/#{color}/number_#{number}.png"

  # Some storage for drawing places algorithm
  markers = {} # place.id: marker format

  wipeMarkers = ->
    _.each markers, (marker) ->
      marker.setMap(null)
    markers = {}

  updateMarkers = (items) ->
    existingIds = _.keys markers
    itemIds = _.map items, (p) -> p.id

    # step one: remove invisible markers
    idsToRemove = _.filter existingIds, (id) ->
      !_.contains(itemIds, id)

    markersToRemove = _.pick markers, idsToRemove
    _.each markersToRemove, (marker) ->
      marker.setMap(null)

    _.each markers, (val, key) ->
      delete markers[key] if _.contains(markersToRemove, key)

    # step two: add some markers to the map
    _.each items, (p) -> addMarker(p)

    # step three: enumerate markers
    _.each items, (item, index) ->
      rank = index + 1
      markers[item.id].rank = rank
      markers[item.id].set "icon", mkMarkerIcon(rank, "red")

  DEFAULT_MARKER_COLOR = "ff0000"
  activeInfoWindow = null
  openInfoWindow = (marker) ->

  addMarker = (item) ->
    map = handler.getMap()
    existingIds = _.keys markers
    unless _.contains(existingIds, item.id)
      position = new google.maps.LatLng(item.latitude, item.longitude)
      infoWindow = new google.maps.InfoWindow
        content: """
          <h5>#{item.title}</h5>
          <span style="font-size:12px;">
            #{item.price}
          </span>
          <img src="#{item.image_url}">
        """
        disableAutoPan: true

      # hide [x] in infowindow
      google.maps.event.addListener infoWindow, 'domready', ->
        $(".gm-style-iw").next("div").hide()

      marker = new google.maps.Marker
        icon: mkMarkerIcon(0, "red")
        position: position
        map: map

      markers[item.id] = marker

      google.maps.event.addListener marker, 'click', ->
        if tableMode == "places"
          window.location.href = "/places/#{item.id}"
        else if tableMode == "dishes"
          window.location.href = "/places/#{item.place_id}"

      google.maps.event.addListener marker, 'mouseover', (e) ->
        activeInfoWindow.close() if activeInfoWindow
        infoWindow.open(map,marker)
        activeInfoWindow = infoWindow
        marker.set("icon", mkMarkerIcon(marker.rank, "purple"))

        if tableMode == "places"
          selector = "#place-#{item.id}"
        else if tableMode == "dishes"
          selector = "#dish-#{item.id}"

        unless e.noscroll
          $(selector).addClass("highlight")
          $("##{tableMode}-table").parent().parent().parent().scrollTo(selector)

      google.maps.event.addListener marker, 'mouseout', ->
        activeInfoWindow.close() if activeInfoWindow
        marker.set("icon", mkMarkerIcon(marker.rank, "red"))
        if tableMode == "places"
          $("#place-#{item.id}").removeClass("highlight")
        else if tableMode == "dishes"
          $("#dish-#{item.id}").removeClass("highlight")


  ######################################
  # TABLE BUTTONS EVENT HANDLING
  ######################################

  onPlacesRowMouseEnter = ->
    id = ($ @).attr('data-id')
    marker = markers[id]
    google.maps.event.trigger marker, 'mouseover', {noscroll: true}
    $(@).addClass('highlight')

  onPlacesRowMouseLeave = ->
    id = ($ @).attr('data-id')
    marker = markers[id]
    google.maps.event.trigger marker, 'mouseout'
    $(@).removeClass('highlight')

  onLoadMorePlacesClick = ->
    fetchPlacesLimit += DEFAULT_PLACES_LIMIT
    doFetch()
    false

  onDishesRowMouseEnter = ->
    id = ($ @).attr('data-id')
    marker = markers[id]
    google.maps.event.trigger marker, 'mouseover', {noscroll: true}
    $(@).addClass('highlight')

  onDishesRowMouseLeave = ->
    id = ($ @).attr('data-id')
    marker = markers[id]
    google.maps.event.trigger marker, 'mouseout'
    $(@).removeClass('highlight')

  onLoadMoreDishesClick = ->
    fetchDishesLimit += DEFAULT_DISHES_LIMIT
    doFetch()
    false

  onTabChange = (e) ->
    href = $(e.target).attr('href')
    if href == "#places-pane"
      wipeMarkers()
      tableMode = "places"
      doFetch()
    else if href == "#dishes-pane"
      wipeMarkers()
      tableMode = "dishes"
      doFetch()

  $('#places-table').on('mouseenter', 'tr', onPlacesRowMouseEnter)
  $('#places-table').on('mouseleave', 'tr', onPlacesRowMouseLeave)
  $('.js-more-places').on('click', onLoadMorePlacesClick)
  $('#dishes-table').on('mouseenter', 'tr', onDishesRowMouseEnter)
  $('#dishes-table').on('mouseleave', 'tr', onDishesRowMouseLeave)
  $('.js-more-dishes').on('click', onLoadMoreDishesClick)
  $('a[data-toggle="tab"]').on('shown.bs.tab', onTabChange)

  ######################################
  # TABLE TOP CONTROLS LOGIC
  ######################################
  $('.date-mode-select').on 'change', ->
    setTimeout doFetch, 50

  $('.cuisine-select').on 'change', ->
    setTimeout doFetch, 50

  $('.price-range-select').on 'change', ->
    setTimeout doFetch, 50
