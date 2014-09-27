(($) ->
  fixUpvotesSpacing = ->
    $('.js-upvote').each ->
      ($ @).text(($ @).text().trim())

  # rowTemplate: template used for rows
  $.fn.dynamicTable = (options)->
    @$el = $(@)
    if @$el.data('dtable')
      opts = @$el.data('dtable')
      rowTemplate = $(opts.rowTemplate).html()
      @$el.data('compiledRowTemplate', _.template(rowTemplate))

      if options.addRow
        html = @$el.data('compiledRowTemplate')(opts.prepareRow(options.addRow))
        $(html).appendTo(@$el)
        fixUpvotesSpacing()

      if options.setData
        @$el.html('')
        _.each options.setData, (p) =>
          html = @$el.data('compiledRowTemplate')(opts.prepareRow(p))
          $(html).appendTo(@$el)
          fixUpvotesSpacing()
    else
      options.prepareRow ||= (e) -> e
      @$el.data('dtable', options)
)(jQuery)
