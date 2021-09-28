get_repo_name() {
  echo $1 | tr '/' '\n' | tail -n 1 | tr '.' '\n' | head -n 1
}

test=$(get_repo_name $1)

echo $test