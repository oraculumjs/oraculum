define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
  'oraculum/models/mixins/disposable'
  'oraculum/models/mixins/dispose-removed'
  'oraculum/models/mixins/sort-by-attribute-direction'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  # Define the collection we want to use to store our sort specification state
  stateModelName = '_SortByMultiAttributeDirectionInterfaceState.Collection'
  Oraculum.extend 'Collection', stateModelName, {
    model: '_SortByAttributeDirectionInterfaceState.Model'
    mixinOptions: disposable: disposeModels: true
  }, mixins: [
    'Disposable.CollectionMixin'
    'DisposeRemoved.CollectionMixin'
  ]

  Oraculum.defineMixin 'SortByMultiAttributeDirectionInterface.CollectionMixin', {

    mixinOptions:
      sortByMultiAttributeDirection:
        defaults: []

    mixconfig: ({sortByMultiAttributeDirection:conf}, m, {sortDefaults} = {}) ->
      conf.defaults = Oraculum.composeConfig conf.defaults, sortDefaults

    mixinitialize: ->
      defaults = @mixinOptions.sortByMultiAttributeDirection.defaults
      defaults = defaults.call this if _.isFunction defaults
      @sortState = @__factory().get stateModelName, defaults
      @on 'dispose', (target) =>
        return unless target is this
        @sortState.dispose()
        delete @sortState

    addAttributeDirection: (attribute, direction) ->
      return @removeAttributeDirection attribute unless direction
      @sortState.add {attribute, direction}, merge: true

    getAttributeDirection: (attribute) ->
      return 0 unless model = @sortState.get attribute
      return model.get 'direction'

    removeAttributeDirection: (attribute) ->
      return unless @getAttributeDirection attribute
      model = @sortState.get attribute
      @sortState.remove model

    unsort: ->
      @sortState.reset() unless @sortState.isEmpty()

  }, mixins: ['Evented.Mixin']
