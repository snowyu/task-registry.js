## task-registry [![npm](https://img.shields.io/npm/v/task-registry.svg)](https://npmjs.org/package/task-registry)

[![Build Status](https://img.shields.io/travis/snowyu/task-registry.js/master.svg)](http://travis-ci.org/snowyu/task-registry.js)
[![Code Climate](https://codeclimate.com/github/snowyu/task-registry.js/badges/gpa.svg)](https://codeclimate.com/github/snowyu/task-registry.js)
[![Test Coverage](https://codeclimate.com/github/snowyu/task-registry.js/badges/coverage.svg)](https://codeclimate.com/github/snowyu/task-registry.js/coverage)
[![downloads](https://img.shields.io/npm/dm/task-registry.svg)](https://npmjs.org/package/task-registry)
[![license](https://img.shields.io/npm/l/task-registry.svg)](https://npmjs.org/package/task-registry)

The task registry collects tasks to execute synchronously or asynchronously.

* It could register a task.
* It could define the attributes of the task.
* It chould set/change the attributes' default value of the task.
* It could get a task via name.

## Usage

```coffee
Task      = require 'task-registry'
register  = Task.register
aliases   = Task.aliases

class SimpleTask
  register SimpleTask
  aliases SimpleTask, 'simple', 'single'
  constructor: -> return super

  # (optional) define attributes of this task
  Task.defineProperties, SimpleTask,
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

result = simpleTask.executeSync(aOptions)
assert.equal result, 4
```

## API

## TODO


## License

MIT
