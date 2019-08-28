#!/bin/bash
getconf(){
  file=$1
  key=$2
  if [[ -z $file || -z $key ]]
  then
    exit
  else
    if [[ -f $file ]]
    then
      value=$(cat "$file" | grep $key | tail -n1 | sed "s/$key://g")
      echo $value
    else
      echo "$file is not a valid file"
    fi
  fi
}
