# Utility methods
#
# @mixin
Utils =
  # Regexp for validating the tagname
  # probably cheaper then try / catch - createElement
  TAGNAME_REGEXP: /^[a-zA-Z_:]([-a-zA-Z0-9_:.]+)?$/

  # Async series minimal implementation
  #
  # @param [Array] method The methods to run
  # @param [Function] callback The callback to run
  series: (methods, callback)->
    return callback(null) unless methods.length
    methods.shift() (error)->
      return callback(error) if error
      Utils.series methods, callback

  # Validates the given tag for html tag name
  #
  # @param [String] tag The tagname to validate
  validateTag: (tag)-> throw new Error "Invalid type '#{tag}'!" unless @TAGNAME_REGEXP.test tag

  # Validates a component
  # @param [Object] component The component to validate
  #
  # @return [Boolean] True if valid false if not
  validateComponent: (component)->
    return false if component.css isnt undefined and typeof component.css isnt 'string'

    return false if component.components is null or (component.components isnt undefined and typeof component.components isnt 'object')
    return false if component.events     is null or (component.events     isnt undefined and typeof component.events     isnt 'object')
    return false if component.properties is null or (component.properties isnt undefined and typeof component.properties isnt 'object')

    for id, comp of component.components
      return false unless /[A-za-z][A-za-z0-9]+/.test id
      return false unless comp.type
      return false if typeof comp.type isnt 'string'
      return false unless @TAGNAME_REGEXP.test comp.type
      return false if comp.position is null or (comp.position isnt undefined and typeof comp.position isnt 'number')

    for id, method of component.events
      return false unless method instanceof Function

    for id, method of component.properties
      return false unless /[A-za-z][A-za-z0-9]+/.test id
      return false unless method instanceof Function

    true

  # Runs method for every key / value
  #
  # @param [Object] object The object
  # @param [Function] method The method
  each: (object, method)-> method(key,value) for key, value of object

  # Gets the body of a function
  #
  # @param [Function] method - The function
  #
  # @return [String] The body of the function
  getBody: (method)->
    code = method.toString()
    code.substring(code.indexOf("{")+1,code.lastIndexOf("}")).trim()

  # Extends the given element with `fireEvent` and `matchesSelector`
  #
  # @param [Element] element The element to extend
  extendElement: (element)->
    element.fireEvent = @fireEvent.bind element
    element.matchesSelector ?= @matchesSelector.bind element

  # Fires a HTMLEvent with type and data (as properties of the event)
  #
  # @param [String] type The type of the event
  # @param [Object] data The extra data for the event
  #
  # @return [Event] The dispatched event
  fireEvent: (type, data) ->
    throw "No / Wrong type specified" if typeof type isnt "string"
    event = @ownerDocument.createEvent("HTMLEvents")
    event.initEvent type, true, true
    event[key] = data[key] for key of data
    @dispatchEvent event
    event

  # MatchesSelector Polyfill
  matchesSelector: ->
    @mozMatchesSelector or @msMatchesSelector or @oMatchesSelector or @webkitMatchesSelector or (selector) ->
      Array::slice.call((@parentNode or @ownerDocument).querySelectorAll(selector)).indexOf(@) isnt -1

module.exports = Utils
