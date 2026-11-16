// Tactus - a vibrating metronome for Garmin watches
// Copyright (C) 2026 Jon Solberg
// GNU General Public License v3.0 or later. See LICENSE.

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// Main screen: tempo, time signature, beat ring (round screens) and a row
// of beat dots. Draws in colour or black and white depending on Theme.
class MetronomeView extends WatchUi.View {

    hidden var _engine;
    hidden var _round = false;
    hidden var _bpmLabel = "BPM";
    hidden var _barLabel = "Bar";
    hidden var _vibeOffLabel = "";

    function initialize(engine) {
        View.initialize();
        _engine = engine;
    }

    function onLayout(dc) {
        _round = (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND);
        _bpmLabel = WatchUi.loadResource(Rez.Strings.Bpm);
        _barLabel = WatchUi.loadResource(Rez.Strings.Bar);
        _vibeOffLabel = WatchUi.loadResource(Rez.Strings.VibrationOff);
    }

    function onShow() {
        Theme.apply();
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        dc.setColor(Theme.fg, Theme.bg);
        dc.clear();

        var beats = Prefs.beatsPerBar();
        var current = _engine.playing ? _engine.beat : -1;

        if (_round) {
            drawRing(dc, w, h, beats, current);
        }

        // Time signature: in the Instinct sub-screen if there is one,
        // otherwise at the top.
        var sub = null;
        if (WatchUi has :getSubscreen) {
            sub = WatchUi.getSubscreen();
        }
        // Leave room below the Instinct sub-screen.
        var yNum = 0.44;
        var yInfo = 0.63;
        var yDots = 0.74;
        var yIcon = 0.86;
        if (sub != null) {
            yNum = 0.53;
            yInfo = 0.71;
            yDots = 0.80;
            yIcon = 0.91;
            dc.setColor(Theme.fg, Graphics.COLOR_TRANSPARENT);
            dc.drawText(sub.x + sub.width / 2, sub.y + sub.height / 2, Graphics.FONT_SMALL,
                Prefs.sigLabel(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            dc.setColor(Theme.mono ? Theme.fg : Theme.accent2, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, (h * 0.19).toNumber(), Graphics.FONT_SMALL, Prefs.sigLabel(),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Tempo
        var bpmColor = Theme.fg;
        if (current >= 0 && !Theme.mono) {
            bpmColor = Theme.colorFor(_engine.lastLevel);
        }
        dc.setColor(bpmColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (h * yNum).toNumber(), Graphics.FONT_NUMBER_THAI_HOT, Prefs.bpm.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // "BPM · Andante" (or bar counter while playing)
        var info = _bpmLabel + "  " + Prefs.tempoName();
        if (_engine.playing) {
            info = _barLabel + " " + _engine.bar.toString() + "  " + Prefs.tempoName();
        }
        dc.setColor(Theme.mono ? Theme.fg : Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, (h * yInfo).toNumber(), Graphics.FONT_XTINY, info,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        drawDots(dc, w, (h * yDots).toNumber(), beats, current);

        if (Pulse.vibrationBlocked()) {
            dc.setColor(Theme.mono ? Theme.fg : Theme.accent, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, (h * yIcon).toNumber(), Graphics.FONT_XTINY, _vibeOffLabel,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            drawPlayIcon(dc, cx, (h * yIcon).toNumber(), (h * 0.035).toNumber() + 2);
        }
    }

    // One arc segment per beat around the edge of a round screen.
    hidden function drawRing(dc, w, h, beats, current) {
        var r = (w < h ? w : h) / 2 - 4;
        var thick = (w / 32) + 2;
        var seg = 360.0 / beats;
        var gap = beats > 1 ? (beats > 8 ? 3.0 : 5.0) : 0.0;
        for (var i = 0; i < beats; i++) {
            var startDeg = 90.0 - i * seg - gap / 2;
            var endDeg = 90.0 - (i + 1) * seg + gap / 2;
            var level = Prefs.accentFor(i);
            if (i == current) {
                dc.setColor(Theme.colorFor(level), Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(thick + 2);
            } else if (Theme.mono) {
                dc.setColor(Theme.fg, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(level == 2 ? 3 : 1);
            } else {
                dc.setColor(level == 2 ? 0xAA5500 : Theme.dim, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(thick);
            }
            if (beats == 1) {
                dc.drawCircle(w / 2, h / 2, r);
            } else {
                dc.drawArc(w / 2, h / 2, r, Graphics.ARC_CLOCKWISE, normDeg(startDeg), normDeg(endDeg));
            }
        }
        dc.setPenWidth(1);
    }

    hidden function normDeg(d) {
        var n = d.toNumber() % 360;
        return n < 0 ? n + 360 : n;
    }

    // A row of dots, one per beat; the sounding beat is filled.
    hidden function drawDots(dc, w, y, beats, current) {
        var maxRow = w * 0.62;
        var step = maxRow / beats;
        var r = (w / 40) + 1;
        if (step > r * 4) {
            step = r * 4;
        }
        if (step < r * 2 + 2) {
            r = ((step - 2) / 2).toNumber();
            if (r < 2) { r = 2; }
        }
        var x0 = w / 2 - step * (beats - 1) / 2.0;
        for (var i = 0; i < beats; i++) {
            var x = (x0 + i * step).toNumber();
            var level = Prefs.accentFor(i);
            var rr = (level == 2) ? r + 1 : r;
            if (i == current) {
                dc.setColor(Theme.colorFor(level), Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x, y, rr + 1);
            } else if (Theme.mono) {
                dc.setColor(Theme.fg, Graphics.COLOR_TRANSPARENT);
                dc.drawCircle(x, y, rr);
            } else {
                dc.setColor(level > 0 ? Theme.colorFor(level) : Theme.dim, Graphics.COLOR_TRANSPARENT);
                dc.drawCircle(x, y, rr);
                if (level == 0) {
                    dc.fillCircle(x, y, rr - 1);
                }
            }
        }
    }

    // Play triangle when stopped, pause bars while running.
    hidden function drawPlayIcon(dc, x, y, s) {
        if (_engine.playing) {
            dc.setColor(Theme.fg, Graphics.COLOR_TRANSPARENT);
            var bw = (s * 2) / 3;
            dc.fillRectangle(x - s, y - s, bw, s * 2);
            dc.fillRectangle(x + s - bw, y - s, bw, s * 2);
        } else {
            dc.setColor(Theme.play, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon([[x - s + 2, y - s], [x - s + 2, y + s], [x + s + 2, y]]);
        }
    }
}
