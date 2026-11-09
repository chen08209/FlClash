part of '../action.dart';

@Riverpod(keepAlive: true)
class ScriptsAction extends _$ScriptsAction {
  @override
  void build() {}

  void putScript(Script script) {
    ref.read(scriptsProvider.notifier).put(script);
    _applyIfInUse(script.id);
  }

  void deleteScript(int scriptId) {
    final inUse = ref.read(currentProfileProvider)?.scriptId == scriptId;
    ref.read(scriptsProvider.notifier).del(scriptId);
    ref
        .read(profilesProvider.notifier)
        .updateWhere(
          (profile) => profile.scriptId == scriptId,
          (profile) => profile.copyWith(scriptId: null),
        );
    if (inUse) {
      ref
          .read(setupActionProvider.notifier)
          .applyProfileDebounce(silence: true);
    }
  }

  Future<void> updateScript(Script script) async {
    final updatingKeys = ref.read(updatingKeysProvider.notifier);
    final operation = updatingKeys.start(script.updatingKey);
    try {
      putScript(await script.update());
    } finally {
      updatingKeys.stop(script.updatingKey, operation);
    }
  }

  void _applyIfInUse(int scriptId) {
    if (ref.read(currentProfileProvider)?.scriptId != scriptId) {
      return;
    }
    ref.read(setupActionProvider.notifier).applyProfileDebounce(silence: true);
  }
}
