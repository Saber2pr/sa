name=$1
image=${2:-$name}
docker run -d -it --name="$name" $image