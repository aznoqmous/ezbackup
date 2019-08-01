#!/bin/bash
SRC=${0%/*}
source "${SRC}/echolor.sh"

usage(){
  echo 'ezbackup import <backup_name> <destination_folder> (destination_db)'
  echo 'ezbackup import list : list available exports'
}

list_backups(){
  backups=$(ls -1 "$root_folder")
  for backup in $backups; do
    savefile="$root_folder/$backup/save.tar.gz"
    dbfile="$root_folder/$backup/database.sql.gz"
    echolor bggreen "\n $backup \n"
    if [[ -f $savefile ]]; then
      echolor green "{[FILES]}    $(du -ha $savefile)\n"
    fi
    if [[ -f $dbfile ]]; then
      echolor green "{[DATABASE]} $(du -ha $dbfile)\n"
    fi
  done
  echo ""
}

ezimport(){
  name=$1
  destination_dir=$2
  destination_db=$3
  root_folder="/var/lib/ezbackup"

  if [[ -z $name ]]
  then
    read -p "Chose a backup from the list bellow : $(list_backups) `echo $'\n> '`" name
  else
    if [[ $name == "list" ]]; then
      echo "Available exports ($root_folder):"
      list_backups
      exit
    fi
  fi

  source_dir="$root_folder/$name"

  if [[ -z $destination_dir ]]
  then
    echolor green "Destination folder path: "
    read destination_dir
  fi

  mkdir -p $destination_dir
  echolor green "{Exporting backup} $name {from} $source_dir {to} $destination_dir\n"

  # FILES
  source_size=$(zcat "$source_dir/save.tar.gz" | wc --bytes)
  echo "Uncompressing archive..."
  progress_bar=50
  checkpoint=$(($source_size/10000/$progress_bar))
  for (( i=0; i<$(($progress_bar-1)); i++ )); do
    printf "░"
  done
  printf "\r"

  tar -zxf "$source_dir/save.tar.gz" -C "$destination_dir/" --record-size=10K --checkpoint=$checkpoint --checkpoint-action="ttyout=█"

  printf "\r"
  for (( i=0; i<$(($progress_bar-1)); i++ )); do
    printf "  "
  done
  printf "\r"
  echo "Archive uncompressed."

  # DATABASE
  if [[ -z $destination_db ]]
  then
    echo 'No database selected for importation.'
    echo '' > /dev/null
  else
    if [[ -f "$source_dir/database.sql.gz" ]]
    then
      echo "Importing Database..."
      read -s -p "MYSQL Password:" mysql_pwd
      echo ""
      mysql -u root -p$mysql_pwd -e "CREATE DATABASE IF NOT EXISTS $destination_db"
      gunzip < "$source_dir/database.sql.gz" | mysql -u root -p$mysql_pwd $destination_db
      echo "Database import done."
    else
      echo "No database save can be found in backup folder $name"
    fi
  fi

  echo ""
  echo "Import done."

}
