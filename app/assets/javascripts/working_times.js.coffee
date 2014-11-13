$ ->
  $workingTimesDiv = $('.js-working-times')
  return if $workingTimesDiv.length == 0

  $daysDiv = $workingTimesDiv.find('.days')

  # clean up empty things
  $daysDiv.children().each ->
    $fg = $(@)
    $id = $fg.find('.js-id')
    if $id.val().length == 0
      $id.remove()
      $fg.find('.js-_destroy').remove()

  $workingTimesDiv.on 'click', '.js-rm-btn', ->
    if $daysDiv.children(':visible').length > 1
      $fg = $(@).parent()
      if $fg.find('.js-id')
        $fg.find('.js-_destroy').val('1')
        $fg.hide()
      else
        $fg.remove()

  $workingTimesDiv.on 'change', '.js-start', ->
    val = +$(@).val()
    if val == 60
      $(@).val(59)
    else
      $end = $(@).parent().find('.js-end')
      endVal = +$end.val()
      if endVal <= val
        $end.val(val + 1)

  $workingTimesDiv.on 'change', '.js-end', ->
    val = +$(@).val()
    if val == 12
      $(@).val(13)
    else
      $start = $(@).parent().find('.js-start')
      startVal = +$start.val()
      if startVal > val
        $start.val(val - 1)

  $workingTimesDiv.find('.js-add-btn').click ->
    $fg = $('<div class="form-group"></div>')
    $fg.html($daysDiv.find('.form-group').last().html())

    index = +(new Date())
    $fg.find('select').each ->
      $sel = $(@)

      id = $sel.attr('id')
      $sel.attr 'id', id.replace(/\d+/, index)

      name = $sel.attr('name')
      $sel.attr 'name', name.replace(/\[\d+\]/, '['+index+']')

    $fg.find('.js-id').remove()
    $fg.find('.js-_destroy').remove()

    $wday = $fg.find('.js-wday')
    $wday.val((+$daysDiv.children().last().find('.js-wday').val() + 1) % 7)
    $fg.find('.js-start').val($daysDiv.children().last().find('.js-start').val())
    $fg.find('.js-end').val($daysDiv.children().last().find('.js-end').val())

    $fg.appendTo($daysDiv)
