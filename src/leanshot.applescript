-- leanshot — copy every new screenshot to the clipboard, without changing
-- anything else. macOS keeps saving the file (and showing its thumbnail)
-- exactly as before; leanshot just *also* drops the image on your clipboard.
--
-- It's a tiny background login-item app: it watches wherever macOS is set to
-- save screenshots and copies each new one about a second after it lands.

property lastFile : ""

on run
	repeat
		my copyLatestShot()
		delay 1
	end repeat
end run

on copyLatestShot()
	-- newest screenshot in the folder macOS is configured to save to
	-- Folder resolution, most specific first:
	--   1. an explicit leanshot override:  defaults write com.kuberwastaken.leanshot folder <path>
	--   2. wherever macOS saves screenshots (com.apple.screencapture location)
	--   3. ~/Desktop (the macOS default)
	set newest to ""
	try
		set newest to do shell script "loc=$(defaults read com.kuberwastaken.leanshot folder 2>/dev/null)
if [ -z \"$loc\" ]; then loc=$(defaults read com.apple.screencapture location 2>/dev/null); fi
if [ -z \"$loc\" ]; then loc=\"$HOME/Desktop\"; fi
loc=$(printf '%s' \"$loc\" | sed \"s|^~|$HOME|\")
ls -t \"$loc\"/*.png \"$loc\"/*.jpg \"$loc\"/*.jpeg 2>/dev/null | head -n 1"
	end try
	if newest is "" then return
	if newest is lastFile then return

	-- only act on a freshly-saved file (skip old ones, e.g. right after login)
	set fileAge to 999
	try
		set fileAge to (do shell script "echo $(( $(date +%s) - $(stat -f %m " & quoted form of newest & ") ))") as integer
	end try
	set lastFile to newest
	if fileAge > 15 then return

	try
		if newest ends with ".png" then
			set the clipboard to (read (POSIX file newest) as «class PNGf»)
		else
			set the clipboard to (read (POSIX file newest) as JPEG picture)
		end if
	end try
end copyLatestShot
