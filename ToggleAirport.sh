#!/usr/bin/env sh

# Toogle script to be used as a trigger with Quicksilver.
#
# My choice of QS Configuration
#   - Hot Key: Ctrl + Opt + Cmd + W
#   - Delay  : Hold for 0.5s
#   - Display: Show Window

AIRPORT_BIN='/opt/local/bin/airport'

if [ ! -x ${AIRPORT_BIN} ]; then
	echo "Airport command line utility not found in '${AIRPORT_BIN}'."
	echo "It's available via MacPorts under package name 'airport'."
	exit 1
fi

if ${AIRPORT_BIN} -p > /dev/null 2>&1; then
	${AIRPORT_BIN} -P 0
else
	${AIRPORT_BIN} -P 1
fi
