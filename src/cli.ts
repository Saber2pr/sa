#!/usr/bin/env node

import { join } from 'path'
import { runInWorkspace } from './core/run-in-workspace'

runInWorkspace({
  name: 'saber2pr-cli',
  libRoot: join(__dirname, '..'),
  releaseZipUrl: 'https://github.com/Saber2pr/sa/archive/refs/heads/master.zip',
})
