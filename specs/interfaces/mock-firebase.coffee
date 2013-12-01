class Firebase
  constructor: (path)->
    @db = {}
  child: (child)->
    switch child
      when "component_names"
        {
          once: (type,callback)=>
            keys = {}
            for key, value of @db when key.match 'component_names/'
              keys[key.split("/")[1]] = true
            callback {val: -> keys }
        }
      else
        {
          set: (value,callback)=>
            if value isnt null
              @db[child] = value
            else
              delete @db[child]
            callback()
          once: (type, callback)=> callback {val: => @db[child]}
        }
  off: ->
  on: (event, callback)->
    setTimeout ->
      callback {val: -> true}

module.exports = Firebase
