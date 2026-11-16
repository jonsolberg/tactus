// Tactus - a vibrating metronome for Garmin watches
// Copyright (C) 2026 Jon Solberg
// GNU General Public License v3.0 or later. See LICENSE.

import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// Buttons on the main screen:
//   START / tap middle      start or stop
//   UP / swipe down         +1 BPM
//   DOWN / swipe up         -1 BPM
//   hold UP (MENU)          settings
//   tap the tempo number    pick a tempo (touch watches)
//   BACK                    stop, or exit when stopped
class MetronomeDelegate extends WatchUi.BehaviorDelegate {

    hidden var _engine;

    function initialize(engine) {
        BehaviorDelegate.initialize();
        _engine = engine;
    }

    function onSelect() {
        _engine.toggle();
        return true;
    }

    function onPreviousPage() {
        _engine.changeBpm(1);
        return true;
    }

    function onNextPage() {
        _engine.changeBpm(-1);
        return true;
    }

    function onMenu() {
        SettingsMenu.open(_engine);
        return true;
    }

    function onBack() {
        if (_engine.playing) {
            _engine.stop();
            return true;
        }
        return false;
    }

    // Touch: tap the number to pick a tempo, anywhere else to start/stop.
    function onTap(evt) {
        var xy = evt.getCoordinates();
        var settings = System.getDeviceSettings();
        var h = settings.screenHeight;
        var y = xy[1];
        if (y > h * 0.28 && y < h * 0.58) {
            TempoPicker.open();
        } else {
            _engine.toggle();
        }
        return true;
    }
}
