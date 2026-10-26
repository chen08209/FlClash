part of '../action.dart';

@Riverpod(keepAlive: true)
class ScriptsAction extends _$ScriptsAction {
  @override
  void build() {}

  void putScript(Script script) {
    ref.read(scriptsProvider.notifier).put(script);
    _applyIfInUse(script.id);
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

  void deleteScript(int scriptId) {
    ref.read(scriptsProvider.notifier).del(scriptId);
    if (ref.read(appSettingProvider).globalScriptId == scriptId) {
      setGlobalScript(null);
    }
  }

  void setGlobalScript(int? scriptId) {
    final previous = ref.read(appSettingProvider).globalScriptId;
    if (previous == scriptId) {
      return;
    }
    final effective = _currentEffectiveScriptId();
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(globalScriptId: scriptId));
    if (effective != _currentEffectiveScriptId()) {
      _applyProfile();
    }
  }

  int? _currentEffectiveScriptId() {
    return ref
        .read(currentProfileProvider)
        ?.effectiveScriptId(ref.read(appSettingProvider).globalScriptId);
  }

  void _applyIfInUse(int scriptId) {
    if (_currentEffectiveScriptId() == scriptId) {
      _applyProfile();
    }
  }

  void _applyProfile() {
    ref.read(setupActionProvider.notifier).applyProfileDebounce(silence: true);
  }
}
