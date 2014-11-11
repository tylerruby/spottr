$ ->
  $workingTimesDiv = $('.js-working-times')
  return if $workingTimesDiv.length == 0

  index = 1
  $daysDiv = $workingTimesDiv.find('.days')

  $workingTimesDiv.on 'click', '.js-rm-btn', ->
    if $daysDiv.children().length > 1
      $(@).parent().remove()

  $workingTimesDiv.find('.js-add-btn').click ->
    $fg = $('<div class="form-group"></div>')
    $fg.html($daysDiv.find('.form-group').last().html())

    $fg.find('select').each ->
      $sel = $(@)

      id = $sel.attr('id')
      $sel.attr 'id', id.replace(/\d+/, index)

      name = $sel.attr('name')
      $sel.attr 'name', name.replace(/\[\d+\]/, '['+index+']')
    index++

    $wday = $fg.find('.js-wday')
    $wday.val((+$daysDiv.children().last().find('.js-wday').val() + 1) % 7)

    $fg.find('.js-start').val(18)
    $fg.find('.js-end').val(34)

    $fg.appendTo($daysDiv)
