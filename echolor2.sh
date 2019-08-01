#!/bin/bash
declare -A COLORS
# COLORS[black]="0;30"
COLORS[red]="0;31"
COLORS[green]="0;32"
COLORS[orange]="0;33"
COLORS[blue]="0;36" # == cyan
# COLORS[purple]="0;35"
# COLORS[cyan]="0;36"
# COLORS[light]="0;37"
# COLORS[dgray]="1;30"
# COLORS[lred]="1;31"
# COLORS[lgreen]="1;32"
COLORS[yellow]="1;33"
# COLORS[lblue]="1;34"
# COLORS[lpurple]="1;35"
# COLORS[lcyan]="1;36"
# COLORS[white]="1;37"
COLORS[err]="0;31"
COLORS[warn]="0;33"
COLORS[info]="0;36"
COLORS[success]="0;32"

# COLORS[bgblack]="40"
COLORS[bgred]="41"
COLORS[bggreen]="42"
COLORS[bgorange]="43"
COLORS[bgblue]="46" # == bgcyan
# COLORS[bgpurple]="45"
# COLORS[bgcyan]="46"
# COLORS[bgwhite]="47"

usage () {
  echo 'Usage : echolor "{color colored_string} string_with_no_color {color2 colored2_string}"'
  echo 'Example: echolor "{err Caution !} the {success package} is {warn not found}"'
  echo "Available colors :"
  for color in "${!COLORS[@]}"
  do
    echolor "{$color $color} "
  done
}

echolor () {
  if [[ -z $1 ]]; then
    usage
    exit
  fi
  content=$1

  end='\\033[0m'
  for color in "${!COLORS[@]}"
  do
    value=${COLORS[$color]}
    start='\\033['$value'm'
    content=$(echo "$content" | sed "s:{$color :$start:g")
  done
  content=$(echo "$content" | sed "s:}:$end:g")

  printf "$content"
}
