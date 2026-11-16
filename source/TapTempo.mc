// Tactus - a vibrating metronome for Garmin watches
// Copyright (C) 2026 Jon Solberg
// GNU General Public License v3.0 or later. See LICENSE.

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// Tap START (or the screen) in time; the tempo is the average of the last
// few taps. BACK keeps the new tempo.
class TapTempoView extends WatchUi.View {

    var taps = [];
    var tapped = 0;          // BPM from taps, 0 = none yet
    hidden var _hint1 = "";
    hidden var _hint2 = "";
    hidden var _hint3 = "";
    hidden var _title = "";

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        _title = WatchUi.loadResource(Rez.Strings.TapTempo);
        _hint1 = WatchUi.loadResource(Rez.Strings.TapHint);
        _hint2 = WatchUi.loadResource(Rez.Strings.TapHint2);
        _hint3 = WatchUi.loadResource(Rez.Strings.TapSave);
    }

    function tap() {
        var now = System.getTimer();
        var n = taps.size();
        if (n > 0 && now - taps[n - 1] > 2500) {
            taps = [];   // long pause: start over
        }
        taps.add(now);
        if (taps.size() > 8) {
            taps = taps.slice(1, null);
        }
        n = taps.size();
        if (n >= 2) {
            var avg = (taps[n - 1] - taps[0]).toFloat() / (n - 1);
            if (avg > 0) {
                tapped = Prefs.clamp((60000.0 / avg + 0.5).toNumber(), Prefs.MIN_BPM, Prefs.MAX_BPM);
            }
        }
        Pulse.beat(0);
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var j = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;

        dc.setColor(Theme.fg, Theme.bg);
        dc.clear();

        dc.setColor(Theme.mono ? Theme.fg : Theme.accent2, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (h * 0.2).toNumber(), Graphics.FONT_SMALL, _title, j);

        dc.setColor(tapped > 0 ? Theme.fg : (Theme.mono ? Theme.fg : Theme.dim), Graphics.COLOR_TRANSPARENT);
        var shown = tapped > 0 ? tapped : Prefs.bpm;
        dc.drawText(cx, (h * 0.46).toNumber(), Graphics.FONT_NUMBER_THAI_HOT, shown.toString(), j);

        dc.setColor(Theme.mono ? Theme.fg : Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (h * 0.68).toNumber(), Graphics.FONT_XTINY, _hint1 + " " + _hint2, j);
        dc.drawText(cx, (h * 0.79).toNumber(), Graphics.FONT_XTINY, _hint3, j);
    }
}

class TapTempoDelegate extends WatchUi.BehaviorDelegate {

    hidden var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onSelect() {
        _view.tap();
        return true;
    }

    function onTap(evt) {
        _view.tap();
        return true;
    }

    function onBack() {
        if (_view.tapped > 0) {
            Prefs.setBpm(_view.tapped);
        }
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
