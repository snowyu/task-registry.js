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

## Usage

```coffee
Task      = require 'task-registry'
register  = Task.register
aliases   = Task.aliases

class SimpleTask
  register SimpleTask # the registered name is 'Simple'(excludes 'Task')
  aliases SimpleTask, 'simple', 'single'
  constructor: -> return super

  # (optional) define attributes of this task
  Task.defineProperties SimpleTask,
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

//the class SimpleTask
function SimpleTask() {
  return SimpleTask.__super__.constructor.apply(this, arguments);
}

register(SimpleTask);
aliases(SimpleTask, 'simple', 'single');

Task.defineProperties(SimpleTask, {
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

class A2Task
  register A2Task, SimpleTask # register the A2Task to the SimpleTask

a1Task = SimpleTask 'a1'
assert.equal abcTask, Task '/simple/a1'
a2Task = SimpleTask 'a2'
assert.equal abcTask, Task '/simple/a2'
```

the following is javacript:

```js
function A1Task() {}
register(A1Task, SimpleTask);

function A2Task() {}
register(A2Task, SimpleTask);

var a1Task = SimpleTask('a1');
assert.equal(abcTask, Task('/simple/a1'));

var a2Task = SimpleTask('a2');
assert.equal(abcTask, Task('/simple/a2'));
```
## API

## TODO


## License

MIT
