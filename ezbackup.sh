 #!/bin/bash
SRC=${0%/*}

source "${SRC}/ezexport.sh"
source "${SRC}/ezimport.sh"
source "${SRC}/echolor.sh"
source "${SRC}/getconf.sh"

root_folder=$(getconf "${SRC}/ezbackup.conf" "root_folder")

usage () {
  echolor orange "Usage:\n"
  echolor green "{ezbackup} "
  echolor orange "{export}     Create a new backup\n"
  echolor green "{ezbackup} "
  echolor orange "{import}     Import a previously created backup\n"
  echolor green "{ezbackup} "
  echolor orange "{list}       List available exports\n"
  echolor green "{ezbackup} "
  echolor orange "{delete}     Delete a previously created backup\n"
  echolor green "{ezbackup} "
  echolor orange "{infos}      Get infos about a backup\n"
  echolor orange "{backup folder:} $root_folder\n"
}

delete () {
  name=$1
  if [[ -z $name ]]
  then
    read -p "Chose a backup to delete : $(list_backups) `echo $'\n> '`" name
  fi
  if [[ -z $name ]]
  then
    echo "No backup selected."
  fi
  if [[ -d "$root_folder/$name" ]]
    then
      echolor warn "{Deleting} $root_folder/$name \n"
      rm -rf "$root_folder/$name"
      echo "Done"
    else
      echolor green "No backup {$name} where found\n"
  fi
}
infos(){
  name=$1
  if [[ -z $name ]]
  then
    read -p "Chose a backup : $(list_backups) `echo $'\n> '`" name
  fi
  cat "$root_folder/$name/infos.log"
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
  if [[ $1 == 'infos' ]]; then
    infos $2
  fi
fi
