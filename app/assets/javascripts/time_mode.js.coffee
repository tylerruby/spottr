# Time mode select shit

$ ->
  $dateModeSelect = $('.date-mode-select')
  $dateModeSelect.find('.dropdown-menu a').on 'click', ->
    $this = $(@)
    timeMode = $(@).attr('data-mode')
    $dateModeSelect.attr('data-mode', timeMode)
    $dateModeSelect
      .find('.dropdown-toggle .text').text($this.text())
    $dateModeSelect.find('.dropdown-toggle').dropdown('toggle')
    $dateModeSelect.trigger('change')
    false
