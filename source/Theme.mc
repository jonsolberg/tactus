// Tactus - a vibrating metronome for Garmin watches
// Copyright (C) 2026 Jon Solberg
// GNU General Public License v3.0 or later. See LICENSE.

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Colours for the colour and black-and-white looks.
// The colour palette sticks to multiples of 0x55 so it maps exactly onto
// the 64-colour memory-in-pixel screens (fenix, Forerunner, Instinct...).
module Theme {

    var mono = false;
    var bg = Graphics.COLOR_BLACK;
    var fg = Graphics.COLOR_WHITE;
    var dim = Graphics.COLOR_DK_GRAY;   // inactive beats, secondary text
    var beat = 0x00AAFF;                // normal beat
    var accent2 = 0xFFAA00;             // secondary accent
    var accent = 0xFF5500;              // beat 1
    var play = 0x55FF55;                // start icon

    function apply() {
        var m;
        if (Prefs.display == Prefs.DISPLAY_AUTO) {
            m = WatchUi.loadResource(Rez.JsonData.MonoDisplay).equals("mono");
        } else {
            m = (Prefs.display == Prefs.DISPLAY_MONO);
        }
        mono = m;

        bg = Graphics.COLOR_BLACK;
        fg = Graphics.COLOR_WHITE;
        if (m) {
            dim = Graphics.COLOR_WHITE;
            beat = Graphics.COLOR_WHITE;
            accent2 = Graphics.COLOR_WHITE;
            accent = Graphics.COLOR_WHITE;
            play = Graphics.COLOR_WHITE;
        } else {
            dim = Graphics.COLOR_DK_GRAY;
            beat = 0x00AAFF;
            accent2 = 0xFFAA00;
            accent = 0xFF5500;
            play = 0x55FF55;
        }
    }

    function colorFor(level) {
        if (level == 2) { return accent; }
        if (level == 1) { return accent2; }
        return beat;
    }
}
