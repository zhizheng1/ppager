#!/bin/sh

if [ -z "$1" ]; then
	TTY=`tty`
	TEMPFILE=ppager_${TTY##*/}
else
	TEMPFILE=$1
fi

echo '(PID=`cat /tmp/'$TEMPFILE'.pid`; rm -f /tmp/'$TEMPFILE'.pid; kill $PID; cat>/tmp/'$TEMPFILE'.fifo)' >/tmp/$TEMPFILE
chmod +x /tmp/$TEMPFILE

mkfifo /tmp/$TEMPFILE.fifo
echo "export PAGER=/tmp/$TEMPFILE" >/tmp/$TEMPFILE.fifo &
while true; do 
	cat /tmp/$TEMPFILE.fifo|less -R &
	PID=$!
	echo $PID >/tmp/$TEMPFILE.pid
	wait $PID
	[ -f /tmp/$TEMPFILE.pid ] && break
done

rm -f /tmp/$TEMPFILE /tmp/$TEMPFILE.fifo /tmp/$TEMPFILE.pid
