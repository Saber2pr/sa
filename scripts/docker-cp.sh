image=$1
path=$2
target_path=$3

function verify_arg {
  if [ "$2" = "" ]; then
    echo "$1 is required: $2"
    exit
  else
    echo $2
  fi
}
  
verify_arg "image" $image
verify_arg "path" $path
verify_arg "target_path" $target_path

docker pull $image
docker cp $(docker create --rm $image):$path $target_path