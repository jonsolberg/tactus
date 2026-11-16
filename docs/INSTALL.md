# Installing Tactus on your Garmin watch

## Quick install (fēnix 7 or Instinct 2)

Download a ready-made file from the [latest release](https://github.com/jonsolberg/tactus/releases/latest), either **Tactus-fenix7.prg** or **Tactus-instinct2.prg**. Then skip to [step 6](#6-copy-it-to-the-watch) and copy it to the watch.

The build must match your watch model exactly. For any other watch, build it yourself as described below.

## Building it yourself

Tactus isn't in the Connect IQ Store (yet), so for other watches you build it yourself and copy it to the watch. You only need to do steps 1–2 once.

## 1. Install the tools (once)

1. Install **[Visual Studio Code](https://code.visualstudio.com/)**.
2. In VS Code, open Extensions (Ctrl+Shift+X), search for **Monkey C** (by Garmin) and install it.
3. Download the **Connect IQ SDK Manager** from <https://developer.garmin.com/connect-iq/sdk/> and run it.
   - Sign in with your Garmin account.
   - Under **SDK**, download the latest SDK and click **Use as active SDK**.
   - Under **Devices**, download at least **fēnix® 7** (and any other watch you want to build for).
4. Back in VS Code, press Ctrl+Shift+P and run **Monkey C: Verify Installation**. It should report that everything is OK.

## 2. Create a developer key (once)

Every Connect IQ app has to be signed.

1. Ctrl+Shift+P → **Monkey C: Generate a Developer Key**.
2. Save it somewhere safe **outside the repository**, e.g. `C:\Users\<you>\garmin\developer_key.der`.
   Keep this file. It's needed for every future update of the app.

(`.gitignore` already keeps `*.der` and `*.pem` out of Git.)

## 3. Get the code

```sh
git clone https://github.com/jonsolberg/tactus.git
```

Then open the `tactus` folder in VS Code (**File → Open Folder**).

## 4. Try it in the simulator (optional)

1. Ctrl+Shift+P → **Monkey C: Run** (or press F5) → choose **fenix7**.
2. The simulator opens with Tactus running. Click the watch buttons on screen to use it.
   The simulator can't vibrate, so turn on **Settings → Tones** in the simulator, or set *Pulse* to *Beep* in Tactus, to hear the beat.
3. To capture screenshots: **File → Save Screen Capture** in the simulator.

## 5. Build for your watch

1. Ctrl+Shift+P → **Monkey C: Build for Device**.
2. Pick **fenix7** (or your model: `fenix7s`, `fenix7x`, `fenix7pro`, `instinct2`, …).
3. Choose an output folder, e.g. `bin`. You'll get **`Tactus.prg`**.

Command-line alternative:

```sh
monkeyc -d fenix7 -f monkey.jungle -o bin/Tactus.prg -y C:\Users\<you>\garmin\developer_key.der
```

## 6. Copy it to the watch

1. Connect the watch to your computer with the Garmin USB cable.
2. **Windows:** the watch shows up under *This PC* as **fēnix 7** (an MTP device, not a drive letter).
   Open *Internal Storage → GARMIN → APPS*.
   **macOS:** install [OpenMTP](https://openmtp.ganeshrvel.com/) (Garmin Express doesn't do this) and browse to `GARMIN/APPS`.
   **Linux:** most file managers show the watch over MTP. Otherwise use `jmtpfs` / `go-mtpfs`.
3. Copy **`Tactus.prg`** into **`GARMIN/APPS`**.
4. Safely eject and unplug the watch. It installs the app within a few seconds.

## 7. Start Tactus

- **fenix 7 / fenix 6 / epix / Forerunner:** from the watch face press **START** and scroll to **Tactus**.
  If it isn't in the list, scroll to the bottom → **Add** → find Tactus under the apps, and it stays in the list after that. You can also put it on a hot key under *Settings → System → Controls* (the menu names vary a little between models).
- **Instinct 2:** press **GPS** (START) and pick Tactus from the list.
- **Venu / vivoactive:** press the top button → Tactus.

## Updating

Build a new `Tactus.prg` **with the same developer key** and copy it over the old one in `GARMIN/APPS`. Your settings are kept.

## Uninstalling

Delete `Tactus.prg` from `GARMIN/APPS` over USB, or on the watch: hold UP / MENU in the apps list → Tactus → *Remove*.

## Troubleshooting

| Problem | Fix |
|---|---|
| The app doesn't show up after copying | Make sure the file went into `GARMIN/APPS` (not `GARMIN`), then unplug the watch. Check that you built for the right model. Some older watches need a restart. |
| "Invalid device id" when building | Your SDK doesn't know one of the watches in `manifest.xml`. Remove that line, or use **Monkey C: Edit Products**. |
| The watch shows an *IQ!* icon / crash | Build again for the exact model, e.g. `fenix7pro` and not `fenix7`. If it still happens, open an issue with the contents of `GARMIN/APPS/LOGS/CIQ_LOG.YML`. |
| No vibration | Tactus shows *Vibration is off*. Turn on vibration in the watch's settings (under *System → Sounds & Alerts* on fenix 7). Also check that *Pulse* isn't set to *Beep*. |
| No beep | The watch's tones are off, or the watch has no speaker. Use *Vibrate*. |
