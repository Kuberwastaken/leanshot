<div align="center">

<img src="assets/leanshot-1024.png" width="128" alt="leanshot icon" />

# leanshot

**Copy every screenshot to your clipboard — while still keeping the file.**

macOS · AppleScript · zero dependencies · MIT

</div>

---

## The story

On Windows I was used to grabbing a partial screenshot and having it land in **both** places at once — copied to my clipboard *and* saved to a folder. On my Mac I could only ever get one or the other: hold `Ctrl` and it goes to the clipboard, let go and it saves a file. Never both.

I went looking for something to fix this. Everything I found was either a big all-in-one capture suite with annotation tools, cloud accounts and a subscription, or a menu-bar app doing ten things I didn't want. I just wanted the one missing behaviour — nothing else. I couldn't find a lean enough solution, so I built my own.

**leanshot** is that: a tiny background app that does exactly one thing and then gets out of the way. You keep taking screenshots the normal macOS way — same shortcut, same file, same little thumbnail in the corner — and leanshot quietly also drops each new one on your clipboard, ready to paste.

## What it does

- 📋 **Copies every new screenshot to your clipboard**, automatically.
- 💾 **Leaves everything else untouched** — the file still saves to your usual folder and the native thumbnail still shows. leanshot never moves, renames, or deletes anything.
- 🪶 **Lean.** One small AppleScript, no dependencies, no menu-bar icon, no settings to babysit, no network.
- 📸 **Works with how you already screenshot** — full screen, selection, or window (`⌘⇧4`, then Space + click). Whatever you capture, you can immediately `⌘V` it.
- 📁 **Follows your setup.** It reads wherever macOS is configured to save screenshots, so it just works even if you've changed the folder.

> **macOS only.** leanshot is built on AppleScript + login items, so it's a Mac thing by design.

## Install

### From source (recommended)

```sh
git clone https://github.com/Kuberwastaken/leanshot.git
cd leanshot
make install
```

That compiles the app, drops it in `~/Applications`, starts it, and registers it as a hidden login item so it comes back every time you log in.

### From a release

Grab `leanshot-x.y.z.zip` from the [latest release](https://github.com/Kuberwastaken/leanshot/releases/latest), unzip it, and move `leanshot.app` to `~/Applications`. Open it once; to have it start at login, add it under **System Settings → General → Login Items**.

## Usage

There's no UI — that's the point. Once it's running:

1. Take a screenshot however you normally do.
2. The file saves and the thumbnail appears, exactly like before.
3. About a second later it's also on your clipboard — just `⌘V` anywhere.

## Configuration

You usually don't need any. By default leanshot watches **wherever macOS is set to save screenshots** (`System Settings → Screenshots → Save to`), so if you change that, leanshot follows automatically.

If you'd rather pin leanshot to a specific folder regardless of the macOS setting:

```sh
# watch a specific folder
defaults write com.kuberwastaken.leanshot folder "$HOME/Pictures/Screenshots"

# go back to following the macOS screenshot location
defaults delete com.kuberwastaken.leanshot folder
```

Changes take effect within a second — no need to restart the app.

For reference, to see or change where macOS itself saves screenshots:

```sh
defaults read com.apple.screencapture location    # where they go now
defaults write com.apple.screencapture location "$HOME/Pictures/Screenshots" && killall SystemUIServer
```

## Uninstall

```sh
make uninstall
```

Stops it, removes the login item, and deletes the app. Your screenshots keep working the normal way.

## How it works

leanshot is a stay-open AppleScript applet (`LSUIElement`, so no Dock icon). About once a second it checks the folder macOS saves screenshots to, and when a brand-new image shows up it loads it onto the clipboard. That's the whole thing.

Why a login-item app instead of a `launchd` agent? On managed/MDM Macs the usual `~/Library/LaunchAgents` spot can be locked down by the org, so a plain login item is the approach that works everywhere without admin rights.

**Note on permissions:** if your screenshots save into `~/Documents`, `~/Desktop`, or `~/Downloads`, macOS may show a one-time *"leanshot would like to access files in your … folder"* prompt the first time it runs — click **OK**. That's macOS's normal file-access prompt, not leanshot phoning home (it never does).

## Building / development

```sh
make icon      # regenerate assets/leanshot.icns from the 1024px master
make build     # compile build/leanshot.app
make run       # build and launch it
make dist      # package build/leanshot-<version>.zip
make clean
```

The app icon lives in `assets/` (`leanshot-1024.png` master + `leanshot.svg` vector source); `make icon` rebuilds the multi-resolution `.icns` from the master with macOS's own `sips` + `iconutil`.

## License

MIT — see [LICENSE](LICENSE). Built by [Kuber Mehta](https://github.com/Kuberwastaken).
