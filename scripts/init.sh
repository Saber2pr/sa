read -p "Project Name: " name

if [ "$name" = "" ]; then
  echo "The Project Name is required"
  exit
fi

read -p "Project Type (React?): " type
type=${type:-React}

tpl=""

if [ "$type" = "React" ]; then
  tpl="react-ts"
elif [ "$type" = "Vscode" ]; then
  tpl="vsc-ext-web-tpl"
elif [ "$type" = "Lib" ]; then
  tpl="ts-lib-tpl"
  exit
else
  echo "Project Type must be React, Vscode or Lib"
  exit
fi


sa git-clone-sa $tpl $name \
&& cd $name \
&& rm -rf .git \
&& git init