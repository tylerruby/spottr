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
    # handler.addMarkers(#{raw @hash.to_json});
    handler.getMap().setZoom(12)
    bindEvents()

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
      fetchPlaces(params)

  ######################################
  # API CALLS
  ######################################

  # fetch the points from server
  PLACES_URL = '/api/places.json'
  fetchPlaces = (params) ->
    url = "#{PLACES_URL}?#{$.param(params)}"
    $.getJSON url, (data) =>
      updateMarkers(data.places)
      updateTableRows(data.places)


  ######################################
  # MARKERS LOGIC
  ######################################

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
      handler.removeMarker(marker)

    _.each markers, (val, key) ->
      delete markers[key] if _.contains(markersToRemove, key)

    # step two: add some markers to the map
    _.each places, (p) -> addMarker(p)

    console.log(markers)

  addMarker = (place) ->
    existingIds = _.keys markers
    unless _.contains(existingIds, place.id)
      data =
        lat: place.latitude,
        lng: place.longitude,
        infowindow: "<a href='/places/#{place.id}'>#{place.title}</a>"
      marker = handler.addMarker(data)
      markers[place.id] = marker

  ######################################
  # TABLE LOGIC
  ######################################

  updateTableRows = (places) ->
    $table = $('#places-table')

    placeIds = _.map places, (p) -> p.id

    # step one: remove invisible rows
    $table.find('tr').each ->
      unless _.include placeIds, +$(@).attr('data-id')
        $(@).remove()

    # step two add row
    _.each places, (p) -> addTableRow(p)

    # step three: fix numbers for table rows
    fixTableRowNumbers()

  rowTemplate = """
    <tr data-id="<%=id%>" id="place-<%=id%>">
      <td>
        <strong class="count" style="font-size:18px;">
        </strong>
      </td>
      <td>
        <span class="btn btn-sm btn-default glyphicon glyphicon-chevron-up">
          10
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
      <span class="btn btn-sm btn-default fa fa-car pull-right"></span>
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
