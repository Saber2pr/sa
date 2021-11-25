moduleName=$1

moduleDir=${2:-"./src/modules"}
modulePath=$moduleDir/$moduleName

headUpperCase() {
  name=$1
  head=$(echo ${name:0:1} | tr '[a-z]' '[A-Z]')
  echo $head${name:1}
}

gen_controller() {
  name=$1
  Name=$(headUpperCase $name)
  echo "import { Controller } from '@nestjs/common';

@Controller('$name')
export class ${Name}Controller {}
" > $modulePath/$1.controller.ts
}

gen_service() {
  name=$1
  Name=$(headUpperCase $name)
  echo "import { Injectable } from '@nestjs/common';

@Injectable()
export class ${Name}Service {}
" > $modulePath/$1.service.ts
}

gen_module() {
  name=$1
  Name=$(headUpperCase $name)
  echo "import { ${Name}Service } from './${name}.service';
import { ${Name}Controller } from './${name}.controller';
import { Module } from '@nestjs/common';

@Module({
  controllers: [${Name}Controller],
  providers: [${Name}Service],
  exports: [${Name}Service],
})
export class ${Name}Module {}
" > $modulePath/$1.module.ts
}

mkdir -p $moduleDir
mkdir $modulePath

gen_controller $1
gen_service $1
gen_module $1