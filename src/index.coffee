factory         = require 'custom-factory'
propertyManager = require 'property-manager/ability'
setImmediate    = setImmediate || process.nextTick
isFunction      = (arg)->typeof arg == 'function'

module.exports  = class Task
  factory Task
  propertyManager Task, name:'advance', nonExported1stChar:'_'

  constructor: (aName, aOptions)->return super
  ### !pragma coverage-skip-next ###
  _executeSync: (aOptions)->throw new Error('not implement executeSync')
  _execute: (aOptions, done)->
    setImmediate =>
      try
        result = @executeSync aOptions
      catch err
      done err, result
  executeSync: (aOptions)->
    aOptions = @mergeTo(aOptions)
    @_executeSync(aOptions)
  execute: (aOptions, done)->
    if isFunction aOptions
      done = aOptions
      aOptions = null
    aOptions = @mergeTo(aOptions)
    @_execute(aOptions, done)

