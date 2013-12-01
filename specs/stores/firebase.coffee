FirebaseStore = require '../../source/stores/firebase'
Firebase      = require '../interfaces/mock-firebase'
iStore        = require '../interfaces/store'

describe 'FirebaseStore', ->
  before (done)->
    @store = new FirebaseStore Firebase, {root: 'graphite', node: 'test' }, done

  iStore.call @
