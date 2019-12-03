#!/bin/bash
SRC=${0%/*}
source "${SRC}/echolor.sh"
source "${SRC}/getconf.sh"

ssh_creds="$1"
backup="$2"

tmp_file="${SRC}/tmp"
conf_file="/etc/ezbackup/ezbackup.conf"
root_folder=$(getconf "$conf_file" "root_folder")

test_ssh(){
  res=$(ssh "$ssh_creds" echo "ok")
  echo $res
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

if [[ -z "$(test_ssh)" ]]
then
  echo "SSH credentials incorrect"
  exit
fi

ssh $ssh_creds -t 'bash -ci "ezbackup update"' > /dev/null
ssh $ssh_creds -t 'bash -ci "ezbackup backup_folder"' > "$tmp_file" 2>/dev/null

if [[ -z $backup ]]
then
  echolor orange "Chose a backup from the list bellow :"
  read -p "$(list_backups) `echo $'\n> '`" backup
else
  if [[ $name == "list" ]]; then
    echo "Available exports ($root_folder):"
    list_backups
    exit
  fi
fi
source_folder="$root_folder/$backup"
destination_folder=$(cat "$tmp_file" | sed 's/\r//g')

echo "Remote connection : $ssh_creds"
echo "Destination folder : $destination_folder"
echo "Local backup : $source_folder"

rm -f "$tmp_file"

read -p "Is it ok ? (Leave blank, CTRL+C to exit)" ok



## Work in progress
rsync --info=progress2 --no-i-r -e ssh -avz "$source_folder" "$ssh_creds:$destination_folder"
