$(document).on 'click', '#help-link, #close-help', ->
  if $('#help').is(':hidden')
    $('#help').slideDown('normal')
  else
    $('#help').slideUp('normal')
