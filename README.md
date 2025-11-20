# @saber2pr/cli

```bash
# install cli
npm i -g @saber2pr/cli
# fetch scripts
sa _ u
```

# Usage

```shell
# system command
sa _ <command> <args>

# upgrade scripts list
sa _ upgrade
# or
sa _ u

# ls all commands
sa _ ls

# install tab completion (bash/zsh)
sa _ completion
# or
sa _ auto

# scripts command
sa <command> <args>
```

used as a creator:

```ts
import create from '@saber2pr/cli'

create({
  name: 'saber2pr-cli',
  libRoot: join(__dirname, '..'),
  scriptsDirName: 'scripts',
  releaseZipUrl: 'https://github.com/Saber2pr/sa/archive/refs/heads/master.zip',
})
```
