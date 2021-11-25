gen_controller() {
  name=$1
  echo "import { Controller } from '@nestjs/common';

@Controller('$name')
export class ${name^}Controller {}
" > ./src/modules/$1/$1.controller.ts
}

gen_service() {
  name=$1
  echo "import { Injectable } from '@nestjs/common';

@Injectable()
export class ${name^}Service {}
" > ./src/modules/$1/$1.service.ts
}

gen_module() {
  name=$1
  echo "import { ${name^}Service } from './${name}.service';
import { ${name^}Controller } from './${name}.controller';
import { Module } from '@nestjs/common';

@Module({
  controllers: [${name^}Controller],
  providers: [${name^}Service],
  exports: [${name^}Service],
})
export class ${name^}Module {}
" > ./src/modules/$1/$1.module.ts
}


gen_controller $1
gen_service $1
gen_module $1