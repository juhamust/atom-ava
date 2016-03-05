TerminalCommandExecutor = require '../lib/terminal-command-executor'
ChildProcess = require 'child_process'
FakeSpawn = require './fake-spawn'

describe 'TerminalCommandExecutor', ->
  [executor, fake, exec, stdOutData, exitCode] = {}

  beforeEach ->
    stdOutData = ''
    exitCode = -1
    fake = new FakeSpawn
    executor = new TerminalCommandExecutor
    spyOn(ChildProcess, 'spawn').andReturn(fake)

  it 'can be created', ->
    expect(executor).not.toBeNull()

  it 'writes the command and exits if not destination folder is provided', ->
    executor.run 'command'
    expect(fake.commandsReceived[0]).toBe('command\n')
    expect(fake.commandsReceived[1]).toBe('exit\n')

  it 'writes the folder, command and exits if folder is provided', ->
    executor.run 'command', 'dir'
    expect(fake.commandsReceived[0]).toBe('cd "dir" && command\n')
    expect(fake.commandsReceived[1]).toBe('exit\n')

  it 'calls the callback when new data appears in stdout', ->
    executor.run 'command'
    executor.onDataReceived (data) -> stdOutData = data
    fake.stdout.write('some data')
    expect(stdOutData).toBe('some data')

  it 'calls the callback when the stream is closed', ->
    executor.run 'command'
    executor.onDataFinished (code) -> exitCode = code
    fake.emulateClose()
    expect(exitCode).toBe(0)
