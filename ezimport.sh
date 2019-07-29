name=$1
destination_dir=$2
destination_db=$3
root_folder="/var/lib/ezbackup"

function usage(){
  echo 'ezbackup import <backup_name> <destination_folder> (destination_db)'
  echo 'ezbackup import list : list available exports'
}

function list_backups(){
  backups=$(ls -1 "$root_folder")
  for backup in $backups; do
    savefile="$root_folder/$backup/save.tar.gz"
    dbfile="$root_folder/$backup/database.sql.gz"
    echo -e '\n'$backup
    if [[ -f $savefile ]]; then
      echo "[FILES] $(du -ha $savefile)"
    fi
    if [[ -f $dbfile ]]; then
      echo "[DATABASE] $(du -ha $dbfile)"
    fi
  done
  echo ""
}

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
  read -p "Destination folder path : " destination_dir
fi

mkdir -p $destination_dir
echo "Backup $name from $source_dir"

echo "Uncompressing archive..."
tar -zxf "$source_dir/save.tar.gz" -C "$destination_dir/" --checkpoint=.1000
echo "Archive uncompressed."

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
