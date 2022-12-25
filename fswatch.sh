#!/bin/sh

# https://github.com/emcrisostomo/fswatch
#./configure LDFLAGS='-Wl,-rpath=\$$ORIGIN/lib'

[ -z "$1" ] && { echo [FSWATCH_REMOTE=user@host] `basename $0` "<dir> [<vol_dir>]"; exit; }

if [ -z "$FSWATCH_REMOTE" ]; then
  cmd="~/Applications/Utilities/fswatch --monitor=fsevents_monitor --event=AttributeModified --event=Renamed $1"
else
  cmd="ssh $FSWATCH_REMOTE "'"~/Applications/Utilities/fswatch --monitor=inotify_monitor --event=Updated '$1'"'
fi

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
