#= require ./remote_object_deleter

$ ->
  class Ingredient
    constructor: (element) ->
      @element = $(element)
      @deleteButton =
        new DeleteIngredientButton(this,
          @element.find('[data-delete="ingredient"]')
        )

    remove: ->
      @element.fadeOut('fast')

  class DeleteIngredientButton
    constructor: (@ingredient, element) ->
      @element = $(element)
      @deleter = @_buildDeleter()

    _buildDeleter: ->
      deleter = new RemoteObjectDeleter(@element)
      deleter.on 'success', => @ingredient.remove()
      deleter

  $('[data-item="ingredient"]').each ->
    new Ingredient(this)
