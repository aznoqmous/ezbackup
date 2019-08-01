#!/bin/bash
SRC=${0%/*}
source "${SRC}/echolor.sh"

usage(){
  echo 'ezbackup export <backup_name> <source_folder> (source_db)'
}

disclaimer(){
  echolor orange '\n{| NOTE:} ezbackup default exclude so-called {"node_modules"}, {"vendor"} and {"cache"} directories {|}\n\n'
}

ezexport(){
  name=$1
  source_dir=$2
  source_db=$3
  root_folder="/var/lib/ezbackup"
  # echo ""
  disclaimer
  if [[ $name == '--help' ]]; then
    usage
    exit
  fi
  if [[ -z $name ]]; then
    read -p "Enter a name for your export : " name
  fi

  destination="$root_folder/$name"

  if [[ -z $source_dir ]]
  then
    read -p "Source folder path : " source_dir
  fi

  if [[ -d $source_dir ]];
  then
    echo '' > /dev/null
  else
    echo "$source_dir is not a valid directory."
    exit
  fi

  mkdir -p $destination
  echolor green "{Creating backup} $name {from} $source_dir {to} $destination\n"

  # FILES
  source_size=$(du -bc --exclude="cache" --exclude="vendor" --exclude="node_modules" $source_dir | tail -n1 | sed 's/total//g' | sed 's/ //g')
  echolor green "Compressing files\n"
  progress_bar=50
  checkpoint=$(($source_size/10000/$progress_bar))
  for (( i=0; i<$progress_bar; i++ )); do
    printf "░"
  done
  printf "\r"

  tar --exclude="cache" --exclude="vendor" --exclude="node_modules" -zcf "$destination/save.tar.gz" -C "$source_dir" .  --record-size=10K --checkpoint=$checkpoint --checkpoint-action="ttyout=█"

  printf "\r"
  for (( i=0; i<$progress_bar; i++ )); do
    printf "  "
  done
  printf "\r"
  echo "File archive build done."

  # DATABASE
  if [[ -z $source_db ]]; then
    echolor green "{Chose a} database {or leave blank} : "
    read source_db
  fi
  if [[ -z $source_db ]]
  then
    echo "No database to export."
  else
    echolor green "{Exporting database} $source_db {to} $destination/database.sql.gz\n"
    mysqldump $source_db -u root -p | gzip > "$destination/database.sql.gz"
    echo "Database export done."
  fi

  echo "Backup done."
  echolor green "{The} $name {backup is located at} $destination\n"
  echolor green "{To import this backup :} ezbackup import "
  echolor orange "{$name} <destination folder> (destination_db)\n"

  echo ""

}

# ezexport "$@"
