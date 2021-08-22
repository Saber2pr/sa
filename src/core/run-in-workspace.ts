import { spawn } from "child_process"
import { readdir } from "fs/promises"
import { join, parse, resolve } from "path"

const libRoot = resolve(join(__dirname, '../../'))
const scriptsDir = join(libRoot, 'scripts')

const runShell = (workspace: string, shellFile: string, args: string[]) => {
  return new Promise((resolve, reject) => {
    const task = spawn(`sh ${shellFile}`, args, {
      cwd: workspace,
      env: process.env,
      shell: true
    })

    let _data = ''
    let _error = ''
    task.stdout.on('data', (data) => {
      console.log(`${data}`);
      _data += data
    });

    task.stderr.on('data', (data) => {
      console.error(`${data}`);
      _error += data
    });

    task.on('close', (code) => {
      resolve(_error ? `Error: ${_error}` : _data)
    });
  })
}

type Script = {
  [name: string]: {
    name: string
    fileName: string
    path: string
  }
}

const loadScriptList = async () => {
  const scriptsFiles = await readdir(scriptsDir)
  const scripts = scriptsFiles
    .reduce((acc, fileName) => {
      const name = parse(fileName).name
      const path = join(scriptsDir, fileName)
      acc[name] = {
        path,
        name,
        fileName
      }
      return acc
    }, {} as Script)
  return scripts
}

const upgrade = async () => {
  
}

export const runInWorkspace = async () => {
  const workspacePath = process.cwd()
  const args = process.argv.slice(2)
  const scriptsList = await loadScriptList()

  const scriptName = args[0]
  const scriptArgs = args.slice(1)

  if (scriptName in scriptsList) {
    const script = scriptsList[scriptName]
    runShell(workspacePath, script.path, scriptArgs)
  } else {
    console.log(`Run Cli Fail: ${scriptName} not found.`)
  }
}