MemoryStore = require './stores/memory.coffee'
Utils = require './utils.coffee'

CREATE_REGEXP = /Components\.create\(["'](.*?)["']/

# Core
# ----
# TODO: rename ports to properties
# TODO: rename add to register
# TODO: caching
Components =
  store: new MemoryStore
  add: (type, component, callback)->
    Utils.validateTag(type)
    @store.set type, component, callback

  create: (type, callback, testMode = false)->
    Utils.validateTag(type)
    @store.get type, (base)=>
      # Create base element
      component = @document.createElement(type)
      # End here if there is no component
      # gracefull degradation...
      return callback component unless base

      Utils.extendElement component

      # Setup data store
      component._data = {}

      series = []

      # Create sub components...
      ( for identifier, value of base.components
        id: identifier
        type: value.type
        position: value.position or 0 ).sort((a,b)-> a.position - b.position).forEach (subComponent)=>
          series.push (cb)=>
            @create subComponent.type, (el)->
              component[subComponent.id] = el
              component.appendChild el
              cb()

      # Setup component
      series.push (cb)=>

        # Add properties
        Utils.each base.ports, (name,port)->
          Object.defineProperty component, name,
            set: (value)->
              @_data[name] = value
              port.call component, value
            get: -> @_data[name]

        # Add events
        Utils.each base.events, (type,code)->
          # Event delegation
          [event,selector] = type.split(":")
          return component.addEventListener(type, code) unless selector
          component.addEventListener event, (e)->
            code.call(component,e) if e.target.matchesSelector(selector)
          , true

        # Testmode event
        component.fireEvent 'test' if testMode

        # Ready event
        component.fireEvent 'ready'

        callback component

      # Start process
      Utils.series(series)

  style: (type, callback)->
    Utils.validateTag type
    @store.get type, (base)=>
      return callback {} unless base

      styles      = {}
      components  = []
      series      = []

      # Set self type
      styles[type] = base.css

      # Geather components from codes
      methods = (code for key, code of base.events).concat(code for key, code of base.ports)
      methods.forEach (code)->
        if (m = code.toString().match(CREATE_REGEXP))
          components.push m[1] if components.indexOf(m[1]) is -1

      # Add sub components
      for identifier, value of base.components
        components.push value.type if components.indexOf(value.type) is -1

      # Get styles
      components.forEach (comp)=>
        series.push (cb)=>
          @style comp, (s)->
            for key, style of s
              continue if styles[key]
              styles[key] = style
            cb()

      series.push -> callback styles

      # Start process
      Utils.series(series)

module.exports = Components
