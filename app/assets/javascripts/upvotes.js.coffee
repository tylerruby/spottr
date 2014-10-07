$ ->
  onUpvoteClick = ->
    unless window.user_logged_in
      $('#sign-in-alert').removeClass('hidden').slideDown()
      return false

    $this = $(@)
    unless $this.is('.upvoted')
      href = $this.attr('href') + "?time_mode=#{$('.date-mode-select').attr('data-mode')}"
      $.ajax
        url: href
        type: "POST"
        success: (data) ->
          $this.text(data.votes_count)
          $this.addClass('upvoted')
    false
  $('.js-dynamic-table').on('click', '.js-upvote', onUpvoteClick)
