Utils = require '../source/utils'

describe 'Utils', ->
  describe 'validateComponent', ->

    it 'should return false for wrong css', ->
      Utils.validateComponent({css: null}).should.be.false
      Utils.validateComponent({css: ->}).should.be.false
      Utils.validateComponent({css: undefined}).should.be.false
      Utils.validateComponent({css: 0}).should.be.false

    it 'should return true for good css', ->
      Utils.validateComponent({css: ''}).should.be.true
