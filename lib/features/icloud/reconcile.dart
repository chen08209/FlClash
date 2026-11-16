enum SyncDecision { unchanged, upload, download, conflict, missing }

SyncDecision reconcileYaml({String? base, String? local, String? remote}) {
  if (local == remote) return SyncDecision.unchanged;
  if (base == null) {
    if (local == null) return SyncDecision.download;
    if (remote == null) return SyncDecision.upload;
    return SyncDecision.conflict;
  }
  // A missing side may be an eviction or a deletion; never infer a tombstone.
  if (local == null || remote == null) return SyncDecision.missing;
  if (local == base) return SyncDecision.download;
  if (remote == base) return SyncDecision.upload;
  return SyncDecision.conflict;
}
