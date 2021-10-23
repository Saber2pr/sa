import { spawn } from 'child_process'
import { readFileSync } from 'fs'
import { readdir } from 'fs/promises'
import { homedir } from 'os'
import { join, parse } from 'path'

import { downloadZip } from './downloadZip'

const getTempDir = (cliName: string) => join(homedir(), cliName)

const getUpdatedScriptsDir = async (cliName: string, scriptsDir: string) => {
  const tempDir = getTempDir(cliName)
  const result = await readdir(tempDir)
  return join(getTempDir(cliName), result[0], scriptsDir)
}

const runner = {
  '.js': 'node',
  '.sh': 'sh',
}

const runScript = (workspace: string, script: Script, args: string[]) => {
  return new Promise(resolve => {
    const task = spawn(`${runner[script.ext]} ${script.path}`, args, {
      cwd: workspace,
      env: process.env,
      shell: true,
      stdio: 'inherit',
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
  scriptsFiles && dir
    ? scriptsFiles.reduce((acc, fileName) => {
        const parsed = parse(fileName)
        const path = join(dir, fileName)
        const name = parsed.name
        acc[name] = {
          path,
          name,
          fileName,
          ext: parsed.ext,
        }
        return acc
      }, {} as Record<string, Script>)
    : {}

const loadScriptList = async (
  cliName: string,
  libRoot: string,
  scriptsDirName: string
) => {
  const scriptsDir = join(libRoot, scriptsDirName)
  const scriptsFiles = await readdir(scriptsDir)
  let updatedScripts = {}
  try {
    const updatedScriptsDir = await getUpdatedScriptsDir(
      cliName,
      scriptsDirName
    )
    const updatedScriptsFiles = await readdir(updatedScriptsDir)
    updatedScripts = parseScripts(updatedScriptsDir, updatedScriptsFiles)
  } catch (error) {}

  const scripts = parseScripts(scriptsDir, scriptsFiles)

  return Object.assign(scripts, updatedScripts)
}

export const getArray = <T>(array: T[]) => (Array.isArray(array) ? array : [])

const upgrade = async (cliName: string, releaseZipUrl: string) => {
  await downloadZip(releaseZipUrl, getTempDir(cliName))
}

const PROFILE = '_profile'

export interface CliFactoryOptions {
  name: string
  libRoot: string
  /**
   * default is `scripts`
   */
  scriptsDirName?: string
  /**
   * for command `_ u`
   */
  releaseZipUrl?: string
}

export const runInWorkspace = async ({
  name,
  libRoot,
  scriptsDirName = 'scripts',
  releaseZipUrl,
}: CliFactoryOptions) => {
  name = `cli_${name}`
  const workspacePath = process.cwd()
  const args = process.argv.slice(2)
  const scriptsList = await loadScriptList(name, libRoot, scriptsDirName)
  const profileScript = scriptsList[PROFILE]
  delete scriptsList[PROFILE]

  const scriptName = args[0]
  const scriptArgs = args.slice(1)

  if (scriptName === '_') {
    const sysScript = scriptArgs[0]
    if (sysScript === 'upgrade' || sysScript === 'u') {
      if (releaseZipUrl) {
        try {
          await upgrade(name, releaseZipUrl)
          console.log('upgrade success')
        } catch (error) {
          console.log('upgrade fail', error)
        }
        return
      }
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

  if (scriptName) {
    if (scriptName in scriptsList) {
      const script = scriptsList[scriptName]
      runScript(workspacePath, script, scriptArgs)
    } else {
      console.log(`Run Cli Fail: ${scriptName} not found.`)
    }
  } else {
    if (profileScript) {
      runScript(workspacePath, profileScript, scriptArgs)
    }
  }
}
