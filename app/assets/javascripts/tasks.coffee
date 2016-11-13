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
  $("#all-tasks .page").infinitescroll
    loading: {
      img:     "http://www.mytreedb.com/uploads/mytreedb/loader/ajax_loader_blue_48.gif"
      msgText: "ロード中..."
    }
    navSelector: "nav.pagination" # selector for the paged navigation (it will be hidden)
    nextSelector: "nav.pagination a[rel=next]" # selector for the NEXT link (to page 2)
    itemSelector: "#all-tasks div.task" # selector for all items you'll retrieve

$ ->
  $('#content').masonry({
    itemSelector: '.task'
  })
