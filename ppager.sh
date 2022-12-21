#!/bin/sh

if [ -z "$1" ]; then
	TTY=`tty`
	TEMPFILE=/tmp/ppager_${TTY##*/}
else
	TEMPFILE=/tmp/$1
fi

st() { STARTED=1; echo "export PAGER=$TEMPFILE" >$TEMPFILE.fifo & }
dt() { rm -f $TEMPFILE $TEMPFILE.fifo $TEMPFILE.pid; }
dt
echo '(PID=`cat '$TEMPFILE'.pid`; rm -f '$TEMPFILE'.pid; kill $PID; cat>'$TEMPFILE'.fifo; exit 0)' >$TEMPFILE
chmod +x $TEMPFILE
mkfifo $TEMPFILE.fifo
st
while true; do 
	cat $TEMPFILE.fifo|less -R &
	PID=$!
	echo $PID >$TEMPFILE.pid
	wait $PID
	if [ -f $TEMPFILE.pid ]; then
		[ -n "$STARTED" ] && break
		st
	else
		unset STARTED
	fi
done
dt
