#!/usr/bin/env bash
# Tactus - capture simulator screens on a virtual X display (used by CI).
# GPL v3 or later.
set -u
mkdir -p shots
export DISPLAY=:99 LIBGL_ALWAYS_SOFTWARE=1
Xvfb :99 -screen 0 1600x1000x24 +extension GLX +render -noreset >/dev/null 2>&1 &
sleep 3
SDKBIN="$(connect-iq-sdk-manager sdk current-path --bin)"
"$SDKBIN/simulator" > shots/sim.log 2>&1 &
sleep 30

snap() { import -window root "shots/$1.png"; }

run_app() {  # $1 prg, $2 device, $3 log name
  for try in 1 2 3 4 5 6 7 8; do
    monkeydo "$1" "$2" > "shots/$3.log" 2>&1 &
    sleep 12
    if ! grep -q "Unable to connect" "shots/$3.log"; then echo "connected on try $try" >> shots/sim.log; return 0; fi
    sleep 5
  done
  return 1
}

run_app dist/fenix7.prg fenix7 monkeydo-fenix7
sleep 10
snap 01-fenix7-start
xdotool key Return; sleep 2
snap 02-fenix7-after-return
exit 0
