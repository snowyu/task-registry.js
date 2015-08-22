factory         = require 'custom-factory'
propertyManager = require 'property-manager/ability'
isInheritedFrom = require 'inherits-ex/lib/isInheritedFrom'
setImmediate    = setImmediate || process.nextTick
isFunction      = (arg)->typeof arg == 'function'

module.exports  = class Task
  factory Task
  propertyManager Task, name:'advance', nonExported1stChar:'_'

  @ROOT_NAME: ''
  vGetNameFromClass = @getNameFromClass
  @getNameFromClass: (aClass, aParentClass, aBaseNameOnly)->
    # TODO: the baseNameOnly is failed for the registered name is always the path name.
    result = vGetNameFromClass(aClass, aParentClass, aBaseNameOnly)
    aParentClass = aParentClass || Task
    vRootPath = aParentClass::path()
    vRootPath += '/' if vRootPath[vRootPath.length-1] isnt '/'
    result = vRootPath+result
    result
  @getParentTaskClass: ->
    try vCaller = arguments.callee.caller.caller.caller
    if vCaller and isInheritedFrom vCaller, Task
      vLastCaller = vCaller
      vCaller = vCaller.caller
      #get farest hierarchical registered class
      while isInheritedFrom vCaller, vLastCaller
        vLastCaller = vCaller
        vCaller = vCaller.caller
    vLastCaller
  @get: (aName, aOptions)->
    result = Task._get(aName, aOptions)
    unless result or aName[0] is '/'
      vParent = Task.getParentTaskClass()
      if vParent
        s = vParent::path()
        s += '/' if s[s.length-1] isnt '/'
        result = Task._get(s+aName, aOptions)
    result

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

