# Reaches the processes the zygotes started before post-fs-data's mount could.
MODDIR=${0%/*}
sh "$MODDIR/inject.sh" -a "$MODDIR"/cacert/*
