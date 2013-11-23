# Utility methods
# ---------------
Utils =
  # Regexp for validating the tagname
  # probably cheaper then try / catch - createElement
  TAGNAME_REGEXP: /^[a-zA-Z_:][-a-zA-Z0-9_:.]+$/

  # Async series minimal implementation
  # because that's all we need right?
  series: (methods, callback)->
    return callback(null) unless methods.length
    methods.shift() (error)->
      return callback(error) if error
      Utils.series methods, callback

  validateTag: (tag)-> throw "Invalid type '#{tag}'!" unless @TAGNAME_REGEXP.test tag

  each: (object, method)-> method(key,value) for key, value of object

  getBody: (method)->
    code = method.toString()
    code.substring(code.indexOf("{")+1,code.lastIndexOf("}")).trim()

  extendElement: (element, args...)->
    element.fireEvent = @fireEvent.bind element
    element.matchesSelector = @matchesSelector.bind element

  fireEvent: (type, data) ->
    throw "No / Wrong type specified"  if typeof type isnt "string"
    event = @ownerDocument.createEvent("HTMLEvents")
    event.initEvent type, true, true
    event[key] = data[key] for key of data
    @dispatchEvent event
    event

  matchesSelector: ->
    @matchesSelector or @mozMatchesSelector or @msMatchesSelector or @oMatchesSelector or @webkitMatchesSelector or (selector) ->
      Array::slice.call(@parentNode or @document).querySelectorAll(selector).indexOf(@) isnt -1

module.exports = Utils
