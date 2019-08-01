 #!/bin/bash
SRC=${0%/*}
root_folder="/var/lib/ezbackup"

source "${SRC}/ezexport.sh"
source "${SRC}/ezimport.sh"
source "${SRC}/echolor.sh"

usage () {
  echo "Usage:"
  echolor green "{ezbackup} list       List available exports\n"
  echolor green "{ezbackup} export     Create a new backup\n"
  echolor green "{ezbackup} import     Import a previously created backup\n"
}

delete () {
  name=$1
  if [[ -z $name ]]; then
    ezimport list
    exit
  fi
  if [[ -d "$root_folder/$1" ]]
    then
      echolor warn "{Deleting} $root_folder/$1 \n"
      rm -rf "$root_folder/$1"
      echo "Done"
    else
      echolor green "No backup {$name} where found\n"
  fi
}

if [[ -z $1 ]]; then
  usage
  exit
else
  if [[ $1 == 'list' ]]; then
    ezimport list
  fi
  if [[ $1 == 'export' ]]; then
    ezexport $2 $3 $4
  fi
  if [[ $1 == 'import' ]]; then
    ezimport $2 $3 $4
  fi
  if [[ $1 == 'delete' ]]; then
    delete $2
  fi
fi
