const child_process = require('child_process')
const { join } = require('path')

const pkg = require(join(process.cwd(), 'package.json'))

const version = pkg.version
const length = version.length

const newVersion = `${version.slice(0, length - 1)}${Number(version[length - 1]) + 1}`

child_process.exec(`yarn version --new-version ${newVersion}`)