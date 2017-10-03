#!/bin/sh

# test usr host process
# a script to test network performance while sending files.
# measures and logs CPU, memory, and time while sending different files across
# to a specified host. (username@host/IP)

# also takes in the name of a process to monitor

TIMESTAMP=$(date +%T%d%m)
ARGS=$#

if [ $ARGS -lt 2 ]
then
  echo "At least 2 arguments required."
  exit $E_WRONGARGS
fi

# what processes are you watching
P_SCP="scp"
P_SSH="ssh"
if [ $ARGS -eq 3 ]
then
  P_MON=$3
fi

# user and host to send files to
USR=$1
HOST=$2

NAME="$1@$2"

# create the logfile
#touch ./steps_log.$TIMESTAMP
#LOG_STEPS=./steps_log.$TIMESTAMP

touch ./stats_log.$TIMESTAMP
LOG_STATS=./stats_log.$TIMESTAMP

# files to send
echo "Large file to send (>1GIG): "
read ISO

echo "Small file to send (KB): "
read SM

echo "Medium file to send (MB): "
read MED

# start the tests

#flags for future reference:
# -i : ignore idle or zombie processes in top
# -b : batch mode for better writing to file
# -d : delay (set to 1 second right now)

# the upshot of -i is that if there is no significant CPU usage going on (as
# in small file copies, for instance), top will print no processes to the file.
# if, however, there is CPU activity (as in some medium and certainly all large
# file transfers, top will return those active processes.)
nohup top -i -b -d 1 >> $LOG_STATS &
#had to change this implementation because of differences in VPN implementations.

echo "\n\nSmall File Transfer - $(date +%T)\n\n" >> $LOG_STATS
scp $SM $NAME:./
echo "\n\nSmall File Transfer Finished - $(date +%T)\n\n" >> $LOG_STATS

# start the tests again
kill $(pidof top)
nohup top -i -b -d 1 >> $LOG_STATS &

echo "\n\nMedium File Transfer - $(date +%T)\n\n" >> $LOG_STATS
scp $MED $NAME:./
echo "\n\nMedium File Transfer Finished - $(date +%T)\n\n" >> $LOG_STATS

# start the tests again
kill $(pidof top)
nohup top -i -b -d 1 >> $LOG_STATS &

echo "\n\nLarge File Transfer - $(date +%T)\n\n" >> $LOG_STATS
scp $ISO $NAME:./
echo "\n\nLarge File Transfer Finished - $(date +%T)\n\n" >> $LOG_STATS

#make sure top ends
kill $(pidof top)

echo Finished! Log is at: $LOG_STATS
