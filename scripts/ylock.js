const fs = require('fs')
const path = require('path')

const fPath = path.join(process.cwd(), 'yarn.lock')

const content = fs.readFileSync(fPath, 'utf8')

const newContent = content.replaceAll(`https://registry.npm.taobao.org/`, 'https://registry.npmmirror.com/')

fs.writeFileSync(fPath, newContent, 'utf8')