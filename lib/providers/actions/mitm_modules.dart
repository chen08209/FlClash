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

  Future<void> recordConsent(
    int id, {
    required bool asksConsent,
    bool? agreed,
  }) async {
    final current = await _current(id);
    if (!ref.mounted || current == null) {
      return;
    }
    putModule(
      current.copyWith(
        asksConsent: asksConsent,
        enabled: agreed ?? true,
        accepted: agreed ?? current.accepted,
      ),
    );
  }

  /// Turning a module off counts as declining it until it is turned on.
  Future<void> turnOff(int id) async {
    final current = await _current(id);
    if (ref.mounted && current != null) {
      putModule(
        current.copyWith(enabled: false, accepted: current.accepted ?? false),
      );
    }
  }

  /// A restored row may have been judged against another device's files.
  Future<void> recheckConsent() async {
    for (final module in await database.mitmModulesDao.query().get()) {
      bool asksConsent;
      try {
        asksConsent = (await _read(module, module.arguments)).asksConsent;
      } catch (_) {
        asksConsent = true;
      }
      if (!ref.mounted) {
        return;
      }
      if (asksConsent != module.asksConsent) {
        putModule(module.copyWith(asksConsent: asksConsent));
      }
    }
  }

  /// Null once the module is gone; a module file that cannot be read throws.
  Future<MitmModule?> setArguments(
    MitmModule module,
    Map<String, String> arguments,
  ) async {
    final content = await _read(module, arguments);
    final current = await _current(module.id);
    if (!ref.mounted || current == null) {
      return current;
    }
    final changed = _withContent(
      current.copyWith(arguments: arguments),
      content,
    );
    putModule(changed);
    final held = <String>[];
    try {
      final missing = content.resourceUrls.difference({
        ...changed.resources.keys,
      });
      final fetched = missing.isEmpty || !ref.mounted
          ? const <String, String>{}
          : await _download(missing, previous: const {}, held: held);
      final written = await _writeInline({
        for (final MapEntry(:key, :value) in content.inlineResources.entries)
          if (!changed.resources.containsKey(key)) key: value,
      }, held);
      if (fetched.isEmpty && written.isEmpty) {
        return changed;
      }
      final latest = await _current(module.id);
      if (!ref.mounted || latest == null) {
        return latest;
      }
      final withResources = latest.copyWith(
        resources: {...latest.resources, ...fetched, ...written},
      );
      putModule(withResources);
      return withResources;
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

  Future<MitmModuleContent> _read(
    MitmModule module,
    Map<String, String> arguments,
  ) async {
    final text = await File(await _pathOf(module)).readAsString();
    return compute(_parseMitmModule, (text, arguments));
  }

  Future<MitmModule?> _current(int id) async => (await ref.read(
    mitmModulesProvider.future,
  )).where((item) => item.id == id).firstOrNull;

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
      await File(await _pathOf(module)).writeAsStringAtomically(text);
      if (!ref.mounted) {
        return module;
      }
      final current = added ? module : await _current(module.id);
      if (current == null || !ref.mounted) {
        return module;
      }
      final saved = _withContent(current, content).copyWith(
        name: content.name ?? current.name,
        description: content.description ?? '',
        system: content.system,
        resources: {...mitmAttachments(current), ...resources, ...written},
        lastUpdateTime: DateTime.now(),
      );
      putModule(saved, first: first);
      return saved;
    } finally {
      held.forEach(_held.remove);
      if (ref.mounted) {
        unawaited(_cleanAfterSave());
      }
    }
  }

  MitmModule _withContent(MitmModule current, MitmModuleContent content) {
    final next = current.copyWith(
      scripts: content.declaredScripts,
      asksConsent: content.asksConsent,
    );
    if (!current.enabled ||
        current.accepted == true ||
        !next.asksBeforeTurningOn) {
      return next;
    }
    return next.copyWith(enabled: false, accepted: null);
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
