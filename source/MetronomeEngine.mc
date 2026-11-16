// Tactus - a vibrating metronome for Garmin watches
// Copyright (C) 2026 Jon Solberg
// GNU General Public License v3.0 or later. See LICENSE.

import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

// Keeps time. Each beat is scheduled against an absolute target time
// (not "interval after the last callback"), so timer jitter does not add
// up into drift over a long practice session.
class MetronomeEngine {

    const MIN_DELAY = 50;   // shortest timer Connect IQ allows (ms)

    var playing = false;
    var beat = -1;          // index of the beat that sounded last
    var bar = 0;            // bar counter since start
    var lastLevel = 0;

    hidden var _timer;
    hidden var _nextAt = 0.0;

    function initialize() {
        _timer = new Timer.Timer();
    }

    function start() {
        if (playing) {
            return;
        }
        Pulse.rebuild();
        playing = true;
        beat = -1;
        bar = 0;
        _nextAt = System.getTimer().toFloat();
        fire();
    }

    function stop() {
        if (!playing) {
            return;
        }
        playing = false;
        _timer.stop();
        beat = -1;
        WatchUi.requestUpdate();
    }

    function toggle() {
        if (playing) {
            stop();
        } else {
            start();
        }
    }

    function changeBpm(delta) {
        Prefs.setBpm(Prefs.bpm + delta);
        WatchUi.requestUpdate();
    }

    function onTimer() as Void {
        if (playing) {
            fire();
        }
    }

    hidden function fire() {
        var beats = Prefs.beatsPerBar();
        beat += 1;
        if (beat >= beats) {
            beat = 0;
        }
        if (beat == 0) {
            bar += 1;
        }
        lastLevel = Prefs.accentFor(beat);
        Pulse.beat(lastLevel);
        WatchUi.requestUpdate();

        // Tempo changes take effect from the next beat.
        var interval = 60000.0 / Prefs.bpm;
        _nextAt += interval;
        var now = System.getTimer();
        var delay = (_nextAt - now).toNumber();
        if (delay < -interval) {
            // We fell far behind (watch was busy): resync instead of
            // firing a burst of catch-up beats.
            _nextAt = now + interval;
            delay = interval.toNumber();
        } else if (delay < MIN_DELAY) {
            delay = MIN_DELAY;
        }
        _timer.start(method(:onTimer), delay, false);
    }
}
