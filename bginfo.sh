#!/bin/sh

#send top information and bandwidth information to two separate files.

# REMEMBER TO KILL THIS PROCESS MANUALLY
echo "Remember to kill this when finished!"

TIMESTAMP=$(date +%T%d%m)

# create the logfiles
mkdir ./$TIMESTAMP
touch ./$TIMESTAMP/band_log
LOG_BAND=./$TIMESTAMP/band_log

touch ./$TIMESTAMP/stats_log
LOG_STATS=./$TIMESTAMP/stats_log

background() {
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
  nohup top2 -i -b -d 1 >> $LOG_STATS &

  # track bandwidth as well. this should capture all the interfaces, regardless of
  # whether the VPN makes a new one.
  # no idea if the same issues exist here as with top and nohup vs no nohup, but
  # i am not taking any chances.
  nohup ifstat -t -T >> $LOG_BAND &
}

background &

# pid sometimes doesn't show up. either search it manually or just run 'sudo killall'
# (don't run 'killall' on a desktop please)
echo top: $(pidof top)
echo ifstat: $(pidof ifstat)
