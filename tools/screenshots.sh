#!/usr/bin/env bash
# Tactus - capture simulator screens on a virtual X display (used by CI).
# GPL v3 or later.
set -u
mkdir -p shots
export DISPLAY=:99
Xvfb :99 -screen 0 1600x1000x24 >/dev/null 2>&1 &
sleep 3
SDKBIN="$(connect-iq-sdk-manager sdk current-path --bin)"
ls "$SDKBIN" > shots/sdkbin.txt
"$SDKBIN/simulator" > shots/sim.log 2>&1 &
sleep 15

snap() { import -window root "shots/$1.png"; xdotool search --name "" getwindowname %@ 2>/dev/null | sort -u > "shots/$1-windows.txt"; }

# fenix 7
monkeydo dist/fenix7.prg fenix7 > shots/monkeydo-fenix7.log 2>&1 &
sleep 20
snap 01-fenix7-start
WIN=$(xdotool search --name "Simulator" | head -1)
echo "sim window: $WIN" >> shots/sim.log
if [ -n "$WIN" ]; then
  xdotool windowactivate --sync "$WIN" 2>/dev/null
  xdotool getwindowgeometry "$WIN" >> shots/sim.log
fi
xdotool key Return; sleep 2
snap 02-fenix7-after-return
exit 0
