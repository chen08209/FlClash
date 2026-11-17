part of '../action.dart';

MitmModuleContent _parseMitmModule((String, Map<String, String>) source) =>
    parseMitmModule(source.$1, values: source.$2);

@Riverpod(keepAlive: true)
class MitmModulesAction extends _$MitmModulesAction {
  var _autoUpdating = false;

  /// Files written before a row or a line names them, which [clean] keeps.
  final _held = <String>[];

  /// Deletions run one at a time: two at once can both find a file still there
  /// and the later delete fails.
  Future<void> _deleting = Future.value();

  @override
  void build() {}

  Future<MitmModule> addFromUrl(String url) async {
    final response = await request.getTextResponseForUrl(url);
    final segments = Uri.tryParse(url)?.pathSegments ?? const <String>[];
    final name = segments.where((segment) => segment.isNotEmpty).lastOrNull;
    return _save(
      MitmModule(
        id: snowflake.id,
        name: basenameWithoutExtension(name ?? url),
        url: url,
        lastUpdateTime: DateTime.now(),
      ),
      response.data ?? '',
      added: true,
    );
  }

  Future<MitmModule> addFromFile(String text, String fileName) {
    return _save(
      MitmModule(
        id: snowflake.id,
        name: basenameWithoutExtension(fileName),
        lastUpdateTime: DateTime.now(),
      ),
      text,
      added: true,
    );
  }

  Future<MitmModule> create(String text) {
    return _save(
      MitmModule(
        id: snowflake.id,
        name: currentAppLocalizations.mitmModule,
        lastUpdateTime: DateTime.now(),
      ),
      text,
      added: true,
      first: true,
      edited: true,
    );
  }

  Future<MitmModule> edit(MitmModule module, String text) {
    return _save(module, text, edited: true);
  }

  Future<MitmModule> updateModule(MitmModule module) async {
    final updatingKeys = ref.read(updatingKeysProvider.notifier);
    final operation = updatingKeys.start(module.updatingKey);
    try {
      final url = module.url;
      if (url == null) {
        return await _save(
          module,
          await File(await _pathOf(module)).readAsString(),
        );
      }
      final response = await request.getTextResponseForUrl(url);
      return await _save(module, response.data ?? '');
    } finally {
      updatingKeys.stop(module.updatingKey, operation);
    }
  }

  void putModule(MitmModule module, {bool first = false}) {
    ref.read(mitmModulesProvider.notifier).put(module, first: first);
  }

  Future<MitmModule?> setArguments(
    MitmModule module,
    Map<String, String> arguments,
  ) async {
    putModule(module.copyWith(arguments: arguments));
    final held = <String>[];
    try {
      final wasAccepted = await _accepted(module);
      final text = await File(await _pathOf(module)).readAsString();
      final content = await compute(_parseMitmModule, (text, arguments));
      final missing = content.resourceUrls.difference({
        ...module.resources.keys,
      });
      final fetched = missing.isEmpty || !ref.mounted
          ? const <String, String>{}
          : await _download(missing, previous: const {}, held: held);
      final written = await _writeInline({
        for (final MapEntry(:key, :value) in content.inlineResources.entries)
          if (!module.resources.containsKey(key)) key: value,
      }, held);
      final current = await _current(module.id);
      if (!ref.mounted || current == null) {
        return current;
      }
      final changed = current.copyWith(
        enabled: _staysOn(current, content, wasAccepted: wasAccepted),
        accepted: current.accepted ?? wasAccepted,
        resources: {...current.resources, ...fetched, ...written},
        scripts: content.declaredScripts,
      );
      if (changed != current) {
        putModule(changed);
        _awaitConsentIfTurnedOff(current, changed);
      }
      return changed;
    } on FileSystemException catch (e) {
      commonPrint.log(
        'MITM module ${module.name}: ${compactError(e)}',
        logLevel: LogLevel.warning,
      );
      return null;
    } finally {
      held.forEach(_held.remove);
    }
  }

  Future<void> attach(
    MitmModule module,
    String fileName,
    List<int> bytes,
  ) async {
    if (bytes.length > maxMitmResourceSize) {
      throw MessageException(
        currentAppLocalizations.mitmFileTooLarge(maxMitmResourceSize >> 20),
      );
    }
    final name = await _storeResource(fileName, bytes);
    try {
      final current = await _current(module.id);
      if (current != null && ref.mounted) {
        putModule(
          current.copyWith(resources: {...current.resources, fileName: name}),
        );
      }
    } finally {
      _held.remove(name);
    }
  }

  Future<void> detach(MitmModule module, String fileName) async {
    final current = await _current(module.id);
    if (current == null || !ref.mounted) {
      return;
    }
    putModule(
      current.copyWith(
        resources: {
          for (final MapEntry(:key, :value) in current.resources.entries)
            if (key != fileName) key: value,
        },
      ),
    );
    await clean();
  }

  Future<void> deleteModule(MitmModule module) async {
    ref.read(mitmModulesProvider.notifier).del(module.id);
    final path = await _pathOf(module);
    await _oneDeletionAtATime(() async {
      await File(path).safeDelete();
      await _sweep();
    });
  }

  Future<void> _oneDeletionAtATime(Future<void> Function() delete) =>
      _deleting = _deleting.then((_) {}, onError: (_) {}).then((_) => delete());

  Future<String> _pathOf(MitmModule module) async {
    return join(await appPath.mitmModulesDirPath, module.fileName);
  }

  Future<MitmModule?> _current(int id) async => (await ref.read(
    mitmModulesProvider.future,
  )).where((item) => item.id == id).firstOrNull;

  /// Accepting a module's scripts or network changes trusts its source, so
  /// later saves keep it on.
  Future<MitmModule> _save(
    MitmModule module,
    String text, {
    bool added = false,
    bool first = false,
    bool edited = false,
  }) async {
    final content = await compute(_parseMitmModule, (text, module.arguments));
    if (content.isEmpty && !edited) {
      throw MessageException(currentAppLocalizations.mitmModuleInvalid);
    }
    final held = [module.fileName];
    _held.addAll(held);
    try {
      final resources = await _download(
        content.resourceUrls,
        previous: module.resources,
        held: held,
      );
      final written = await _writeInline(content.inlineResources, held);
      final wasAccepted = !added && await _accepted(module);
      await File(await _pathOf(module)).writeAsStringAtomically(text);
      if (!ref.mounted) {
        return module;
      }
      final current = added ? module : await _current(module.id);
      if (current == null || !ref.mounted) {
        return module;
      }
      final saved = current.copyWith(
        name: content.name ?? current.name,
        description: content.description ?? '',
        system: content.system,
        enabled: added
            ? !_asksConsent(content)
            : _staysOn(current, content, wasAccepted: wasAccepted),
        accepted: current.accepted ?? wasAccepted,
        scripts: content.declaredScripts,
        resources: {...mitmAttachments(current), ...resources, ...written},
        lastUpdateTime: DateTime.now(),
      );
      putModule(saved, first: first);
      _awaitConsentIfTurnedOff(current, saved);
      return saved;
    } finally {
      held.forEach(_held.remove);
      if (ref.mounted) {
        unawaited(_cleanAfterSave());
      }
    }
  }

  void _awaitConsentIfTurnedOff(MitmModule before, MitmModule after) {
    if (before.enabled && !after.enabled) {
      ref.read(mitmModulesAwaitingConsentProvider.notifier).add(after.id);
    }
  }

  bool _asksConsent(MitmModuleContent content) =>
      content.declaredScripts > 0 || content.asksConsent;

  bool _staysOn(
    MitmModule current,
    MitmModuleContent content, {
    required bool wasAccepted,
  }) =>
      current.enabled &&
      ((current.accepted ?? wasAccepted) || !_asksConsent(content));

  /// A module stored before agreement was recorded counts as agreed to when it
  /// was on with something turning it on asks about.
  Future<bool> _accepted(MitmModule module) async {
    if (module.accepted case final accepted?) {
      return accepted;
    }
    if (!module.enabled) {
      return false;
    }
    if (module.scripts > 0) {
      return true;
    }
    final file = File(await _pathOf(module));
    if (!await file.exists()) {
      return false;
    }
    final content = await compute(_parseMitmModule, (
      await file.readAsString(),
      module.arguments,
    ));
    return content.asksConsent;
  }

  Future<void> _cleanAfterSave() async {
    try {
      await clean();
    } catch (e) {
      if (ref.mounted) {
        commonPrint.log(
          'MITM module clean: ${compactError(e)}',
          logLevel: LogLevel.warning,
        );
      }
    }
  }

  /// A resource that fails to download keeps the copy an earlier update left.
  Future<Map<String, String>> _download(
    Set<String> urls, {
    required Map<String, String> previous,
    required List<String> held,
  }) async {
    final directory = await appPath.mitmResourcesDirPath;
    final names = await Future.wait([
      for (final url in urls)
        () async {
          try {
            final bytes = (await request.getFileResponseForUrl(url)).data;
            if (bytes == null || bytes.length > maxMitmResourceSize) {
              throw const FileSystemException('too large');
            }
            final name = await _storeResource(url, bytes);
            held.add(name);
            return name;
          } catch (e) {
            commonPrint.log(
              'MITM resource $url: ${compactError(e)}',
              logLevel: LogLevel.warning,
            );
            final name = previous[url];
            if (name == null) {
              return null;
            }
            held.add(name);
            _held.add(name);
            return await File(join(directory, name)).exists() ? name : null;
          }
        }(),
    ]);
    return {for (final (index, url) in urls.indexed) url: ?names[index]};
  }

  Future<Map<String, String>> _writeInline(
    Map<String, String> sources,
    List<String> held,
  ) async {
    final written = <String, String>{};
    for (final MapEntry(:key, :value) in sources.entries) {
      final name = await _storeResource(key, utf8.encode(value));
      held.add(name);
      written[key] = name;
    }
    return written;
  }

  Future<String> _storeResource(String source, List<int> bytes) async {
    final name = mitmResourceName(source, bytes);
    _held.add(name);
    final file = File(join(await appPath.mitmResourcesDirPath, name));
    if (!await file.exists()) {
      await file.safeWriteAsBytes(bytes);
    }
    return name;
  }

  /// Removes every file no module names, judged file by file so that what a
  /// save writes or names while it runs stays.
  Future<void> clean() => _oneDeletionAtATime(_sweep);

  Future<void> _sweep() async {
    final stored = await database.mitmModulesDao.query().get();
    Future<void> sweep(
      String path,
      Iterable<String> Function(MitmModule module) namesOf,
    ) async {
      final directory = Directory(path);
      if (!await directory.exists()) {
        return;
      }
      await for (final entity in directory.list()) {
        if (entity is! File || !ref.mounted) {
          continue;
        }
        // writeAsStringAtomically writes a held file through `<name>.<pid>.tmp`.
        final name = basename(
          entity.path,
        ).replaceFirst(RegExp(r'\.\d+\.tmp$'), '');
        final modules = [...stored, ...?ref.read(mitmModulesProvider).value];
        if (!_held.contains(name) &&
            !modules.any((module) => namesOf(module).contains(name))) {
          await entity.safeDelete();
        }
      }
    }

    await sweep(
      await appPath.mitmModulesDirPath,
      (module) => [module.fileName],
    );
    await sweep(
      await appPath.mitmResourcesDirPath,
      (module) => module.resources.values,
    );
  }

  /// Remote modules follow the resources' two settings. What a restore leaves
  /// out, the content of remote modules and every downloaded resource, comes
  /// back even with auto update off.
  Future<void> autoUpdate() async {
    final setting = ref.read(patchClashConfigProvider);
    if (_autoUpdating || !ref.mounted || !(rsFeature && setting.mitm.enable)) {
      return;
    }
    _autoUpdating = true;
    try {
      final interval = Duration(hours: setting.geoUpdateInterval);
      final resourcesDir = await appPath.mitmResourcesDirPath;
      for (final module in await database.mitmModulesDao.query().get()) {
        final missing =
            !await File(await _pathOf(module)).exists() ||
            !(await Future.wait([
              for (final name in module.resources.values)
                File(join(resourcesDir, name)).exists(),
            ])).every((exists) => exists);
        final due =
            setting.geoAutoUpdate &&
            module.isRemote &&
            module.lastUpdateTime.add(interval).isBeforeNow;
        if (!due && !missing) {
          continue;
        }
        if (!ref.mounted) {
          return;
        }
        if (!module.isRemote && !await File(await _pathOf(module)).exists()) {
          continue;
        }
        try {
          await updateModule(module);
        } catch (e) {
          commonPrint.log(
            'auto update ${module.name}: ${compactError(e)}',
            logLevel: LogLevel.warning,
          );
        }
      }
    } finally {
      _autoUpdating = false;
    }
  }
}
