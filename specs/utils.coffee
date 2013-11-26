Utils = require '../source/utils'

describe 'Utils', ->
  describe 'validateComponent', ->

    describe 'css', ->
      it 'should return false for wrong css', ->
        Utils.validateComponent({css: null}).should.be.false
        Utils.validateComponent({css: ->}).should.be.false
        Utils.validateComponent({css: 0}).should.be.false

      it 'should return true for good css', ->
        Utils.validateComponent({css: ''}).should.be.true

    describe 'components', ->
      it 'should return false for non object components', ->
        Utils.validateComponent({components: ""}).should.be.false
        Utils.validateComponent({components: null}).should.be.false
        Utils.validateComponent({components: ->}).should.be.false
        Utils.validateComponent({components: 0}).should.be.false

      it 'should return false for wrong id', ->
        Utils.validateComponent({components: {"$test": {}}}).should.be.false

      it 'should return false for missing type', ->
        Utils.validateComponent({components: {"test": {}}}).should.be.false
        Utils.validateComponent({components: {"test": {type: ""}}}).should.be.false
        Utils.validateComponent({components: {"test": {type: null}}}).should.be.false

      it 'should return false for wrong type', ->
        Utils.validateComponent({components: {"test": {type: "$ad"}}}).should.be.false
        Utils.validateComponent({components: {"test": {type: 0}}}).should.be.false
        Utils.validateComponent({components: {"test": {type: null}}}).should.be.false
        Utils.validateComponent({components: {"test": {type: ->}}}).should.be.false

      it 'should return false for wrong position', ->
        Utils.validateComponent({components: {"test": {type: "ad", position: ""}}}).should.be.false
        Utils.validateComponent({components: {"test": {type: "ad", position: ->}}}).should.be.false
        Utils.validateComponent({components: {"test": {type: "ad", position: null}}}).should.be.false

      it 'should return true for empty components', ->
        Utils.validateComponent({components: {}}).should.be.true

      it 'should return true for valid components', ->
        Utils.validateComponent({components: {"test": {type: "ad", position: 0}}}).should.be.true

    describe 'Events', ->
      it 'should return false for non object events', ->
        Utils.validateComponent({events: ""}).should.be.false
        Utils.validateComponent({events: null}).should.be.false
        Utils.validateComponent({events: ->}).should.be.false
        Utils.validateComponent({events: 0}).should.be.false

      it 'should return false for non function', ->
        Utils.validateComponent({events: {'test': undefined}}).should.be.false
        Utils.validateComponent({events: {'test': ""}}).should.be.false
        Utils.validateComponent({events: {'test': null}}).should.be.false
        Utils.validateComponent({events: {'test': 0}}).should.be.false

      it 'should return true for valid event', ->
        Utils.validateComponent({events: {'test': ->}}).should.be.true

    describe 'Properties', ->
      it 'should return false for non object properties', ->
        Utils.validateComponent({properties: ""}).should.be.false
        Utils.validateComponent({properties: null}).should.be.false
        Utils.validateComponent({properties: ->}).should.be.false
        Utils.validateComponent({properties: 0}).should.be.false

      it 'should return false for non wrong id', ->
        Utils.validateComponent({properties: {"$test": {}}}).should.be.false

      it 'should return false for non function', ->
        Utils.validateComponent({properties: {'test': undefined}}).should.be.false
        Utils.validateComponent({properties: {'test': ""}}).should.be.false
        Utils.validateComponent({properties: {'test': null}}).should.be.false
        Utils.validateComponent({properties: {'test': 0}}).should.be.false

       it 'should return true for valid property', ->
        Utils.validateComponent({properties: {'test': ->}}).should.be.true


