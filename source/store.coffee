class Store
  list   : -> console.warn Object.getPrototypeOf(@).constructor.name+'::list not implemented!'
  get    : -> console.warn Object.getPrototypeOf(@).constructor.name+'::get not implemented!'
  set    : -> console.warn Object.getPrototypeOf(@).constructor.name+'::set not implemented!'
  remove : -> console.warn Object.getPrototypeOf(@).constructor.name+'::remove not implemented!'

  # Serialize component
  deserialize: (component)->
    if component.ports
      for key,value of component.ports
        component.ports[key] = Function('value',value)
    if component.events
      for key,value of component.events
        component.events[key] = Function('e',value)
    component

  serialize: (component)->
    newComp = css: component.css

    # Copy components
    if component.components
      newComp.components = component.components

    # Serialize ports
    if component.ports
      newComp.ports = {}
      for key, value of component.ports
        code = value.toString()
        newComp.ports[key] = code.substring(code.indexOf("{")+1,code.lastIndexOf("}"))

    # Serialize Events
    if component.events
      newComp.events = {}
      for key, value of component.events
        code = value.toString()
        newComp.events[key] = code.substring(code.indexOf("{")+1,code.lastIndexOf("}"))

    newComp
