## task-registry [![npm](https://img.shields.io/npm/v/task-registry.svg)](https://npmjs.org/package/task-registry)

[![Build Status](https://img.shields.io/travis/snowyu/task-registry.js/master.svg)](http://travis-ci.org/snowyu/task-registry.js)
[![Code Climate](https://codeclimate.com/github/snowyu/task-registry.js/badges/gpa.svg)](https://codeclimate.com/github/snowyu/task-registry.js)
[![Test Coverage](https://codeclimate.com/github/snowyu/task-registry.js/badges/coverage.svg)](https://codeclimate.com/github/snowyu/task-registry.js/coverage)
[![downloads](https://img.shields.io/npm/dm/task-registry.svg)](https://npmjs.org/package/task-registry)
[![license](https://img.shields.io/npm/l/task-registry.svg)](https://npmjs.org/package/task-registry)

The hierarchical task registry collects tasks to execute synchronously or asynchronously.

* It could register a task.
* It could define the attributes of the task.
* It chould set/change the attributes' default value of the task.
* It could get a task via name.
* It could execute a task synchronously or asynchronously.
* It could be hierarchical tasks.
* It could iterate all tasks via forEach.

## Usage

```coffee
Task      = require 'task-registry'
register  = Task.register
aliases   = Task.aliases
defineProperties = Task.defineProperties

class SimpleTask
  register SimpleTask # the registered name is 'Simple'(excludes 'Task')
  aliases SimpleTask, 'simple', 'single'
  constructor: -> return super

  # (optional) define attributes of this task
  defineProperties SimpleTask,
    one:
      type: 'Number'
      value: 1 # the default value of the attribute.

  # (required)the task execution synchronously.
  # the aOptions argument is optional.
  _executeSync: (aOptions)->aOptions.one+1

  # (optional)the task execution asynchronously.
  # the default is used `executeSync` to execute asynchronously.
  #_execute: (aOptions, done)->

simpleTask = Task('Simple', one:3) #change the default value of the attr to 3.
sTask = Task('Simple')
assert.strictEqual sTask, simpleTask
assert.strictEqual simpleTask.one, 3

result = simpleTask.executeSync()
assert.equal result, 4

result = simpleTask.executeSync(one: 5) # override the default value.
assert.equal result, 6
```

the following is javascript:

```js
var Task = require('task-registry');
var register = Task.register;
var aliases = Task.aliases;
var defineProperties = Task.defineProperties

//the class SimpleTask
function SimpleTask() {
  return SimpleTask.__super__.constructor.apply(this, arguments);
}

register(SimpleTask);
aliases(SimpleTask, 'simple', 'single');

defineProperties(SimpleTask, {
  one: {
    type: 'Number',
    value: 1
  }
});

SimpleTask.prototype._executeSync = function(aOptions) {
  return aOptions.one + 1;
};


var simpleTask = Task('Simple', {
  one: 3
});

var sTask = Task('Simple');

assert.strictEqual(sTask, simpleTask);

assert.strictEqual(simpleTask.one, 3);

var result = simpleTask.executeSync();
assert.equal(result, 4);

result = simpleTask.executeSync({
  one: 5
});
assert.equal(result, 6);
```

the hierarchical task:

```coffee
class A1Task
  register A1Task, SimpleTask # register the A1Task to the SimpleTask
  #or SimpleTask.register A1Task

class A2Task
  register A2Task, SimpleTask # register the A2Task to the SimpleTask
  #or SimpleTask.register A2Task

a1Task = SimpleTask 'A1' # or simpleTask.get('A1')
assert.equal abcTask, Task '/Simple/A1'
a2Task = SimpleTask 'A2'
assert.equal abcTask, Task '/Simple/A2'
```

the following is javacript:

```js
function A1Task() {}
register(A1Task, SimpleTask);

function A2Task() {}
register(A2Task, SimpleTask);

var a1Task = SimpleTask('A1');
assert.equal(abcTask, Task('/Simple/A1'));

var a2Task = SimpleTask('A2');
assert.equal(abcTask, Task('/Simple/A2'));
```
## API

the derived task should overwrite these methods to execute a task:

* `_executeSync(aOptions)`: execute synchronously.
* `_execute(aOptions, callback)`: execute asynchronously (optional).
  * It will call `_executeSync` to execute asynchronously if not exists.

* class/static methods
  * `register(aTaskClass[[, aParentClass=Task], aOptions])`: register the `aTaskClass` to the Task registry.
    * `aOptions` *(object|string)*: It will use the aOptions as default options to create instance.
      * it is the customized registered name if aOptions is string.
      * `name`: use the name instead of the class name to register if any.
        or it will use the class name(remove the last factory name if exists) to register.
      * `createOnDemand` *(boolean)*: create the task item instance on demand
        or create it immediately. defaults to true.
  * `unregister(aName|aClass)`: unregister the class or name from the Task registry.
  * `alias/aliases(aClass, aliases...)`: create aliases to the `aClass`.
  * `constructor(aName, aOptions)`: get a singleton task instance.
  * `constructor(aOptions)`: get a singleton task instance.
    * aOptions: *(object)*
      * name: the task item name. defaults to the constructor's name
  * `constructor(aInstance, aOptions)`: apply(re-initialize) the aOptions to the task `aInstance`.
  * `create(aName, aOptions)`: create a new task instance always.
  * `get(aName, aOptions)`: get the singleton task instance via `aName` and apply(re-initialize) the aOptions to the task.
  * `forEach(callback)`: iterate all the singleton task instances to callback.
    * `callback` *function(instance, name)*
* instance methods
  * `get(aName, aOptions)`: get the singleton task instance via `aName` and apply(re-initialize) the aOptions to the task.
  * `register(aClass[, aOptions])`: register a class to itself.
  * `unregister(aName|aClass)`: same as the unregister class/static method.
  * `execute([aOptions][, aName=this.name], callback)`: execute the task asynchronously.
    * `aOptions` *(object)*:
      1. apply the default value of the task to the `aOptions`
      2. pass the aOptions object argument to the `_execute` method
    * `aName` *(string)*: execute the specified task if any, defaults to itself.
    * `callback` *function(error, result)*
  * `executeSync([aOptions][, aName=this.name])`: execute the task synchronously and return the result.
    * `aOptions` *(object)*:
      1. apply the default value of the task to the `aOptions`
      2. pass the `aOptions` object argument to the `_executeSync` method
    * `aName` *(string)*: execute the specified task if any, defaults to itself.


Note:

* The 'root' task will holds all the registered tasks.
* The 'non-root' task will holds the tasks which registered to it.

## TODO


## License

MIT
