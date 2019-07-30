#!/bin/bash
script_path=$(echo $0 | sed 's:/ezbackup.sh::g')
# alias ezexport="sh '$script_path/ezexport.sh'"
# alias ezimport="sh '$script_path/ezimport.sh'"
source "$script_path/.bash_aliases"

function usage (){
  echo "Usage:"
  echo "ezbackup list       List available exports"
  echo "ezbackup export     Create a new backup"
  echo "ezbackup import     Import a previously created backup"
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
fi
