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

class SimpleTask
  register SimpleTask
  aliases SimpleTask, 'simple', 'single'

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


describe 'Task', ->
  beforeEach ->SimpleTask::_executeSync.reset()

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

