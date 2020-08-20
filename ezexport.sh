#!/bin/bash
SRC=${0%/*}
source "${SRC}/echolor.sh"
source "${SRC}/getconf.sh"

conf_file="/etc/ezbackup/ezbackup.conf"

usage(){
  echo 'ezbackup export <backup_name> <source_folder> (source_db)'
}

get_excludes(){
  excludes=$1
  if [[ -z $excludes ]]
  then
    excludes=$(getconf "$conf_file" "default_excludes")
  fi
  excludes=$(echo "$excludes" | tr ',' '\n')
  excludes_options=()
  for exclude in $excludes
  do
    excludes_options+=(--exclude="$exclude")
  done
  echo "${excludes_options[@]}"
}

ezexport(){
  name=$1
  source_dir=$2
  source_db=$3
  root_folder=$(getconf "$conf_file" "root_folder")
  mkdir -p $root_folder

  if [[ $name == '--help' ]]; then
    usage
    exit
  fi
  if [[ -z $name ]]; then
    read -p "Enter a name for your export : " name
  fi

  backup_name=''
  override_existing_backup=0
  while [[ -z $backup_name ]]
  do
    destination="$root_folder/$name"
    if [[ -d $destination ]]
    then
      echolor orange "{Backup} $name {already exists.}\n"
      echolor orange "{Choose a new} name {for your export or leave blank to override:} "
      read -p "" new_name
      if [[ -z $new_name ]]
      then
        override_existing_backup=1
        backup_name=$name
        echolor orange "$name {backup will be overwritten.}\n"
      else
        name=$new_name
      fi
    else
      backup_name=$name
    fi
  done


  if [[ -z $source_dir ]]
  then
    echolor orange "Source folder path : "
    read -p "" source_dir
  fi

  if [[ -d $source_dir ]];
  then
    echo '' > /dev/null
  else
    echo "$source_dir is not a valid directory."
    exit
  fi

  echolor orange "Calculating...\r"
  available_disk_space=$(df -h --output="avail" $root_folder | tail -n1)
  source_size=$(du -hs "$source_dir" | cut -f1)
  printf "              \r"
  echolor orange "{Available disk space :} $available_disk_space \n"
  echolor orange "{Backup size before compression :} $source_size \n"

  excludes=$(getconf "$conf_file" "default_excludes")
  echolor orange "{Enter comma separated} folders/files patterns to exclude {(default to 'cache,vendor,node_modules')} :\n"
  read -p '' excludes
  excludes_options=$(get_excludes $excludes)

  read -p "Confirm ?"

  if [[ $override_existing_backup == 1 ]]
  then
      rm -rf "$destination"
  fi
  mkdir -p "$destination"
  echolor orange "\n{Creating backup} $name {from} $source_dir {to} $destination\n"

  # FILES
  echolor orange "Calculating...\r"
  source_size=$(du -bc $excludes_options $source_dir | tail -n1 | sed 's/total//g' | sed 's/ //g')
  printf "              \r"
  echolor orange "Compressing files...\n"
  progress_bar=50
  checkpoint=$(($source_size/10000/$progress_bar))
  for (( i=0; i<$progress_bar; i++ )); do
    printf "░"
  done
  printf "\r"
  tar $excludes_options -zcf "$destination/save.tar.gz" -C "$source_dir" .  --record-size=10K --checkpoint=$checkpoint --checkpoint-action="ttyout=█"
  printf "\r"
  for (( i=0; i<$progress_bar; i++ )); do
    printf "  "
  done
  printf "\r"
  echo "File archive build done."

  # DATABASE
  if [[ -z $source_db ]]; then
    echolor orange "{Chose a} database {or leave blank:}"
    read source_db
  fi
  if [[ -z $source_db ]]
  then
    echolor orange "No database to export.\n"
  else
    echolor green "{Exporting database} $source_db {to} $destination/database.sql.gz\n"
    mysqldump $source_db -u root -p | gzip > "$destination/database.sql.gz"
    echo "Database export done."
  fi

  printf "Backup done.\n\n"

  infos="$destination/infos.log"
  datetime=$(date)
  excludes=$(echo $excludes_options | sed "s/--exclude=//g")
  origin=$(curl -s "ifconfig.me")
  echo "date: $datetime" > "$infos"
  echo "name: $name" >> "$infos"
  echo "source_dir: $source_dir" >> "$infos"
  echo "source_db: $source_db" >> "$infos"
  echo "excludes: $excludes" >> "$infos"
  echo "source_size: $source_size" >> "$infos"
  echo "origin: $origin" >> "$infos"

  echolor green "{The} $name {backup is located at} $destination\n"
  echolor green "To import this backup:\n"
  echolor orange "ezbackup import {$name} <destination folder> (destination_db)\n"

  echo ""

}
