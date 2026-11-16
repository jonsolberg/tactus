// Tactus - a vibrating metronome for Garmin watches
// Copyright (C) 2026 Jon Solberg
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version. See LICENSE for details.

import Toybox.Application;
import Toybox.Lang;

// User settings, persisted in Application.Storage.
module Prefs {

    const MIN_BPM = 30;
    const MAX_BPM = 250;

    // Time signatures. 7/8 is counted 2+2+3, 5/4 as 3+2.
    const SIG_LABELS = ["1/4", "2/4", "3/4", "4/4", "5/4", "6/8", "7/8", "9/8", "12/8"];
    const SIG_BEATS = [1, 2, 3, 4, 5, 6, 7, 9, 12];

    const PULSE_VIBRATE = 0;
    const PULSE_BEEP = 1;
    const PULSE_BOTH = 2;

    const DISPLAY_AUTO = 0;
    const DISPLAY_COLOR = 1;
    const DISPLAY_MONO = 2;

    var bpm = 100;
    var sig = 3;         // index into SIG_LABELS, default 4/4
    var accent = true;   // stronger pulse on beat 1
    var pulse = PULSE_VIBRATE;
    var strength = 1;    // 0 light, 1 medium, 2 strong
    var display = DISPLAY_AUTO;

    function load() {
        bpm = clamp(readNumber("bpm", 100), MIN_BPM, MAX_BPM);
        sig = clamp(readNumber("sig", 3), 0, SIG_BEATS.size() - 1);
        accent = readNumber("accent", 1) != 0;
        pulse = clamp(readNumber("pulse", PULSE_VIBRATE), 0, 2);
        strength = clamp(readNumber("strength", 1), 0, 2);
        display = clamp(readNumber("display", DISPLAY_AUTO), 0, 2);
    }

    function save() {
        Application.Storage.setValue("bpm", bpm);
        Application.Storage.setValue("sig", sig);
        Application.Storage.setValue("accent", accent ? 1 : 0);
        Application.Storage.setValue("pulse", pulse);
        Application.Storage.setValue("strength", strength);
        Application.Storage.setValue("display", display);
    }

    function setBpm(value) {
        bpm = clamp(value, MIN_BPM, MAX_BPM);
        save();
    }

    function beatsPerBar() {
        return SIG_BEATS[sig];
    }

    function sigLabel() {
        return SIG_LABELS[sig];
    }

    // 2 = main accent, 1 = secondary accent, 0 = normal beat.
    function accentFor(beat) {
        if (!accent || SIG_BEATS[sig] == 1) {
            return 0;
        }
        if (beat == 0) {
            return 2;
        }
        var beats = SIG_BEATS[sig];
        if (beats == 6 || beats == 9 || beats == 12) {
            // compound time: accent every dotted quarter
            return (beat % 3 == 0) ? 1 : 0;
        }
        if (beats == 7) {
            // 2+2+3
            return (beat == 2 || beat == 4) ? 1 : 0;
        }
        if (beats == 5) {
            // 3+2
            return (beat == 3) ? 1 : 0;
        }
        return 0;
    }

    // Classic Italian tempo marking for the current tempo.
    function tempoName() {
        if (bpm < 40) { return "Grave"; }
        if (bpm < 60) { return "Largo"; }
        if (bpm < 66) { return "Larghetto"; }
        if (bpm < 76) { return "Adagio"; }
        if (bpm < 108) { return "Andante"; }
        if (bpm < 120) { return "Moderato"; }
        if (bpm < 168) { return "Allegro"; }
        if (bpm < 200) { return "Presto"; }
        return "Prestissimo";
    }

    function readNumber(key, def) {
        var v = Application.Storage.getValue(key);
        if (v instanceof Lang.Number) {
            return v;
        }
        return def;
    }

    function clamp(v, lo, hi) {
        if (v < lo) { return lo; }
        if (v > hi) { return hi; }
        return v;
    }
}
