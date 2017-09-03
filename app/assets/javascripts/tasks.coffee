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

$(document).on 'turbolinks:load', ->
  $container = $('#masonry')
  $container.imagesLoaded(
    ->
      $container.masonry({
        itemSelector: '.task',
        columnWidth: '.task',
        isAnimated: true
      })
  )

  $container.infinitescroll(
    {
      navSelector: '#page-bottom',
      nextSelector: '#infinite-scroll-pagination .pagination a[rel=next]',
      itemSelector : '#all-tasks .task',
      loading: {
        img: image_path('/assets/loading.gif')
        msgText: '',
        finishedMsg: '',
        speed: 0,
        selector: '#loading'
      },
    },
    (newElements) -> 
      $newElems = $(newElements)
      $newElems.imagesLoaded(
        -> 
          $container.masonry( 'appended', $newElems, true )
      )
  )

$(document).on 'turbolinks:load', ->
  if Cookies.get("openTag")
    $('a[data-toggle="tab"]').parent().removeClass('active')
    $("a[href='##{Cookies.get('openTag')}']").click()
  $('a[data-toggle="tab"]').on('shown.bs.tab',
    (e) ->
      tabName = e.target.href
      items = tabName.split("#")
      Cookies.set("openTag",items[1], { expires: 365 * 20 })
  )

$(document).on 'turbolinks:load', ->
  $(".pagination").on 'ajax:send', (xhr) ->
    $('#container').infinitescroll('update', {currPage: 1})
    location.href = xhr.target.href
