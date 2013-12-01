Components = require './components'

module.exports.stores =
  redis: require './stores/redis'
  memory: require './stores/memory'
  firebase: require './stores/firebase'
  file: require './stores/file'

module.exports.registry = require './registry/registry'

module.exports.buildClient = (callback)->
  browserify   = require 'browserify'
  FS           = require 'fs'
  coffeeify    = require 'coffeeify'
  UglifyJS     = require 'uglify-js'

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

  FS.writeFileSync('./tmp.js', code, 'utf-8' )

  b = browserify()
  b.add('./tmp.js')
  b.transform coffeeify
  b.bundle {standalone: 'Components'}, (err,src)->
    result = UglifyJS.minify(src, {fromString: true})
    FS.unlink './tmp.js'
    callback result.code

# Builds a browser bundle
#
# @param [Store] store The store from which to build
# @param [String] tagname The name of the component to build
module.exports.build = (store,tagname,callback)->

  Components.store = store

  CleanCSS     = require 'clean-css'
  Autoprefixer = require 'autoprefixer'
  browserify   = require 'browserify'
  coffeeify    = require 'coffeeify'
  UglifyJS     = require 'uglify-js'
  FS           = require 'fs'

  console.log "Resoving component tree..."
  Components.geather tagname, (components)->

    ret = []
    console.log "Compiling components..."
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
    _components.create('#{tagname}',function(element){
      document.body.appendChild(element)
    })
    """

    FS.writeFileSync("#{__dirname}/tmp.js", code, 'utf-8' )

    console.log "Creating browser bundle..."
    b = browserify()
    b.add("#{__dirname}/tmp.js")
    b.transform coffeeify
    b.bundle {}, (err,src)->
      console.log "Compressing..."
      result = UglifyJS.minify(src, {fromString: true})
      FS.unlink "#{__dirname}/tmp.js"

      console.log "Creating css..."
      Components.css tagname, (code)->
        css = Autoprefixer.compile(code)
        css = new CleanCSS().minify(code)
        callback {js: result.code, css: css}
        console.log "Done!"
