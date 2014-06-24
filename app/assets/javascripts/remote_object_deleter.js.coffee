class RemoteObjectDeleter
  constructor: (element) ->
    @element = $(element)
    @element.on 'click', @_handleClick

  _handleClick: (event) =>
    event.preventDefault()

    element = $(event.target)
    confirmationMessage = element.data('confirm')
    url = element.data('href')

    if !confirmationMessage? || window.confirm(confirmationMessage)
      xhr = $.ajax(method: 'delete', url: url)
      xhr.then => @trigger('success')

  $.extend(@prototype, Backbone.Events)

@RemoteObjectDeleter = RemoteObjectDeleter
