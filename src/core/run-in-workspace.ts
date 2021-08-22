import { spawn } from 'child_process';
import { readdir } from 'fs/promises';
import { join, parse, resolve } from 'path';

import { downloadZip } from './downloadZip';

const libRoot = resolve(join(__dirname, '../../'))
const updatedScriptsDir = join(libRoot, '__temp__', 'sa-master', 'scripts')
const scriptsDir = join(libRoot, 'scripts')

const runShell = (workspace: string, shellFile: string, args: string[]) => {
  return new Promise(resolve => {
    const task = spawn(`sh ${shellFile}`, args, {
      cwd: workspace,
      env: process.env,
      shell: true,
      stdio: "inherit"
    })
    task.on('close', resolve)
  })
}

type Script = {
  [name: string]: {
    name: string
    fileName: string
    path: string
  }
}

const parseScripts = (dir: string, scriptsFiles: string[]) =>
  (scriptsFiles && dir) ? scriptsFiles
    .reduce((acc, fileName) => {
      const name = parse(fileName).name
      const path = join(dir, fileName)
      acc[name] = {
        path,
        name,
        fileName
      }
      return acc
    }, {} as Script) : {}

const loadScriptList = async () => {
  const scriptsFiles = await readdir(scriptsDir)
  let updatedScriptsFiles = null
  try {
    updatedScriptsFiles = await readdir(updatedScriptsDir)
  } catch (error) { }

  const scripts = parseScripts(scriptsDir, scriptsFiles)
  const updatedScripts = parseScripts(updatedScriptsDir, updatedScriptsFiles)

  return Object.assign(scripts, updatedScripts)
}

export const getArray = <T>(array: T[]) => (Array.isArray(array) ? array : [])

const upgrade = async () => {
  const tempDir = join(libRoot, "__temp__")
  await downloadZip('https://github.com/Saber2pr/sa/archive/refs/heads/master.zip', tempDir)
}

export const runInWorkspace = async () => {
  const workspacePath = process.cwd()
  const args = process.argv.slice(2)
  const scriptsList = await loadScriptList()

  const scriptName = args[0]
  const scriptArgs = args.slice(1)

  if (scriptName === '_') {
    const sysScript = scriptArgs[0]
    if (sysScript === 'upgrade' || sysScript === 'u') {
      try {
        await upgrade()
        console.log('upgrade success')
      } catch (error) {
        console.log('upgrade fail', error)
      }
      return
    }

    if (sysScript === 'ls') {
      console.log(Object.keys(scriptsList).join('\n'))
      return
    }

    console.log(`Sys Command Fail: ${sysScript} not found.`)
    return
  }

  if (scriptName in scriptsList) {
    const script = scriptsList[scriptName]
    runShell(workspacePath, script.path, scriptArgs)
  } else {
    console.log(`Run Cli Fail: ${scriptName} not found.`)
  }
}