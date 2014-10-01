# Mode select shit (aka dropdown)

$ ->
  $('.mode-select').each ->
    $modeSelect = $(@)
    $modeSelect.find('.dropdown-menu a').on 'click', ->
      $this = $(@)
      timeMode = $(@).attr('data-mode')
      $modeSelect.attr('data-mode', timeMode)
      $modeSelect
        .find('.dropdown-toggle .text').text($this.text())
      $modeSelect.find('.dropdown-toggle').dropdown('toggle')
      $modeSelect.trigger('change')
      false
