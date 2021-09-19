import { spawn } from 'child_process';
import { readFileSync } from 'fs';
import { readdir } from 'fs/promises';
import { homedir } from 'os';
import { join, parse, resolve } from 'path';

import { downloadZip } from './downloadZip';

const tempDir = join(homedir(), 'saber2pr-cli')
const updatedScriptsDir = join(tempDir, 'sa-master', 'scripts')

const libRoot = resolve(join(__dirname, '../../'))
const scriptsDir = join(libRoot, 'scripts')

const runner = {
  '.js': 'node',
  '.sh': 'sh'
}

const runScript = (workspace: string, script: Script, args: string[]) => {
  return new Promise(resolve => {
    const task = spawn(`${runner[script.ext]} ${script.path}`, args, {
      cwd: workspace,
      env: process.env,
      shell: true,
      stdio: "inherit"
    })
    task.on('close', resolve)
  })
}

type Script = {
  name: string
  fileName: string
  path: string
  ext: string
}

const parseScripts = (dir: string, scriptsFiles: string[]) =>
  (scriptsFiles && dir) ? scriptsFiles
    .reduce((acc, fileName) => {
      const parsed = parse(fileName)
      const path = join(dir, fileName)
      const name = parsed.name
      acc[name] = {
        path,
        name,
        fileName,
        ext: parsed.ext
      }
      return acc
    }, {} as Record<string, Script>) : {}

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

    if (sysScript === 'cat') {
      const catItem = scriptArgs[1]
      if (catItem in scriptsList) {
        console.log(readFileSync(scriptsList[catItem].path).toString('utf8'))
      } else {
        console.log(`Sys cat command Fail: ${catItem} not found.`)
      }
      return
    }

    console.log(`Sys Command Fail: ${sysScript} not found.`)
    return
  }

  if (scriptName in scriptsList) {
    const script = scriptsList[scriptName]
    runScript(workspacePath, script, scriptArgs)
  } else {
    console.log(`Run Cli Fail: ${scriptName} not found.`)
  }
}