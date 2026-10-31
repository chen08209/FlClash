# Usage: inject.sh [-a] [-r STALE]... [CERT]
#
# Mounts a copy of the trusted CAs, without any STALE certificate and with
# CERT, over the system's directory, which new mount namespaces inherit.
# Android 14 and later read the Conscrypt APEX's directory instead, whose
# mounts stay private to each namespace, so the copy is bound over it in
# init's and the zygotes' namespaces, and with -a in every running app's.
# CERT is named by its subject's old OpenSSL hash, as Android looks it up.

set -e

system=/system/etc/security/cacerts
apex=/apex/com.android.conscrypt/cacerts

apps=
stale=
while getopts ar: option; do
  case $option in
    a) apps=1 ;;
    r) stale="$stale $OPTARG" ;;
    *) exit 2 ;;
  esac
done
shift $((OPTIND - 1))
cert=$1

source=$system
[ -d "$apex" ] && source=$apex

held() {
  for file in "$1"/*; do
    if cmp -s "$2" "$file"; then
      echo "$file"
      return 0
    fi
  done
  return 1
}

current=
[ -n "$cert" ] && current=$(held "$source" "$cert") || true
removing=
for old in $stale; do
  held "$source" "$old" >/dev/null && removing=1
done

if [ -z "$removing" ] && { [ -z "$cert" ] || [ -n "$current" ]; }; then
  [ -z "$cert" ] && exit 0
else
  context=$(ls -Zd "$source" | awk '{print $1}')
  case $context in
    *:*) ;;
    *) context=u:object_r:system_file:s0 ;;
  esac

  staging=/data/local/tmp/flclash-cacerts
  rm -rf "$staging"
  mkdir -m 700 "$staging"
  cp "$source"/* "$staging"/
  for old in $stale; do
    while file=$(held "$staging" "$old"); do
      rm -f "$file"
    done
  done
  if [ -n "$cert" ]; then
    hash=${cert##*/}
    hash=${hash%.*}
    index=0
    while [ -e "$staging/$hash.$index" ]; do
      index=$((index + 1))
    done
    cp "$cert" "$staging/$hash.$index"
  fi

  mount -t tmpfs -o mode=755 tmpfs "$system"
  cp "$staging"/* "$system"/
  rm -rf "$staging"
  chown -R 0:0 "$system"
  chmod 644 "$system"/*
  chcon -R "$context" "$system"
fi

[ -d "$apex" ] || exit 0

# Bound only where the namespace sees this copy over the system directory,
# so that an app is never left with the system's older set of CAs.
device=$(stat -c %d "$system")
bind() {
  nsenter --mount="/proc/$1/ns/mnt" -- /system/bin/sh -c '
    [ "$(stat -c %d "$1")" = "$3" ] || exit 0
    [ "$(stat -c %d "$2")" = "$3" ] || mount --bind "$1" "$2"
  ' bind "$system" "$apex" "$device"
}

zygotes=" $(pidof zygote zygote64 || true) "
pids="1 $zygotes"
if [ -n "$apps" ]; then
  for status in /proc/[0-9]*/status; do
    { while read -r key value; do
      if [ "$key" = PPid: ]; then
        case $zygotes in
          *" $value "*)
            pid=${status%/status}
            pids="$pids ${pid#/proc/}"
            ;;
        esac
        break
      fi
    done < "$status"; } 2>/dev/null || true
  done
fi

for pid in $pids; do
  bind "$pid" 2>/dev/null &
done
wait
