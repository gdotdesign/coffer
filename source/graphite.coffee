module.exports.Stores =
  Redis: require './stores/redis'
  Memory: require './stores/memory'
  Firebase: require './stores/firebase'
  File: require './stores/file'
  WebSocket: require './stores/websocket'

module.exports.registry = require './registry/registry'

# Builds browser client
#
# @param [Function] callback The callback to call when finished
# @return [String] The minified compiled code
module.exports.buildClient = (callback)->
  browserify   = require 'browserify'
  coffeeify    = require 'coffeeify'
  UglifyJS     = require 'uglify-js'
  Fs           = require 'fs'

  code = """
    WebSocketStore = require('#{__dirname}/stores/websocket.coffee')
    Components = require('#{__dirname}/components.coffee')
    Components.document = document
    Components.store = new WebSocketStore(WebSocket, 'ws://graphite-registry.herokuapp.com/',function(){
      event = document.createEvent("HTMLEvents")
      event.initEvent('components-ready', true, true)
      window.dispatchEvent(event)
    })
    module.exports = Components
  """

  Fs.writeFileSync('./tmp.js', code, 'utf-8' )

  b = browserify()
  b.add('./tmp.js')
  b.transform coffeeify
  b.bundle {standalone: 'Components'}, (err,src)->
    result = UglifyJS.minify(src, {fromString: true})
    Fs.unlink './tmp.js'
    callback result.code

# Build CSS for a given component
#
# @param [Store] store The store that contains the component
# @param [String] name The name of the component
# @param [Function] callback The callback to call when finished
#
# @return [String] The generated CSS
module.exports.buildCSS = (store,name,callback)->

  Autoprefixer = require 'autoprefixer'
  CleanCSS     = require 'clean-css'
  Components   = require './components'

  Components.store = store

  Components.css name, (code)->
    callback new CleanCSS().minify(Autoprefixer.compile(code))

# Build JavaScript for a given component
#
# @param [Store] store The store that contains the component
# @param [String] name The name of the component
# @param [Function] callback The callback to call when finished
#
# @return [String] The generated JavaScript
module.exports.buildJS = (store,name,callback)->

  Components = require './components'
  browserify = require 'browserify'
  coffeeify  = require 'coffeeify'
  UglifyJS   = require 'uglify-js'
  FS         = require 'fs'

  Components.store = store

  Components.geather name, (components)->

    ret = []
    for type, comp of components
      cret = ["components: #{JSON.stringify(comp.components) or '{}'}"]
      cret.push "events: {"+(for key, method of comp.events
        "'#{key}': #{method.toString()}").join(",")+"}"
      cret.push "properties: {"+(for key, method of comp.properties
        "'#{key}': #{method.toString()}").join(",")+"}"
      ret.push "'#{type}': {#{cret.join(",")}}"

    code = """
    var _components = require('#{__dirname}/components.coffee')
    _components.document = document
    _components.store.db = {#{ret.join(",\n")}}
    _components.create('#{name}',function(element){
      document.body.appendChild(element)
    })
    """
    FS.writeFileSync("#{__dirname}/tmp.js", code, 'utf-8' )

    b = browserify()
    b.add("#{__dirname}/tmp.js")
    b.transform coffeeify
    b.bundle {}, (err,src)->
      result = UglifyJS.minify(src, {fromString: true})
      FS.unlinkSync "#{__dirname}/tmp.js"

      callback result.code
