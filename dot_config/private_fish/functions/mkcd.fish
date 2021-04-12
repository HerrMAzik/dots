function mkcd -d "Create directory and switch to it" -a path
  if test -z "$path"
    echo "Usage: mkcd <path>"
    return 1
  end

  mkdir -p $path
  and cd $path
end
