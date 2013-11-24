# Utility methods
#
# @mixin
Utils =
  # Regexp for validating the tagname
  # probably cheaper then try / catch - createElement
  TAGNAME_REGEXP: /^[a-zA-Z_:][-a-zA-Z0-9_:.]+$/

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
  validateTag: (tag)-> throw "Invalid type '#{tag}'!" unless @TAGNAME_REGEXP.test tag

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
      Array::slice.call(@parentNode or @ownerDocument).querySelectorAll(selector).indexOf(@) isnt -1

module.exports = Utils
