Components = require './components'

module.exports.stores =
  redis: require './stores/redis'
  memory: require './stores/memory'
  firebase: require './stores/firebase'

module.exports.registry = require './registry/registry'

# Builds a browser bundle
#
# @param [Store] store The store from which to build
# @param [String] tagname The name of the component to build
module.exports.build = (store,tagname)->

  Components.store = store

  FS           = require 'fs'
  CleanCSS     = require 'clean-css'
  Autoprefixer = require 'autoprefixer'
  browserify   = require 'browserify'
  coffeeify    = require 'coffeeify'
  UglifyJS     = require 'uglify-js'

  console.log "Resoving component tree..."
  Components.geather tagname, (components)->

    ret = []
    console.log "Compiling components..."
    for type, comp of components
      cret = ["components: #{JSON.stringify(comp.components) or '{}'}"]
      cret.push "events: {"+(for key, method of comp.events
        "#{key}: #{method.toString()}").join(",")+"}"
      cret.push "properties: {"+(for key, method of comp.properties
        "#{key}: #{method.toString()}").join(",")+"}"
      ret.push "#{type}: {#{cret.join(",")}}"

    code = """
    window.Components = require('./source/components.coffee')
    Components.document = document
    Components.store.db = {#{ret.join(",\n")}}
    Components.create('#{tagname}',function(element){
      document.body.appendChild(element)
    })
    """

    FS.writeFileSync('./tmp.js', code, 'utf-8' )

    console.log "Creating browser bundle..."
    b = browserify()
    b.add('./tmp.js')
    b.transform coffeeify
    b.bundle {}, (err,src)->
      console.log "Compressing..."
      result = UglifyJS.minify(src, {fromString: true})
      FS.unlink './tmp.js'

      console.log "Creating css..."
      Components.css tagname, (code)->
        css = Autoprefixer.compile(code)
        css = new CleanCSS().minify(code)
        console.log "Done!"
        store.close()
