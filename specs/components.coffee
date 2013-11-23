Components = require '../source/components'

if process
  jsdom = require 'jsdom'
  Components.document = new (jsdom.level(1, "core").Document)()
  Element = jsdom.level(1, "core").Element
else
  Components.document = document

describe 'Components', ->
  it 'should create component', (done)->
    Components.create 'test', (component)->
      component.should.be.instanceOf Element
      done()
