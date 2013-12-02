FileStore = require '../../source/stores/file'
iStore    = require '../interfaces/store'
Fs        = require 'fs'

describe 'FileStore', ->
  before (done)->
    Fs.mkdir './tmp', =>
      @store = new FileStore {base: './tmp'}, done

  iStore.call @

  it 'should read coffee files and eval them to get the component', (done)=>
    code = """
      css: "ui-icon { font-family: FontAwesome }"
      properties:
        icon: (value)->
          @textContent = switch value
            when "chevron-up" then '\uF077'
            when "chevron-down"
              '\uF078'
            when "pencil"
              '\uF040'
            when "remove"
              '\uF00D'
            when "plus"
              '\uf067'
    """
    Fs.writeFile './tmp/coffee-test.coffee', code, ->
      store = new FileStore {base: './tmp', extension: 'coffee'}, ->
        store.get 'coffee-test', (component)->
          component.should.have.property 'css'
          component.css.should.be.exactly 'ui-icon { font-family: FontAwesome }'
          component.should.have.property 'properties'
          component.properties.should.have.property 'icon'
          component.properties.icon.should.be.instanceof Function
          store.remove 'coffee-test', ->
            done()

  it 'should read js files and eval them to get the component', (done)=>
    code = """
      ({
        css: "ui-icon { font-family: FontAwesome }",
        properties: {
          icon: function(value) {
            return this.textContent = (function() {
              switch (value) {
                case "chevron-up":
                  return '\uF077';
                case "chevron-down":
                  return '\uF078';
                case "pencil":
                  return '\uF040';
                case "remove":
                  return '\uF00D';
                case "plus":
                  return '\uf067';
              }
            })();
          }
        }
      });
    """
    Fs.writeFile './tmp/coffee-test.js', code, ->
      store = new FileStore {base: './tmp'}, ->
        store.get 'coffee-test', (component)->
          component.should.have.property 'css'
          component.css.should.be.exactly 'ui-icon { font-family: FontAwesome }'
          component.should.have.property 'properties'
          component.properties.should.have.property 'icon'
          component.properties.icon.should.be.instanceof Function
          store.remove 'coffee-test', ->
            done()

  after (done)->
    Fs.rmdir './tmp', ->
      done()
