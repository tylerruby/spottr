$ ->
  ######################################
  # DISHES TABLE LOGIC
  ######################################

  window.updateDishTableRows = (places, total) ->
    $table = $('#dishes-table')

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
    p.upvoted_class = if p.upvoted_by_user then "upvoted" else ""
    p.direction_link = "http://maps.google.com/?saddr=#{window.latitude},#{window.longitude}&daddr=#{p.latitude},#{p.longitude}"
    return p

  addTableRow = (p) ->
    if $("#dish-#{p.id}").length == 0
      $table.dynamicTable(addRow: p)

  fixTableRowNumbers = ->
    $('#dishes-table tr').each (i) ->
      $(@).find('.count').text(i+1)

  processShowMoreBtn = (placesCount, total) ->
    if placesCount < total
      $('.js-more-dishes').removeClass('hidden')
    else
      $('.js-more-dishes').addClass('hidden')

  # table initialization
  $table = $('#dishes-table')
  $table.dynamicTable(rowTemplate: "#menu-item-row-template-map", prepareRow: prepareRowData)
