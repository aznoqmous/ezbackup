#!/bin/bash
name=$1
source_dir=$2
source_db=$3
root_folder="/var/lib/ezbackup"

echo ""

function usage(){
  echo 'ezbackup export <backup_name> <source_folder> (source_db)'
}
function disclaimer(){
  echo 'NOTE: ezbackup default exclude so-called "node_modules", "vendor" and "cache" directories'
}

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
echo "Backup $name to $destination"

# FILES
echo "Compressing files"
source_size=$(du -bc --exclude="cache" --exclude="vendor" --exclude="node_modules" $source_dir | tail -n1 | sed 's/total//g' | sed 's/ //g')
progress_bar=$(($source_size/10000000))
printf '['
for (( i=0; i<$progress_bar; i++ )); do
  printf " "
done
printf "]\r"
printf '['
tar --exclude="cache" --exclude="vendor" --exclude="node_modules" -zcf "$destination/save.tar.gz" -C "$source_dir" . --checkpoint=.1000
echo -e "\nFile archive build done."

# DATABASE
if [[ -z $source_db ]]; then
  read -p "Chose a database or leave blank : " source_db
fi
if [[ -z $source_db ]]
then
  echo '' > /dev/null
else
  echo "Exporting Database using mysqldump $source_db -> $destination/database.sql.gz "
  mysqldump $source_db -u root -p | gzip > "$destination/database.sql.gz"
  echo -e "Database export done."
fi

echo "Backup done."
echo "Your backup $name is located at $destination"
echo "To import this backup, use : ezbackup import $name <destination folder> (destination_db)"

echo ""
