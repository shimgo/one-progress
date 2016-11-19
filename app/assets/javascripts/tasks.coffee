# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'ajax:success', '.updateTask', (xhr, data, status) ->
  location.reload()

$(document).on 'ajax:error', '.updateTask', (xhr, data, status) ->
  id = data.responseJSON.id
  form = $("#updateTask_#{id} .modal-body")
  div = $('<div id="updateTaskErrors" class="alert alert-danger"></div>')
  ul = $('<ul></ul>')
  data.responseJSON.messages.forEach (message, i) ->
    li = $('<li></li>').text(message)
    ul.append(li)

  if $('#updateTaskErrors')[0]
    $('#updateTaskErrors').html(ul)
  else
    div.append(ul)
    form.prepend(div)

$ ->
  $container = $('#masonry')
  $container.imagesLoaded(
    ->
      $container.masonry({
        itemSelector: '.task',
        isFitWidth: true,
        isAnimated: true,
        isResizable: true
      })
  )

  $container.infinitescroll(
    {
      navSelector: "#page-bottom",
      nextSelector: ".pagination a[rel=next]",
      itemSelector : '#all-tasks .task',
      loading: {
        img: "/assets/loading.gif",
        msgText: "",
        finishedMsg: "",
        speed: 0,
        selector: "#loading"
      }
    },
    (newElements) -> 
      $newElems = $(newElements)
      $newElems.imagesLoaded(
        -> 
          $container.masonry( 'appended', $newElems, true )
      )
  )
