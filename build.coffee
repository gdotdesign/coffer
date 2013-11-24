Components = require './source/components'
fs = require 'fs'
Autoprefixer = require 'autoprefixer'
CleanCSS = require('clean-css')

tagname = process.argv[2]

Components.register 'test', {
  css: """

  @keyframes load {
    from {
      opacity: 0;
      background: #fff;
    }
    to {
      opacity: 1;
      background: #ccc;
    }
  }

  body {
    animation: load 2s;
    background: #ccc;
  }

  test {
    display: block;
    border: 1px solid #aaa;
    background: linear-gradient(#fff,#eee);
    padding: 20px;
    font-family: Ubuntu;
    font-weight: bold;
    font-size: 22px
  }
  """
  components:
    Test: {type: 'test4'}
  properties:
    name: (value)-> @textContent = value
  events:
    ready: ->
      @name = 'Hello Word'
    click: (e,create)->
      create 'test3', (el)=> @appendChild el

  }, ->
    Components.register 'test4', {}, ->
        Components.geather tagname, (components)->
          ret = []
          for type, comp of components
            cret = ["components: #{JSON.stringify(comp.components) or '{}'}"]
            cret.push "events: {"+(for key, method of comp.events
              "#{key}: #{method.toString().replace(/\n/g,'')}").join(",")+"}"
            cret.push "properties: {"+(for key, method of comp.properties
              "#{key}: #{method.toString().replace(/\n/g,'')}").join(",")+"}"
            ret.push "#{type}: {#{cret.join(",")}}"
          components = ret.join(",\n")

          code = """
          window.Components = require('./source/components.coffee')
          Components.document = document
          Components.store.db = {#{components}}
          Components.create('#{tagname}',function(element){
            document.body.appendChild(element)
          })
          """

          fs.writeFileSync('./tmp.js', code, 'utf-8' )

          Components.css tagname, (code)->
            code = Autoprefixer.compile(code)
            code = new CleanCSS().minify(code)
            fs.writeFileSync('./bundle.css',code, 'utf-8')
