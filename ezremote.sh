#!/bin/bash
SRC=${0%/*}
source "${SRC}/echolor.sh"
source "${SRC}/getconf.sh"

ssh_creds="$1"
backup="$2"

tmp_file="${SRC}/tmp"
conf_file="/etc/ezbackup/ezbackup.conf"
root_folder=$(getconf "$conf_file" "root_folder")

usage(){
  echo 'ezbackup remote <remote> <backup_name>'
}


test_ssh(){
  res=$(ssh "$ssh_creds" echo "ok")
  echo $res
}

ezremote(){
  ssh_creds="$1"
  backup="$2"

  if [[ -z $ssh_creds ]]; then
    read -p "Enter SSH credentials: " ssh_creds
  fi

  if [[ -z "$(test_ssh)" ]]
  then
    echo "SSH credentials incorrect."
    exit
  else
    echo "SSH connection successfull."
  fi

  ssh $ssh_creds -t 'bash -ci "ezbackup update"' > /dev/null
  ssh $ssh_creds -t 'bash -ci "ezbackup backup_folder"' > "$tmp_file" 2>/dev/null

  while [[ -z "$backup" ]]; do
    echolor orange "Chose a backup from the list bellow :"
    read -p "$(list_backups) `echo $'\n> '`" backup
  done

  source_folder="$root_folder/$backup"
  destination_folder=$(cat "$tmp_file" | sed 's/\r//g')

  echo "Remote connection : $ssh_creds"
  echo "Destination folder : $destination_folder"
  echo "Local backup : $source_folder"

  rm -f "$tmp_file"

  read -p "Is it ok ? (Leave blank, CTRL+C to exit)" ok

  ## Work in progress
  rsync --info=progress2 --no-i-r -e ssh -avz "$source_folder" "$ssh_creds:$destination_folder"

}
