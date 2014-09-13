$ ->
  handler = Gmaps.build('Google')
  handler.buildMap {
    provider: {},
    internal: {id: 'map'}
  }, =>
    marker = handler.addMarker
      "lat":  window.latitude,
      "lng":  window.longitude,
      "infowindow": "Current Location"
    handler.map.centerOn(marker)
    handler.getMap().setZoom(12)
    bindEvents()

  # SOME CONFIG VARIABLES
  DEFAULT_PLACES_LIMIT = 20
  fetchPlacesLimit = DEFAULT_PLACES_LIMIT
  timeMode = "month"
  foodKindEnabled = true
  barKindEnabled = true
  clubKindEnabled = true

  ######################################
  # EVENTS HANDLING
  ######################################
  bindEvents = ->
    google.maps.event.addListener handler.getMap(),
      'bounds_changed', onBoundsChange

  boundsLock = false
  onBoundsChange = ->
    # preventing this func from being called to often
    unless boundsLock
      boundsLock = true
      setTimeout (->
        boundsLock = false), 100

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
      fetchPlaces(params)

  ######################################
  # API CALLS
  ######################################

  PLACES_URL = '/api/places.json'
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
      time_mode: timeMode,
      food: foodKindEnabled
      bar: barKindEnabled,
      club: clubKindEnabled,
    )

    url = "#{PLACES_URL}?#{$.param(params)}"
    $.getJSON url, (data) =>
      updateMarkers(data.places)
      updateTableRows(data.places, data.total)


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
  addMarker = (place) ->
    map = handler.getMap()
    existingIds = _.keys markers
    unless _.contains(existingIds, place.id)
      position = new google.maps.LatLng(place.latitude, place.longitude)
      infoWindow = new google.maps.InfoWindow
        content: "<a href='/places/#{place.id}'>#{place.title}</a>"
        disableAutoPan: true
      marker = new google.maps.Marker
        icon: mkMarkerIcon(0, "red")
        position: position
        map: map,
        placeId: place.id

      markers[place.id] = marker
      google.maps.event.addListener marker, 'click', ->
        activeInfoWindow.close() if activeInfoWindow
        console.log(marker)
        infoWindow.open(map,marker)
        activeInfoWindow = infoWindow

      google.maps.event.addListener marker, 'mouseover', ->
        marker.set("icon", mkMarkerIcon(marker.rank, "purple"))
        selector = "#place-#{place.id}"
        $(selector).addClass("highlight")
        $('#places-table').parent().scrollTo(selector)

      google.maps.event.addListener marker, 'mouseout', ->
        marker.set("icon", mkMarkerIcon(marker.rank, "red"))
        $("#place-#{place.id}").removeClass("highlight")

  ######################################
  # TABLE LOGIC
  ######################################

  updateTableRows = (places, total) ->
    $table = $('#places-table')

    # step one - clear table
    $table.html('')

    # step two add row
    _.each places, (p) -> addTableRow(p)

    # step three: fix numbers for table rows
    fixTableRowNumbers()

    # step four: fix spaces in js-upvotes
    fixUpvotesSpacing()

    # step five: show/hide show more button
    processShowMoreBtn(places.length, total)

  rowTemplate = """
    <tr data-id="<%=id%>" id="place-<%=id%>">
      <td>
        <strong class="count" style="font-size:18px;">
        </strong>
      </td>
      <td>
        <a class="js-upvote btn btn-sm btn-default glyphicon glyphicon-chevron-up" href="/api/places/<%=id%>/up_vote" style="font-size:14px;border:none;background:whitesmoke;">
          <%=votes_count%>
        </span>
      </td>
      <td>
        <span style="font-size:16px;margin-left:5px;margin-top:5px;">
          <a href="/places/<%=id%>" class="place">
            <%= title %>
          </a>
        </span>
      </td>
      <td>$4.50</td>
      <td>
        <a href="https://www.google.com/maps/place/<%=address%>" target="_blank" class="btn btn-sm btn-default btn-outline fa fa-car pull-right">
        </a>
      </td>
    </tr>
  """
  compiledRowTemplate = _.template(rowTemplate)

  addTableRow = (p) ->
    if $("#place-#{p.id}").length == 0
      $table = $('#places-table')
      rowTemplate = compiledRowTemplate(p)
      $(rowTemplate).appendTo($table)

  fixTableRowNumbers = ->
    $('#places-table tr').each (i) ->
      $(@).find('.count').text(i+1)

  fixUpvotesSpacing = ->
    $('#places-table .js-upvote').each ->
      ($ @).text(($ @).text().trim())

  processShowMoreBtn = (placesCount, total) ->
    if placesCount < total
      $('.js-more-places').removeClass('hidden')
    else
      $('.js-more-places').addClass('hidden')

  ######################################
  # TABLE BUTTONS EVENT HANDLING
  ######################################

  onUpvoteClick = ->
    $this = $(@)
    href = $this.attr('href')
    $.ajax
      url: href
      type: "POST"
      success: (data) ->
        $this.text(data.votes_count)
    false

  onRowMouseEnter = ->
    id = ($ @).attr('data-id')
    marker = markers[id]
    marker.set("icon", mkMarkerIcon(marker.rank, "purple"))
    $(@).addClass('highlight')

  onRowMouseLeave = ->
    id = ($ @).attr('data-id')
    marker = markers[id]
    marker.set("icon", mkMarkerIcon(marker.rank, "red"))
    $(@).removeClass('highlight')

  onLoadMoreClick = ->
    fetchPlacesLimit += DEFAULT_PLACES_LIMIT
    fetchPlaces()
    false

  $('#places-table').on('click', '.js-upvote', onUpvoteClick)
  $('#places-table').on('mouseenter', 'tr', onRowMouseEnter)
  $('#places-table').on('mouseleave', 'tr', onRowMouseLeave)
  $('.js-more-places').on('click', onLoadMoreClick)

  ######################################
  # TABLE TOP CONTROLS LOGIC
  ######################################
  $dateModeSelect = $('.date-mode-select')
  $dateModeSelect.find('.dropdown-menu a').on 'click', ->
    $this = $(@)
    timeMode = $(@).attr('data-mode')
    fetchPlaces()
    $dateModeSelect
      .find('.dropdown-toggle .text').text($this.text())
    $dateModeSelect.find('.dropdown-toggle').dropdown('toggle')
    false

  $('#kind-toggles .btn').on 'click', ->
    setTimeout setKindsAndFetch, 500

  setKindsAndFetch = ->
    foodKindEnabled = $('#food-toggle').hasClass('active')
    barKindEnabled = $('#bar-toggle').hasClass('active')
    clubKindEnabled = $('#club-toggle').hasClass('active')
    if !(foodKindEnabled || barKindEnabled || clubKindEnabled)
      foodKindEnabled = barKindEnabled = clubKindEnabled = true
    fetchPlaces()

    console.log(foodKindEnabled, barKindEnabled, clubKindEnabled)
