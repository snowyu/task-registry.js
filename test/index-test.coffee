chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

setImmediate    = setImmediate || process.nextTick

Task            = require '../src'
register        = Task.register
aliases         = Task.aliases

class RootTask
  register RootTask
  aliases RootTask, 'Root', 'root'

  constructor: -> return super

class EchoTask
  register EchoTask

  constructor: -> return super
  _executeSync: sinon.spy (aOptions)->aOptions

class SimpleTask
  register SimpleTask, RootTask
  aliases SimpleTask, 'Simple', 'single'

  constructor: -> return super

  Task.defineProperties SimpleTask,
    one:
      type: 'Number'
      value: 1 # the default value of the property.

  # (required)the task execution synchronously.
  # the argument aOptions object is optional.
  _executeSync: sinon.spy (aOptions)->aOptions.one+1
  # (optional)the task execution asynchronously.
  # the default is used `executeSync` to execute asynchronously.
  #execute: (aOptions, done)->

class AbcTask
  register AbcTask, SimpleTask

class A2Task
  SimpleTask.register A2Task
  _executeSync: (aOptions)-> 'a2:' + super aOptions

describe 'Task', ->
  beforeEach ->
    SimpleTask::_executeSync.reset()
    EchoTask::_executeSync.reset()

  describe 'path', ->
    it 'should get path() correctly', ->
      expect(RootTask::path()).be.equal '/Root'
      expect(SimpleTask::path()).be.equal '/Root/Simple'
    it 'should get registerd name correctly', ->
      expect(RootTask::name).be.equal '/Root'
      expect(SimpleTask::name).be.equal '/Root/Simple'

  describe 'getTask', ->
    it 'should get task correctly', ->
      result = SimpleTask 'Abc'
      r2 = RootTask 'Simple/Abc'
      r3 = Task 'Root/Simple/Abc'
      assert.equal result, r2
      assert.equal result, r3
      expect(result).be.instanceOf AbcTask
      result = SimpleTask 'A2'
      r2 = RootTask 'Simple/A2'
      assert.equal result, r2
      expect(result).be.instanceOf A2Task
    it 'should get task via instance', ->
      root = Task 'Root'
      simple = root.get 'Simple'
      expect(simple).be.instanceOf SimpleTask
      result = root.get 'Simple/Abc'
      expect(result).be.instanceOf AbcTask
      result = simple.get 'Abc'
      expect(result).be.instanceOf AbcTask

  describe 'executeSync', ->
    it 'should run the simple task via default', ->
      task = Task 'Simple'
      expect(task).be.instanceOf SimpleTask
      expect(task).have.ownProperty 'one'
      expect(task).have.property 'one',1
      result = task.executeSync()
      expect(SimpleTask::_executeSync).be.calledOnce
      expect(SimpleTask::_executeSync).be.calledWith one:1
      expect(result).be.equal 2
    it 'should run the simple task and change the default one option value', ->
      task = Task 'Simple', one:2
      expect(task).be.instanceOf SimpleTask
      expect(task).have.ownProperty 'one'
      expect(task).have.property 'one',2
      result = task.executeSync()
      expect(SimpleTask::_executeSync).be.calledOnce
      expect(SimpleTask::_executeSync).be.calledWith one:2
      expect(result).be.equal 3
      task.one = 1 #restore the old init value
    it 'should run the simple task and pass the options', ->
      task = Task 'Simple'
      expect(task).be.instanceOf SimpleTask
      result = task.executeSync(two:2)
      expect(SimpleTask::_executeSync).be.calledOnce
      expect(SimpleTask::_executeSync).be.calledWith one:1, two:2
      expect(result).be.equal 2
    it 'should run a specified task', ->
      task = Task 'Simple'
      expect(task).be.instanceOf SimpleTask
      result = task.executeSync('A2')
      expect(SimpleTask::_executeSync).be.calledOnce
      expect(SimpleTask::_executeSync).be.calledWith one:1
      expect(result).be.equal 'a2:2'
    it 'should run a specified task with options', ->
      task = Task 'Simple'
      expect(task).be.instanceOf SimpleTask
      result = task.executeSync(two:2, 'A2')
      expect(SimpleTask::_executeSync).be.calledOnce
      expect(SimpleTask::_executeSync).be.calledWith one:1, two:2
      expect(result).be.equal 'a2:2'

    it 'should pass a single argument(non-object&string) directly', ->
      task = Task 'Echo'
      expect(task).be.instanceOf EchoTask
      result = task.executeSync 123
      expect(EchoTask::_executeSync).be.calledOnce
      expect(EchoTask::_executeSync).be.calledWith 123
      expect(result).be.equal 123

    it 'should pass a single string argument directly', ->
      task = Task 'Echo'
      expect(task).be.instanceOf EchoTask
      # MUST PASS an EMPTY name to avoid confuse the first argument is a name or argument.
      result = task.executeSync 'hi load', ''
      expect(EchoTask::_executeSync).be.calledOnce
      expect(EchoTask::_executeSync).be.calledWith 'hi load'
      expect(result).be.equal 'hi load'

  describe 'execute', ->
    it 'should run the simple task via default', (done)->
      task = Task 'Simple'
      expect(task).be.instanceOf SimpleTask
      expect(task).have.ownProperty 'one'
      expect(task).have.property 'one',1
      task.execute (err, result)->
        unless err
          expect(SimpleTask::_executeSync).be.calledOnce
          expect(SimpleTask::_executeSync).be.calledWith one:1
          expect(result).be.equal 2
        done(err)
    it 'should run the simple task and change the default one option value', (done)->
      task = Task 'Simple', one:2
      expect(task).be.instanceOf SimpleTask
      expect(task).have.ownProperty 'one'
      expect(task).have.property 'one',2
      task.execute (err, result)->
        unless err
          expect(SimpleTask::_executeSync).be.calledOnce
          expect(SimpleTask::_executeSync).be.calledWith one:2
          expect(result).be.equal 3
        task.one = 1 #restore the old init value
        done(err)
    it 'should run the simple task and pass the options', (done)->
      task = Task 'Simple'
      expect(task).be.instanceOf SimpleTask
      task.execute two:2, (err, result)->
        unless err
          expect(SimpleTask::_executeSync).be.calledOnce
          expect(SimpleTask::_executeSync).be.calledWith one:1, two:2
          expect(result).be.equal 2
        done(err)
    it 'should run a specified task', (done)->
      task = Task 'Simple'
      expect(task).be.instanceOf SimpleTask
      task.execute 'A2', (err, result)->
        unless err
          expect(SimpleTask::_executeSync).be.calledOnce
          expect(SimpleTask::_executeSync).be.calledWith one:1
          expect(result).be.equal 'a2:2'
        done(err)
    it 'should run a specified task with options', (done)->
      task = Task 'Simple'
      expect(task).be.instanceOf SimpleTask
      task.execute two:2, 'A2', (err, result)->
        unless err
          expect(SimpleTask::_executeSync).be.calledOnce
          expect(SimpleTask::_executeSync).be.calledWith one:1, two:2
          expect(result).be.equal 'a2:2'
        done(err)

    it 'should pass a single argument(non-object&string) directly', (done)->
      task = Task 'Echo'
      expect(task).be.instanceOf EchoTask
      task.execute 123, (err, result)->
        unless err
          expect(EchoTask::_executeSync).be.calledOnce
          expect(EchoTask::_executeSync).be.calledWith 123
          expect(result).be.equal 123
        done(err)

    it 'should pass a single string argument directly', (done)->
      task = Task 'Echo'
      expect(task).be.instanceOf EchoTask
      # MUST PASS an EMPTY name to avoid confuse the first argument is a name or argument.
      task.execute 'hi load', '', (err, result)->
        unless err
          expect(EchoTask::_executeSync).be.calledOnce
          expect(EchoTask::_executeSync).be.calledWith 'hi load'
          expect(result).be.equal 'hi load'
        done(err)

  describe 'inspect', ->
    it 'should inspect via default', ->
      task = Task 'Simple'
      result = task.inspect()
      expect(result).to.be.equal '<Task "Simple">'

    it 'should inspect via debug', ->
      task = Task.create 'Simple', one:124
      result = task.inspect(true)
      expect(result).to.be.equal '<Task "Simple": "one":124>'

    it.only 'should inspect via debug and options', ->
      task = Task.create 'Simple', one:124
      result = task.inspect(true, one:10, two:2)
      expect(result).to.be.equal '<Task "Simple": "one":10>'

    it 'should inspect via debug property', ->
      task = Task.create 'Simple', one:124
      task.debug = true
      result = task.inspect()
      expect(result).to.be.equal '<Task "Simple": "one":124>'
