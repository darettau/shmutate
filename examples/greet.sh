#!/usr/bin/env bash
classify() {
  local n=$1
  if [ "$n" -eq 0 ]; then
    echo zero
  elif [ "$n" -gt 0 ]; then
    echo positive
  else
    if [ "$n" -lt -100 ]; then
      echo tiny
    else
      echo negative
    fi
  fi
}
