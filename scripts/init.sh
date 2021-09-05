read -p "Project Name: " name

if [ "$name" = "" ]; then
  echo "The Project Name is required"
  exit
fi

tpls="React|Vscode|Lib|Nest"

read -p "Project Type ($tpls?): " type
type=${type:-React}

tpl=""

if [ "$type" = "React" ]; then
  tpl="react-ts"
elif [ "$type" = "Vscode" ]; then
  tpl="vsc-ext-web-tpl"
elif [ "$type" = "Lib" ]; then
  tpl="ts-lib-tpl"
elif [ "$type" = "Nest" ]; then
  tpl="nest-tpl"
else
  echo "Project Type must be $tpls"
  exit
fi


sa git-clone-sa $tpl $name \
&& cd $name \
&& rm -rf .git \
&& git init \
&& yarn install \
&& code .