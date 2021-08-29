nest g s $1 modules \
&& nest g co $1 modules \
&& nest g mo $1 modules \
&& rm src/modules/$1/*.spec.ts