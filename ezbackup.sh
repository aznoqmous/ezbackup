 #!/bin/bash
SRC=${0%/*}
root_folder="/var/lib/ezbackup"

source "${SRC}/ezexport.sh"
source "${SRC}/ezimport.sh"
source "${SRC}/echolor.sh"

disclaimer(){
  echolor orange '{ __________________________________________________________________________________________________}\n'
  echolor orange '{|}                                                                                                  {|}\n'
  echolor orange '{| NOTE: } ezbackup default exclude so-called {"node_modules"}, {"vendor"} and {"cache"} directories       {|}\n'
  echolor orange '{|__________________________________________________________________________________________________|}\n'
  echo ""
}

usage () {
  echolor orange "Usage:\n"
  echolor green "{ezbackup}"
  echolor orange " {export}     Create a new backup\n"
  echolor green "{ezbackup} "
  echolor orange "{import}     Import a previously created backup\n"
  echolor green "{ezbackup} "
  echolor orange "{list}       List available exports\n"
  echolor green "{ezbackup} "
  echolor orange "{delete}     Delete a previously created backup\n"
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

if [[ -z $1 ]]; then
  usage
  exit
else
  if [[ $1 == 'list' ]]; then
    ezimport list
  fi
  if [[ $1 == 'export' ]]; then
    disclaimer
    ezexport $2 $3 $4
  fi
  if [[ $1 == 'import' ]]; then
    ezimport $2 $3 $4
    disclaimer
  fi
  if [[ $1 == 'delete' ]]; then
    delete $2
  fi
fi
