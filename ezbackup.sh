 #!/bin/bash
SRC=${0%/*}

source "${SRC}/ezexport.sh"
source "${SRC}/ezimport.sh"
source "${SRC}/echolor.sh"
source "${SRC}/getconf.sh"

mkdir -p "/etc/ezbackup"
conf_file="/etc/ezbackup/ezbackup.conf"

init(){
  if [[ -f $conf_file ]]
  then
    echo "" > /dev/null
    root_folder=$(getconf "${SRC}/ezbackup.conf" "root_folder")
  else
    printf "" > $conf_file
    root_folder="/var/lib/ezbackup"
  fi
  mkdir -p "$root_folder"
}

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
  backup_folder_size=$(du -hs "$root_folder" | cut -f1)
  disk_space_left=$(df -h --output="avail" "$root_folder" | tail -n1 | sed 's/ //g')
  echolor orange "{backup folder:} $root_folder ($backup_folder_size / $disk_space_left left) \n"
  echolor orange "{conf file:}     $conf_file \n"
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
get_infos(){
  name=$1
  if [[ -z $name ]]
  then
    read -p "Chose a backup : $(list_backups) `echo $'\n> '`" name
  fi
  cat "$root_folder/$name/infos.log"
}

update(){
  cd "$SRC"
  git fetch
  git pull
}

init

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
    get_infos $2
  fi
  if [[ $1 == 'update' ]]; then
    update
  fi
fi
