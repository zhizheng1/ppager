#!/bin/sh

TTY=`tty`
TEMPFILE=ppager_${TTY##*/}

echo '(PID=`cat /tmp/'$TEMPFILE'.pid`; rm -f /tmp/'$TEMPFILE'.pid; kill $PID; cat>/tmp/'$TEMPFILE'.fifo)' >/tmp/$TEMPFILE.sh
chmod +x /tmp/$TEMPFILE.sh

mkfifo /tmp/$TEMPFILE.fifo
echo "export PAGER=/tmp/$TEMPFILE.sh" >/tmp/$TEMPFILE.fifo &
while true; do 
	cat /tmp/$TEMPFILE.fifo|less -R &
	PID=$!
	echo $PID >/tmp/$TEMPFILE.pid
	wait $PID
	[ -f /tmp/$TEMPFILE.pid ] && break
done

rm -f /tmp/$TEMPFILE.sh /tmp/$TEMPFILE.fifo /tmp/$TEMPFILE.pid
