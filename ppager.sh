#!/bin/sh

if [ -z "$1" ]; then
	TTY=`tty`
	TEMPFILE=/tmp/ppager_${TTY##*/}
else
	TEMPFILE=/tmp/$1
fi

rm -f $TEMPFILE $TEMPFILE.fifo $TEMPFILE.pid
echo '(PID=`cat '$TEMPFILE'.pid`; rm -f '$TEMPFILE'.pid; kill $PID; while [ ! -f '$TEMPFILE'.pid ]; do sleep 0.01; done; cat>'$TEMPFILE'.fifo; exit 0)' >$TEMPFILE
chmod +x $TEMPFILE
mkfifo $TEMPFILE.fifo
START=1
while true; do 
	[ -n "$START" ] && echo "export PAGER=$TEMPFILE" >$TEMPFILE.fifo &
	cat $TEMPFILE.fifo|less -R &
	PID=$!
	echo $PID >$TEMPFILE.pid
	wait $PID
	if [ -f $TEMPFILE.pid ]; then
		[ -n "$START" ] && break
		START=1
	else
		unset START
	fi
done
rm -f $TEMPFILE $TEMPFILE.fifo $TEMPFILE.pid
