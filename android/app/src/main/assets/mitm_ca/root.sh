# Usage: root.sh install MODULE_ZIP CERT
#        root.sh remove CERT
#
# Run through su. Exits 3 when no root manager took the module, which leaves
# the CA trusted only until the next reboot.

set -e

busybox=
for candidate in /data/adb/magisk/busybox /data/adb/ksu/bin/busybox /data/adb/ap/bin/busybox; do
  if [ -x "$candidate" ]; then
    busybox=$candidate
    break
  fi
done

# Magisk's su keeps the caller's mount namespace by default, where a mount
# would reach this app alone. The root manager's busybox runs the scripts as
# it runs a module's, and brings nsenter to an Android older than 10.
if [ -z "$FLCLASH_ROOT_STAGE" ]; then
  export FLCLASH_ROOT_STAGE=1 ASH_STANDALONE=1
  exec $busybox nsenter --mount=/proc/1/ns/mnt -- $busybox sh "$0" "$@"
fi

dir=${0%/*}
id=flclash_mitm_ca
module=/data/adb/modules/$id
pending=/data/adb/modules_update/$id

case $1 in
  install)
    zip=$2
    cert=$3
    # The manager overwrites a pending update, so its CA is kept aside to be
    # taken out of the mounted copy.
    work=/data/local/tmp/flclash-root
    rm -rf "$work"
    mkdir -m 700 "$work"
    stale=
    count=0
    for old in "$module"/cacert/* "$pending"/cacert/*; do
      [ -f "$old" ] || continue
      count=$((count + 1))
      cp "$old" "$work/$count"
      stale="$stale -r $work/$count"
    done
    managed=1
    if [ -x /data/adb/ksud ]; then
      /data/adb/ksud module install "$zip"
    elif [ -x /data/adb/apd ]; then
      /data/adb/apd module install "$zip"
    elif command -v magisk >/dev/null; then
      magisk --install-module "$zip"
    else
      managed=
    fi
    rm -f "$module/remove"
    $busybox sh "$dir/inject.sh" -a $stale "$cert"
    rm -rf "$work"
    [ -n "$managed" ] || exit 3
    ;;
  remove)
    if [ -d "$module" ]; then
      touch "$module/remove"
    fi
    rm -rf "$pending"
    $busybox sh "$dir/inject.sh" -a -r "$2"
    ;;
  *)
    exit 2
    ;;
esac
