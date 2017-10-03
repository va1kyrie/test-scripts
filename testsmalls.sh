#!/bin/sh

# test load of many small file transfers in quick succession
# measures and logs CPU, memory, time, and bandwidth while sending repetitions
# of a small file many times to a specified host (username@host/IP)

TIMESTAMP=$(date +%T%d%m)
ARGS=$#

if [ ARGS -ne 3 ]; then
  echo "3 arguments needed"
  exit $E_WRONGARGS
fi

# user and host to send files to
USR=$1
HOST=$2

NAME="$1@$2"

# number of times to send file
REPS=$3

# create the logfiles
mkdir ./$TIMESTAMP
touch ./$TIMESTAMP/band_log
LOG_BAND=./$TIMESTAMP/band_log

touch ./$TIMESTAMP/stats_log
LOG_STATS=./$TIMESTAMP/stats_log

echo "Running Small Files Test"
echo "Running Small Files Test" >> $LOG_STATS
echo "Running Small Files Test" >> $LOG_BAND

# small file to send
echo "File to send (KB): "
read SM

# start the tests

# flags for future reference:
#  -i : ignore idle or zombie processes in top
#  -b : batch mode for better writing to file
#  -d : delay (set to 1 second right now)

# the upshot of -i is that if there is no significant CPU usage going on (as
# in small file copies, for instance), top will print no processes to the file.
# if, however, there is CPU activity (as in some medium and certainly all large
# file transfers, top will return those active processes.)
# had to change this implementation because of differences in VPN implementations.
# also i have no idea why but if i don't put "nohup" there it doesn't work correctly.

# for really small files on normal networks, delay should be .1.
# on tinc, this means you're going to crash atom when you try to open the file.
# so maybe keep it at 1 second for tinc.
nohup top -i -b -d .1 >> $LOG_STATS &

# track bandwidth as well. this should capture all the interfaces, regardless of
# whether the VPN makes a new one.
# no idea if the same issues exist here as with top and nohup vs no nohup, but
# i am not taking any chances.
nohup ifstat -t -T .1 >> $LOG_BAND &

for COUNT in `seq $REPS`
do
  echo "\n\n$COUNT File Transfer - $(date +%T)\n\n" >> $LOG_STATS
  scp $SM $NAME:./
  echo "\n\n$COUNT File Transfer Finished - $(date +%T)\n\n" >> $LOG_STATS
done

# make sure everything's ended
kill $(pidof top)
kill $(pidof ifstat)

echo "Finished! Log is at: $LOG_STATS and $LOG_BAND"
