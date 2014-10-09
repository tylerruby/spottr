$ ->
  ######################################
  # PLACES TABLE LOGIC
  ######################################

  window.updatePlaceTableRows = (places, total) ->
    $table = $('#places-table')

    # step one - clear table
    $table.html('')

    # step two add row
    _.each places, (p) -> addTableRow(p)

    # step three: fix numbers for table rows
    fixTableRowNumbers()

    # step five: show/hide show more button
    processShowMoreBtn(places.length, total)

  # preparing row data
  prepareRowData = (p) ->
    # Computing the distance proterty
    currentLatLng = new google.maps.LatLng(window.latitude, window.longitude)
    placeLatLng = new google.maps.LatLng(p.latitude, p.longitude)
    distance = util.getDistance(currentLatLng, placeLatLng)
    distanceMiles = util.toMiles(distance / 1000)
    p.distance = "#{util.formatDec(distanceMiles)} miles"
    p.upvoted_class = if p.upvoted_by_user then "upvoted" else ""
    p.direction_link = "http://maps.google.com/?saddr=#{window.latitude},#{window.longitude}&daddr=#{p.latitude},#{p.longitude}"
    return p

  addTableRow = (p) ->
    if $("#place-#{p.id}").length == 0
      $table.dynamicTable(addRow: p)

  fixTableRowNumbers = ->
    $('#places-table tr').each (i) ->
      $(@).find('.count').text(i+1)


  processShowMoreBtn = (placesCount, total) ->
    if placesCount < total
      $('.js-more-places').removeClass('hidden')
    else
      $('.js-more-places').addClass('hidden')

  # table initialization
  $table = $('#places-table')
  $table.dynamicTable(rowTemplate: "#place-row-template", prepareRow: prepareRowData)
