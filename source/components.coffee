MemoryStore = require './stores/memory.coffee'
Utils = require './utils.coffee'

# Core
# ----
# TODO: caching
Components =
  CREATE_REGEXP: /create\(["'](.*?)["']/g
  store: new MemoryStore
  register: (type, component, callback)->
    Utils.validateTag(type)
    @store.set type, component, callback

  # Creates a components
  create: (type, callback)->
    Utils.validateTag(type)
    @store.get type, (base)=>
      # Create base element
      component = @document.createElement(type)

      # End here if there is no component
      # so element is created but not extended
      return callback? component unless base

      # Add fireEvent / matchesSelector
      Utils.extendElement component

      # Setup data store
      series          = []
      component._data = {}

      # Create sub components...
      ( for identifier, value of base.components
        id: identifier
        type: value.type
        position: value.position or 0
      ).sort((a,b)->
        a.position - b.position
      ).forEach (subComponent)=>
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
            enumerable: true
            get: -> @_data[name]
            set: (value)->
              @_data[name] = value
              property.call component, value, create

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
        callback? component

      # Start process
      Utils.series(series)

  # Resolve dependencies into one object
  geather: (type, callback)->
    Utils.validateTag type
    @store.get type, (base)=>
      return callback? {} unless base

      series           = []
      components       = {}
      componentNames   = []
      components[type] = base

      # Geather all methods into one array
      methods = (code for key, code of base.events).concat(code for key, code of base.properties)
      methods.forEach (code)=>
        # Search for the create() method
        # TODO: Probably would be better with ECMAScript parsing
        code.toString().replace @CREATE_REGEXP, (a,m)->
          componentNames.push m if componentNames.indexOf(m) is -1

      # Add components
      for identifier, value of base.components
        componentNames.push value.type if componentNames.indexOf(value.type) is -1

      # Geather sub components and merge
      componentNames.forEach (comp)=>
        series.push (cb)=>
          @geather comp, (comps)->
            for key, value of comps
              continue if components[key]
              components[key] = value
            cb()

      # End process
      series.push -> callback? components

      # Start process
      Utils.series series

  style: (type, callback)->
    @geather type, (components)->
      styles = {}

      Utils.each components, (type,component)=>
        return if styles[type]
        styles[type] = component.css

      callback? styles

  css: (type, callback)->
    @style type, (styles)->
      code = (for key, style of styles then style ).join("\n\n")
      callback? code

module.exports = Components
