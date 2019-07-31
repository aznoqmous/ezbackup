#!/bin/bash
usage () {
  echo "Usage : echolor <color> <your text>"
  echo "Available colors :"
  echolor black 'black\n'
  echolor red 'red\n'
  echolor green 'green\n'
  echolor orange 'orange\n'
  echolor blue 'blue\n'
  echolor purple 'purple\n'
  echolor cyan 'cyan\n'
  echolor light 'light\n'
  echolor dgray 'dgray\n'
  echolor lred 'lred\n'
  echolor lgreen 'lgreen\n'
  echolor yellow 'yellow\n'
  echolor lblue 'lblue\n'
  echolor lpurple 'lpurple\n'
  echolor lcyan 'lcyan\n'
  echolor white 'white\n'

  echolor err 'err\n'
  echolor warn 'warn\n'
  echolor info 'info\n'
  echolor success 'success\n'

  echolor bgblack 'bgblack\n'
  echolor bgred 'bgred\n'
  echolor bggreen 'bggreen\n'
  echolor bgyellow 'bgyellow\n'
  echolor bgblue 'bgblue\n'
  echolor bgpurple 'bgpurple\n'
  echolor bgcyan 'bgcyan\n'
  echolor bgwhite 'bgwhite\n'
}

echolor () {

  if [[ -z $2 ]]; then
    usage
    exit
  fi

  case "$1" in
    black) color="0;30";;
    red) color="0;31";;
    green) color="0;32";;
    orange) color="0;33";;
    blue) color="0;34";;
    purple) color="0;35";;
    cyan) color="0;36";;
    light) color="0;37";;
    dgray) color="1;30";;
    lred) color="1;31";;
    lgreen) color="1;32";;
    yellow) color="1;33";;
    lblue) color="1;34";;
    lpurple) color="1;35";;
    lcyan) color="1;36";;
    white) color="1;37";;

    err) color="0;31";;
    warn) color="0;33";;
    info) color="0;36";;
    success) color="0;32";;

    bgblack) color='40';;
    bgred) color='41';;
    bggreen) color='42';;
    bgorange) color='43';;
    bgblue) color='44';;
    bgpurple) color='45';;
    bgcyan) color='46';;
    bgwhite) color='47';;
  esac

  start='\033['$color'm'
  end='\033[0m'
  input=$2
  if [[ -z $(echo $input | grep -E '{|}') ]]
    then
      content="$start$input$end"
    else
      content=$(echo "$input" | sed 's:{:\'$start':g' | sed 's:}:\'$end':g' )
  fi
  printf "$content"
}
