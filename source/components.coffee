MemoryStore = require './stores/memory.coffee'
Utils = require './utils.coffee'

# Core
# ----
# TODO: caching
Components =
  CREATE_REGEXP: /create\(["'](.*?)["']/
  store: new MemoryStore
  register: (type, component, callback)->
    Utils.validateTag(type)
    @store.set type, component, callback

  create: (type, callback)->
    Utils.validateTag(type)
    @store.get type, (base)=>
      # Create base element
      component = @document.createElement(type)

      # End here if there is no component
      # so element is created but not extended
      return callback component unless base

      # Add fireEvent / matchesSelector
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
        create = @create.bind @

        # Add properties
        Utils.each base.properties, (name, property)->
          Object.defineProperty component, name,
            set: (value)->
              @_data[name] = value
              property.call component, value, create
            get: -> @_data[name]
            enumerable: true

        # Add events
        Utils.each base.events, (type,code)->
          # Event delegation
          [event,selector] = type.split(":")
          unless selector
            component.addEventListener event, (e)->
              code.call(component,e,create)
          else
            component.addEventListener event, (e)->
              code.call(component,e,create) if e.target.matchesSelector(selector)
            , true

        # Ready event
        component.fireEvent 'ready'

        # End
        callback component

      # Start process
      Utils.series(series)

  geather: (type, callback)->
    Utils.validateTag type
    @store.get type, (base)=>
      return callback [] unless base

      components     = {}
      components[type] = base
      componentNames = []
      series         = []

      methods = (code for key, code of base.events).concat(code for key, code of base.properties)
      methods.forEach (code)=>
        if (m = code.toString().match(@CREATE_REGEXP))
          componentNames.push m[1] if componentNames.indexOf(m[1]) is -1

      for identifier, value of base.components
        componentNames.push value.type if componentNames.indexOf(value.type) is -1

      componentNames.forEach (comp)=>
        series.push (cb)=>
          @geather comp, (comps)->
            for key, value of comps
              continue if components[key]
              components[key] = value
            cb()

      series.push -> callback components

      Utils.series series

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
      methods = (code for key, code of base.events).concat(code for key, code of base.properties)
      methods.forEach (code)->
        if (m = code.toString().match(@CREATE_REGEXP))
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

  css: (type, callback)->
    @style type, (styles)->
      code = (for key, style of styles then style ).join("\n\n")
      callback code

module.exports = Components
