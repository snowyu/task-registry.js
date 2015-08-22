factory         = require 'custom-factory'
propertyManager = require 'property-manager/ability'
isInheritedFrom = require 'inherits-ex/lib/isInheritedFrom'
setImmediate    = setImmediate || process.nextTick
isFunction      = (arg)->typeof arg == 'function'
isString        = (arg)->typeof arg == 'string'

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
      if @ instanceof Task
        s = @path()
      else
        vParent = Task.getParentTaskClass()
        if vParent
          s = vParent::path()
      if s
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
  executeSync: (aOptions, aName)->
    if arguments.length is 1 and isString aOptions
      aName = aOptions
      aOptions = null
    vTask = if aName then @get(aName) else @
    aOptions = vTask.mergeTo(aOptions)
    vTask._executeSync(aOptions)
  execute: (aOptions, aName, done)->
    if arguments.length is 1
      done = aOptions
      aOptions = null
    else if arguments.length is 2
      done = aName
      if isString aOptions
        aName = aOptions
        aOptions = null
      else
        aName = null

    vTask = if aName then @get(aName) else @
    aOptions = vTask.mergeTo(aOptions)
    vTask._execute(aOptions, done)

