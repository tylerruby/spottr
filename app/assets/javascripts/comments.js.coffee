$ ->
  $table = $('#comments-table')
  if $table.size != 0
    BASE_URL = "/api/places/#{window.place_id}/comments.json"
    timeMode = "month"

    # prepare row for comments table
    prepareRow = (p) ->
      p.upvoted_class = if p.upvoted_by_user then "upvoted" else ""
      return p

    $table.dynamicTable
      rowTemplate: "#comment-row-template"
      prepareRow: prepareRow

    refreshComments = ->
      $.getJSON "#{BASE_URL}?time_mode=#{timeMode}", (data) ->
        $table.dynamicTable setData: data["comments"]
    refreshComments()

    $('#comments-panel .date-mode-select').on 'change', ->
      timeMode = $(@).attr('data-mode')
      refreshComments()

