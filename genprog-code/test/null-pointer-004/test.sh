#!/bin/bash
# $1 = EXE 
# $2 = test name  
# $3 = port 
# $4 = source name
# $5 = single-fitness-file name 
# exit 0 = success
ulimit -t 1
# echo $1 $2 $3 $4 $5 >> tesTrunsx.txt
case $2 in

  # p1) echo $1 0 && exit 0 ;;
  p1) $1 0 | diff output.0 - && exit 0 ;;
  p2) $1 1 | diff output.1 - && exit 0 ;;
  p3) $1 2 | diff output.2 - && exit 0 ;;
  p4) $1 4 | diff output.4 - && exit 0 ;;
  p5) $1 5 | diff output.5 - && exit 0 ;;
  p6) $1 7 | diff output.7 - && exit 0 ;;
  p7) $1 8 | diff output.8 - && exit 0 ;;
  n1) $1 3 | diff output.3 - && exit 0 ;;
  n2) $1 6 | diff output.6 - && exit 0 ;;
  n3) $1 9 | diff output.9 - && exit 0 ;;
  
  s) # single-valued fitness 
  let fit=0
  $1 0 | diff output.0 - && let fit=$fit+1
  $1 1 | diff output.1 - && let fit=$fit+1
  $1 2 | diff output.2 - && let fit=$fit+1
  $1 4 | diff output.4 - && let fit=$fit+1
  $1 5 | diff output.5 - && let fit=$fit+1
  $1 7 | diff output.7 - && let fit=$fit+1
  $1 8 | diff output.8 - && let fit=$fit+1
  ($1 3 | diff output.3 -) && let fit=$fit+1
  ($1 6 | diff output.6 -) && let fit=$fit+1
  ($1 9 | diff output.9 -) && let fit=$fit+1
  let passed_all_so_stop_search="$fit >= 8"
  echo $fit > $5
  if [ $passed_all_so_stop_search -eq 1 ] ; then 
    exit 0 
  else
    exit 1 
  fi ;;


esac 
exit 1
