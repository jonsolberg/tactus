// Tactus - a vibrating metronome for Garmin watches
// Copyright (C) 2026 Jon Solberg
// GNU General Public License v3.0 or later. See LICENSE.

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Number picker for jumping straight to a tempo.
module TempoPicker {
    function open() {
        var title = new WatchUi.Text({
            :text => WatchUi.loadResource(Rez.Strings.Tempo),
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_BOTTOM,
            :color => Graphics.COLOR_WHITE
        });
        var factory = new BpmFactory();
        var picker = new WatchUi.Picker({
            :title => title,
            :pattern => [factory],
            :defaults => [Prefs.bpm - Prefs.MIN_BPM]
        });
        WatchUi.pushView(picker, new TempoPickerDelegate(), WatchUi.SLIDE_UP);
    }
}

class BpmFactory extends WatchUi.PickerFactory {

    function initialize() {
        PickerFactory.initialize();
    }

    function getSize() {
        return Prefs.MAX_BPM - Prefs.MIN_BPM + 1;
    }

    function getValue(index) {
        return Prefs.MIN_BPM + index;
    }

    function getDrawable(index, selected) {
        return new WatchUi.Text({
            :text => getValue(index).toString(),
            :color => selected ? Graphics.COLOR_WHITE : Graphics.COLOR_LT_GRAY,
            :font => Graphics.FONT_NUMBER_MEDIUM,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_CENTER
        });
    }
}

class TempoPickerDelegate extends WatchUi.PickerDelegate {

    function initialize() {
        PickerDelegate.initialize();
    }

    function onAccept(values) {
        Prefs.setBpm(values[0]);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
