factory         = require 'custom-factory'
propertyManager = require 'property-manager/ability'
isInheritedFrom = require 'inherits-ex/lib/isInheritedFrom'
createCtor      = require 'inherits-ex/lib/createCtor'
setImmediate    = setImmediate || process.nextTick
isFunction      = (arg)->typeof arg == 'function'
isString        = (arg)->typeof arg == 'string'
isArray         = Array.isArray
isObject        = (arg)->
  result = !isArray arg
  if result
    result = typeof arg == 'object'
  result
getObjectKeys   = Object.keys

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

  ###
  # define a new task through out a function.
  # aName: the task name
  # aOptions: Object
  #   * fnSync(params...): the sync function
  #   * fn(params..., done): the async function
  #   * params Array: the parameters of this function
  #     * [{name:'', type:'', value:''},{}]
  #     * ['theParamName',...]
  #     * Note: the name first char should not be '_'
  #   * self: (optional) the self object to call the function
  #   * alias: ....
  # aParentTask: (optional) register to the class, defaults to the Task class.
  # return the defined task class if successful.
  ###
  @defineFunction: (aName, aOptions, aParentTask = Task)->
    if aName and aOptions
      aOptions = fnSync: aOptions if isFunction aOptions

      throw new TypeError 'missing function arguments' unless aOptions.fn or aOptions.fnSync

      result = createCtor aName # create a new class dynamically.
      aParentTask.register result
      vAliases = aOptions.aliases or aOptions.alias
      aParentTask.aliases vAliases if vAliases
      if isArray aOptions.params
        vAttrs = {}
        vParams = []
        for p in aOptions.params
          if isString p
            vName = p
            p = {}
          else if isObject p
            vName = p.name
          if isString(vName) and vName.length and vName[0] isnt Task::nonExported1stChar
            vAttrs[vName] = p
            vParams.push vName
          else
            throw new TypeError 'Illegal parameter name:' + vName
        if vParams.length
          #vAttrs['_params'] = type: 'Array', value: vParams
          result::_params = vParams
          aParentTask.defineProperties result, vAttrs
      result::_self = aOptions.self if aOptions.self

      vFn = aOptions.fnSync
      if isFunction vFn
        result::_fnSync = vFn
        result::_executeSync = (aOptions)->
          vArgs = []
          if isArray @_params
            for vName in @_params
              vArgs.push aOptions[vName]
          @_fnSync.apply (@_self || @), vArgs
      # result::_executeSync = ((aFn)->
      #   (aOptions)->
      #     vArgs = []
      #     if isArray @_params
      #       for vName in @_params
      #         vArgs.push aOptions[vName]
      #     aFn.apply (@_self || @), vArgs
      # )(vFn) if vFn

      vFn = aOptions.fn
      if isFunction vFn
        result::_fn = vFn
        result::_execute = (aOptions, done)->
          vArgs = []
          if isArray @_params
            for vName in @_params
              vArgs.push aOptions[vName]
          vArgs.push done
          @_fn.apply (@_self || @), vArgs
      # result::_execute = ((aFn)->
      #   (aOptions, done)->
      #     vArgs = []
      #     if isArray @_params
      #       for vName in @_params
      #         vArgs.push aOptions[vName]
      #     vArgs.push done
      #     aFn.apply (@_self || @), vArgs
      # )(vFn) if vFn
    else
      throw new TypeError 'missing arguments'
    result

  constructor: (aName, aOptions)->
    result = super
    return result
  ### !pragma coverage-skip-next ###
  _executeSync: (aOptions)->throw new Error('not implement executeSync')
  _execute: (aOptions, done)->
    setImmediate =>
      try
        result = @_executeSync aOptions
      catch err
      done err, result
  executeSync: (aOptions, aName)->
    if arguments.length is 1 and isString aOptions
      vTask = @getFactoryItem aOptions
      if vTask
        aName = aOptions
        aOptions = null
    unless vTask
      vTask = if aName then @getFactoryItem(aName) else @
    aOptions = vTask.mergeTo(aOptions) if !aOptions? or typeof aOptions == 'object'
    vTask._executeSync(aOptions)
  execute: (aOptions, aName, done)->
    if arguments.length is 1
      done = aOptions
      aOptions = null
    else if arguments.length is 2
      done = aName
      if isString aOptions
        vTask = @getFactoryItem aOptions
        if vTask
          aName = aOptions
          aOptions = null
      else
        aName = null

    unless vTask
      vTask = if aName then @getFactoryItem(aName) else @
    aOptions = vTask.mergeTo(aOptions) if !aOptions? or typeof aOptions == 'object'
    vTask._execute(aOptions, done)
  _inspect: (debug, aOptions)->
    result = @displayName()
    result = '"' + result + '"'
    if debug
      if aOptions?
        if isObject aOptions
          v = {}
          for key in getObjectKeys @getProperties()
            v[key] = aOptions[key] if aOptions[key]?
          aOptions = v
      else
        aOptions = @
      vAttrs = JSON.stringify(aOptions).slice(1,-1)
      result += ': ' + vAttrs if vAttrs
    result
  inspect: (debug, aOptions)->
    debug ?= @debug
    name  = @_inspect(debug, aOptions)
    name = ' ' + name if name
    '<Task'+ name + '>'

