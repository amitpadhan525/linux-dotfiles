#!/usr/bin/env bash
# prints: " / 34%"
usage=$(df -h / --output=pcent | tail -n1 2>/dev/null | tr -d ' %')
if [ -n "$usage" ]; then
  printf " %s%%\n" "$usage"
else
  echo "disk n/a"
fi
