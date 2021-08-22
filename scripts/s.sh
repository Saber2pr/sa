platform=$1
params="${@:2}"

uriencode() {
  node -p "encodeURI('${1}')"
}

keywords="$(echo "$(uriencode "$params")")"

if [ "$platform" = "" ]; then
  echo "The platform is required"
  exit
fi

if [ "$keywords" = "" ]; then
  echo "The keywords is required"
  exit
fi

url=""

if [[ "$platform" = "blog" || "$platform" = "b" ]]; then
  url="http://saber2pr.top/#?q=$keywords"
elif [[ "$platform" = "google" || "$platform" = "g" ]]; then
  url="https://www.google.com/search?q=$keywords"
elif [[ "$platform" = "github" || "$platform" = "gh" ]]; then
  url="https://github.com/search?q=$keywords"
elif [[ "$platform" = "baidu" || "$platform" = "bd" ]]; then
  url="https://www.baidu.com/s?wd=$keywords"
else
  echo "unknown platform: $platform"
  exit
fi

function search_url {
  if [ "$OSTYPE" == 'msys' ]; then
    start $url
  else 
    open $url
  fi
}

search_url
