#!/bin/zsh
# Build assets/leanshot.icns from the 1024px master PNG, using only macOS
# built-ins (sips + iconutil). The master (assets/leanshot-1024.png) and its
# vector source (assets/leanshot.svg) are committed design assets.
set -euo pipefail

root=${0:a:h:h}
master="$root/assets/leanshot-1024.png"
if [ ! -f "$master" ]; then
	echo "error: $master not found (it's a committed asset)" >&2
	exit 1
fi

work=$(mktemp -d)
iset="$work/leanshot.iconset"
mkdir -p "$iset"
for s in 16 32 128 256 512; do
	sips -z $s $s "$master" --out "$iset/icon_${s}x${s}.png" >/dev/null
	sips -z $((s * 2)) $((s * 2)) "$master" --out "$iset/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$iset" -o "$root/assets/leanshot.icns"
rm -rf "$work"
echo "wrote $root/assets/leanshot.icns"
