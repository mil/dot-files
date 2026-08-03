#!/bin/sh
# cm.sh: fuzzy-match a LUKS drive by uuid/label, mount or unmount it

set -e

dev() {
  for f in /dev/disk/by-id/*"$1"* /dev/disk/by-uuid/*"$1"* /dev/disk/by-partuuid/*"$1"* /dev/disk/by-label/*"$1"*; do
    [ -e "$f" ] || continue
    readlink -f "$f"
  done | sort -u
}

type_of()  { blkid "$1" | grep -o 'TYPE="[^"]*"'  | cut -d'"' -f2; }
uuid_of()  { blkid "$1" | grep -o ' UUID="[^"]*"' | cut -d'"' -f2; }
prefix()   { uuid_of "$1" | cut -c1-8; }

label_of() {
  for f in /dev/disk/by-label/*; do
    [ -e "$f" ] || continue
    [ "$(readlink -f "$f")" = "$1" ] && basename "$f" && return
  done
}

list_devices() {
  for f in /dev/disk/by-id/*; do
    d=$(readlink -f "$f")
    [ "$(type_of "$d")" = crypto_LUKS ] || continue
    lbl=$(label_of "$d")
    echo "$(basename "$f")  uuid=$(uuid_of "$d")  label=${lbl:-none}"
  done
}

mount_dev() {
  [ -n "$1" ] || { usage; exit 1; }
  matches=$(dev "$1")
  n=$(printf '%s\n' "$matches" | wc -l)
  [ -n "$matches" ] || { echo "no device matches '$1'" >&2; exit 1; }
  [ "$n" -eq 1 ] || { echo "ambiguous fragment '$1':"; echo "$matches"; exit 1; }

  d="$matches"
  lbl=$(label_of "$d")
  name=${lbl:-$(prefix "$d")}
  cryptsetup open "$d" "$name"
  fs=$(type_of "/dev/mapper/$name")
  mnt="/mnt/${name}_${fs:-raw}"
  mkdir -p "$mnt"
  modprobe "$fs" 2>/dev/null || true
  if ! mount "/dev/mapper/$name" "$mnt"; then
    echo "mount failed, closing $name and cleaning up" >&2
    rmdir "$mnt" 2>/dev/null
    cryptsetup close "$name"
    exit 1
  fi
  echo "mounted -> $mnt"
}

umount_dev() {
  [ -n "$1" ] || { usage; exit 1; }
  name="$1"
  if [ ! -e "/dev/mapper/$name" ]; then
    matches=$(dev "$1")
    n=$(printf '%s\n' "$matches" | wc -l)
    [ -n "$matches" ] || { echo "no device matches '$1'" >&2; exit 1; }
    [ "$n" -eq 1 ] || { echo "ambiguous fragment '$1':"; echo "$matches"; exit 1; }
    lbl=$(label_of "$matches")
    name=${lbl:-$(prefix "$matches")}
  fi
  mnt=$(findmnt -n -o TARGET "/dev/mapper/$name") || { echo "'$name' is not mounted" >&2; exit 1; }
  umount "$mnt"
  cryptsetup close "$name"
  rmdir "$mnt"
  echo "closed -> $name"
}

usage() {
  cat <<EOF
  m [label] : mount disk by uuid or label
  u [label] : unmount disk by uuid or label
  l         : list disks
EOF
}

case "$1" in
  l) list_devices ;;
  m) mount_dev "$2" ;;
  u) umount_dev "$2" ;;
  *) usage ;;
esac