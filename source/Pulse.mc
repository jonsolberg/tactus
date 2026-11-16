// Tactus - a vibrating metronome for Garmin watches
// Copyright (C) 2026 Jon Solberg
// GNU General Public License v3.0 or later. See LICENSE.

import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;

// Buzzes (and/or beeps) one beat. Profiles are built once and reused so
// nothing is allocated on every beat.
module Pulse {

    // index: 0 normal beat, 1 secondary accent, 2 beat 1
    var _vibes = null;
    var _tones = null;

    const NORMAL_DUTY = [30, 60, 100];   // light, medium, strong

    function rebuild() {
        _vibes = null;
        _tones = null;
        if (Attention has :vibrate) {
            var duty = NORMAL_DUTY[Prefs.strength];
            var duty2 = duty + 25;
            if (duty2 > 100) { duty2 = 100; }
            _vibes = [
                [new Attention.VibeProfile(duty, 50)],
                [new Attention.VibeProfile(duty2, 75)],
                [new Attention.VibeProfile(100, 110)]
            ];
        }
        if ((Attention has :playTone) && (Attention has :ToneProfile)) {
            _tones = [
                { :toneProfile => [new Attention.ToneProfile(880, 40)], :repeatCount => 0 },
                { :toneProfile => [new Attention.ToneProfile(1320, 45)], :repeatCount => 0 },
                { :toneProfile => [new Attention.ToneProfile(1760, 60)], :repeatCount => 0 }
            ];
        }
    }

    function beat(level) {
        if (_vibes == null && _tones == null) {
            rebuild();
        }
        var mode = Prefs.pulse;
        if (mode != Prefs.PULSE_BEEP && _vibes != null) {
            Attention.vibrate(_vibes[level]);
        }
        if (mode != Prefs.PULSE_VIBRATE) {
            if (_tones != null) {
                Attention.playTone(_tones[level]);
            } else if (Attention has :playTone) {
                Attention.playTone(level == 2 ? Attention.TONE_LOUD_BEEP : Attention.TONE_KEY);
            }
        }
    }

    // True when the user wants vibration but it is switched off in the
    // watch's own settings.
    function vibrationBlocked() {
        if (Prefs.pulse == Prefs.PULSE_BEEP) {
            return false;
        }
        var ds = System.getDeviceSettings();
        return (ds has :vibrateOn) && !ds.vibrateOn;
    }
}
