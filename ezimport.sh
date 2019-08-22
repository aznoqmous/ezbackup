#!/bin/bash
SRC=${0%/*}
source "${SRC}/echolor.sh"

usage(){
  echo 'ezbackup import <backup_name> <destination_folder> (destination_db)'
  echo 'ezbackup import list : list available exports'
}

list_backups(){
  backups=$(ls -1 "$root_folder")
  echo ""
  for backup in $backups; do
    savefile="$root_folder/$backup/save.tar.gz"
    dbfile="$root_folder/$backup/database.sql.gz"
    echolor green "[$backup]\n"
    if [[ -f $savefile ]]; then
      echolor orange "{(FILES} $(du -ha $savefile | cut -f1){)}  "
    fi
    if [[ -f $dbfile ]]; then
      echolor orange "{(DATABASE} $(du -ha $dbfile | cut -f1){)} "
    fi
    echo ""
    echo ""
  done
}

ezimport(){
  name=$1
  destination_dir=$2
  destination_db=$3
  root_folder="/var/lib/ezbackup"

  if [[ -z $name ]]
  then
    echolor orange "Chose a backup from the list bellow :"
    read -p "$(list_backups) `echo $'\n> '`" name
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
    echolor orange "Destination folder path: "
    read destination_dir
  fi

  mkdir -p $destination_dir
  echolor orange "{Exporting backup} $name {from} $source_dir {to} $destination_dir\n"

  # FILES
  source_size=$(zcat "$source_dir/save.tar.gz" | wc --bytes)
  echolor orange "{Uncompressing} $name {archive...}\n"
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
  echolor green "Archive uncompressed.\n"

  # DATABASE
  if [[ -f "$source_dir/database.sql.gz" ]]
  then
    if [[ -z $destination_db ]]
    then
      echo 'No database selected for importation.'
      echolor orange "{Enter a} database name {or leave blank to skip database import:} "
      read -p "" destination_db
    fi
    if [[ -z $destination_db ]]
    then
      echo "" > /dev/null
    else
      echolor orange "{Importing database to} $destination_db{...}\n"
      read -s -p "MYSQL Password:" mysql_pwd
      echo ""
      mysql -u root -p$mysql_pwd -e "CREATE DATABASE IF NOT EXISTS $destination_db"
      gunzip < "$source_dir/database.sql.gz" | mysql -u root -p$mysql_pwd $destination_db
      echolor green "Database import done.\n"
    fi
  else
    echolor orange "{No database found in} $name {backup}\n"
  fi

  echo ""
  echo "Import done."
  echolor orange "{Destination folder:} $destination_dir\n"
  if [[ -z $destination_db ]]
    then echolor orange "{Destination database:} $destination_db\n"
  fi

}
