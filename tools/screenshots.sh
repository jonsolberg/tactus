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
burst() { for i in 1 2 3 4 5 6 7 8; do import -window root "shots/$1-$i.png"; sleep 0.05; done; }
click() { xdotool mousemove "$1" "$2" click 1; sleep "${3:-0.6}"; }
hold() { xdotool mousemove "$1" "$2" mousedown 1; sleep 2.2; xdotool mouseup 1; sleep 1; }

run_app() {  # $1 prg, $2 device, $3 log name
  for try in 1 2 3 4 5 6 7 8; do
    monkeydo "$1" "$2" > "shots/$3.log" 2>&1 &
    sleep 12
    if ! grep -q "Unable to connect" "shots/$3.log"; then echo "connected on try $try" >> shots/sim.log; return 0; fi
    sleep 5
  done
  return 1
}

# fenix 7 buttons in the simulator window
START="388 200"; BACK="378 400"; UP="16 300"; DOWN="40 398"

run_app dist/fenix7.prg fenix7 monkeydo-fenix7
sleep 8
snap f7-01-ready
click $START 0.3
burst f7-02-playing
sleep 2
burst f7-03-playing
click $START 1
hold $UP
snap f7-04-menu
# Time signature (3rd item) -> 6/8
click $DOWN; click $DOWN
snap f7-05-menu-sig
click $START 1
snap f7-06-sig-list
click $DOWN; click $DOWN
click $START 1
click $BACK 1
snap f7-07-after-sig
# tempo up to 138
for i in $(seq 1 38); do click $UP 0.15; done
sleep 1
snap f7-08-138
click $START 0.3
burst f7-09-68-playing
sleep 1.5
burst f7-10-68-playing
click $START 1
# tap tempo
hold $UP
click $DOWN
click $START 1
for i in 1 2 3 4 5; do click $START 0.6; done
sleep 0.5
snap f7-11-tap
click $BACK 1
snap f7-12-after-tap

# Instinct 2
run_app dist/instinct2.prg instinct2 monkeydo-instinct2
sleep 8
snap i2-01-ready
exit 0
