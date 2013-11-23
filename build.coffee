Components = require './source/components'
fs = require 'fs'

tagname = process.argv[2]

Components.register 'test', {
  components:
    Test: {type: 'test4'}
  properties:
    name: (value)-> @textContent = value
  events:
    ready: ->
      @name = 'as'
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
          Components.store.components = {#{components}}
          Components.create('#{tagname}',function(element){
            document.body.appendChild(element)
          })
          """

          fs.writeFileSync('./tmp.js', code, 'utf-8' )
