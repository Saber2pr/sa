gen_entity() {
  name=$1
  echo "\
import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity()
export class ${name^}Entity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column('varchar', { length: 255, default: '' })
  name: string;

  @Column('varchar', { length: 255, default: '' })
  value: string;
}" > ./src/modules/$1/$1.entity.ts
}

nest g s $1 modules \
&& nest g co $1 modules \
&& nest g mo $1 modules \
&& rm src/modules/$1/*.spec.ts \
&& gen_entity $1