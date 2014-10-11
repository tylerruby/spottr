$ ->
  $table = $('#menu-items-table')
  if $table.length != 0
    BASE_URL = "/api/places/#{window.place_id}/menu_items.json"
    timeMode = "month"

    $('#new-menu-item').click ->
      if $('.menu-items-form').is(':visible')
        $('.menu-items-form').slideUp()
      else
        $('.menu-items-form').slideDown ->
          $('#menu_item_name').focus()

    # prepare row for comments table
    prepareRow = (p) ->
      p.upvoted_class = if p.upvoted_by_user then "upvoted" else ""
      return p

    $table.dynamicTable
      rowTemplate: "#menu-item-row-template"
      prepareRow: prepareRow

    refreshMenuItems = ->
      $.getJSON "#{BASE_URL}?time_mode=#{timeMode}", (data) ->
        $table.dynamicTable setData: data["menu_items"]
    refreshMenuItems()

    $('#menu-items-panel .date-mode-select').on 'change', ->
      console.log "test"
      timeMode = $(@).attr('data-mode')
      refreshMenuItems()
