// Tactus - a vibrating metronome for Garmin watches
// Copyright (C) 2026 Jon Solberg
// GNU General Public License v3.0 or later. See LICENSE.

import Toybox.Lang;
import Toybox.WatchUi;

// Settings menu (hold UP / MENU on the main screen).
module SettingsMenu {

    function open(engine) {
        var menu = new WatchUi.Menu2({ :title => WatchUi.loadResource(Rez.Strings.MenuTitle) });
        menu.addItem(new WatchUi.MenuItem(str(Rez.Strings.Tempo), Prefs.bpm.toString() + " BPM", :tempo, null));
        menu.addItem(new WatchUi.MenuItem(str(Rez.Strings.TapTempo), null, :tap, null));
        menu.addItem(new WatchUi.MenuItem(str(Rez.Strings.TimeSignature), Prefs.sigLabel(), :sig, null));
        menu.addItem(new WatchUi.ToggleMenuItem(str(Rez.Strings.Accent), str(Rez.Strings.AccentSub), :accent, Prefs.accent, null));
        menu.addItem(new WatchUi.MenuItem(str(Rez.Strings.Pulse), pulseLabels()[Prefs.pulse], :pulse, null));
        menu.addItem(new WatchUi.MenuItem(str(Rez.Strings.Strength), strengthLabels()[Prefs.strength], :strength, null));
        menu.addItem(new WatchUi.MenuItem(str(Rez.Strings.Display), displayLabels()[Prefs.display], :display, null));
        WatchUi.pushView(menu, new SettingsMenuDelegate(engine), WatchUi.SLIDE_UP);
    }

    function str(id) {
        return WatchUi.loadResource(id);
    }

    function pulseLabels() {
        return [str(Rez.Strings.Vibrate), str(Rez.Strings.Beep), str(Rez.Strings.Both)];
    }

    function strengthLabels() {
        return [str(Rez.Strings.Light), str(Rez.Strings.Medium), str(Rez.Strings.Strong)];
    }

    function displayLabels() {
        return [str(Rez.Strings.Auto), str(Rez.Strings.Color), str(Rez.Strings.Mono)];
    }
}

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    hidden var _engine;

    function initialize(engine) {
        Menu2InputDelegate.initialize();
        _engine = engine;
    }

    function onSelect(item) {
        var id = item.getId();
        if (id == :tempo) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            TempoPicker.open();
        } else if (id == :tap) {
            _engine.stop();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            var view = new TapTempoView();
            WatchUi.pushView(view, new TapTempoDelegate(view), WatchUi.SLIDE_LEFT);
        } else if (id == :accent) {
            Prefs.accent = (item as WatchUi.ToggleMenuItem).isEnabled();
            Prefs.save();
        } else if (id == :sig) {
            ChoiceMenu.open(str(Rez.Strings.TimeSignature), Prefs.SIG_LABELS, Prefs.sig, item, :sig);
        } else if (id == :pulse) {
            ChoiceMenu.open(str(Rez.Strings.Pulse), SettingsMenu.pulseLabels(), Prefs.pulse, item, :pulse);
        } else if (id == :strength) {
            ChoiceMenu.open(str(Rez.Strings.Strength), SettingsMenu.strengthLabels(), Prefs.strength, item, :strength);
        } else if (id == :display) {
            ChoiceMenu.open(str(Rez.Strings.Display), SettingsMenu.displayLabels(), Prefs.display, item, :display);
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    hidden function str(id) {
        return WatchUi.loadResource(id);
    }
}

// A simple pick-one list used for the settings above.
module ChoiceMenu {
    function open(title, labels, current, parentItem, key) {
        var menu = new WatchUi.Menu2({ :title => title, :focus => current });
        for (var i = 0; i < labels.size(); i++) {
            menu.addItem(new WatchUi.MenuItem(labels[i], null, i, null));
        }
        WatchUi.pushView(menu, new ChoiceMenuDelegate(labels, parentItem, key), WatchUi.SLIDE_LEFT);
    }
}

class ChoiceMenuDelegate extends WatchUi.Menu2InputDelegate {

    hidden var _labels;
    hidden var _parentItem;
    hidden var _key;

    function initialize(labels, parentItem, key) {
        Menu2InputDelegate.initialize();
        _labels = labels;
        _parentItem = parentItem;
        _key = key;
    }

    function onSelect(item) {
        var i = item.getId();
        if (_key == :sig) {
            Prefs.sig = i;
        } else if (_key == :pulse) {
            Prefs.pulse = i;
        } else if (_key == :strength) {
            Prefs.strength = i;
        } else if (_key == :display) {
            Prefs.display = i;
            Theme.apply();
        }
        Prefs.save();
        Pulse.rebuild();
        _parentItem.setSubLabel(_labels[i]);
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}
