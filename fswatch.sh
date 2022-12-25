#!/bin/sh

# https://github.com/emcrisostomo/fswatch
#./configure LDFLAGS='-Wl,-rpath=\$$ORIGIN/lib'

[ -z "$1" ] && { echo [FSWATCH_REMOTE=user@host] `basename $0` "<dir> [<vol_dir>]"; exit; }

VOLDIR=$1
[ -n "$2" ] && VOLDIR=$2

cmd="~/Applications/Utilities/fswatch $1"
[ -n "$FSWATCH_REMOTE" ] && cmd="ssh $FSWATCH_REMOTE "'"'$cmd'  --event=Updated"'
sh -c "$cmd"|while read i; do
  [ -n "$2" ] && i=`echo $i|sed "s|$1|$2|g"`
  i=`echo $i|sed "s| |%20|g"`
  echo 'tell application "Safari"
  set windowList to every window
  repeat with aWindow in windowList
    set tabList to every tab of aWindow
    repeat with atab in tabList
      if (URL of atab is "file://'$i'") then
        set URL of atab to "file://'$i'"
      end if
    end repeat
  end repeat
end tell'|osascript
done
