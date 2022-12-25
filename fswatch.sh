#!/bin/sh

# https://github.com/emcrisostomo/fswatch
#./configure LDFLAGS='-Wl,-rpath=\$$ORIGIN/lib'

[ -z "$1" ] && { echo [FSWATCH_REMOTE=user@host] `basename $0` "<dir> [<addr>]"; exit; }

if [ -z "$FSWATCH_REMOTE" ]; then
  cmd="~/Applications/Utilities/fswatch --monitor=fsevents_monitor --event=AttributeModified --event=Renamed --event=Created --event=Removed --event=Updated $1"
else
  cmd="ssh $FSWATCH_REMOTE "'"~/Applications/Utilities/fswatch --monitor=inotify_monitor --event=Updated --event=Created --event=Removed '$1'"'
fi

sh -c "$cmd"|while read i; do
  if [ -z "$2" ]; then
    i=file://$i
  else
    i=`echo $i|sed "s|$1|$2|g"`
  fi
  i=`echo $i|sed "s| |%20|g"`
  echo 'tell application "Safari"
    set windowList to every window
    repeat with aWindow in windowList
      set tabList to every tab of aWindow
      repeat with atab in tabList
        if (URL of atab is "'$i'") then
          set URL of atab to "'$i'"
        end if
      end repeat
    end repeat
  end tell'|osascript
done
