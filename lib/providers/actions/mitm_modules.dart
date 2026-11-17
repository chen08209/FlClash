part of '../action.dart';

@Riverpod(keepAlive: true)
class MitmModulesAction extends _$MitmModulesAction {
  var _autoUpdating = false;

  /// Files written before a row or a line names them, which [clean] keeps.
  final _held = <String>[];
  final _refreshes = <int, Object>{};

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

  Future<MitmModule> updateModule(MitmModule module) =>
      _refresh(module, module.url);

  /// The module keeps its old URL when the new one fails to download.
  Future<MitmModule> changeUrl(MitmModule module, String url) =>
      _refresh(module, url);

  Future<MitmModule> _refresh(MitmModule module, String? url) async {
    final updatingKeys = ref.read(updatingKeysProvider.notifier);
    final operation = updatingKeys.start(module.updatingKey);
    final token = _refreshes[module.id] = Object();
    bool superseded() => _refreshes[module.id] != token;
    try {
      if (url == null) {
        return await _save(
          module,
          await File(await _pathOf(module)).readAsString(),
          superseded: superseded,
        );
      }
      final response = await request.getTextResponseForUrl(url);
      return await _save(
        module,
        response.data ?? '',
        url: url,
        superseded: superseded,
      );
    } finally {
      if (!superseded()) {
        _refreshes.remove(module.id);
      }
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
      MitmModule checked;
      try {
        checked = _withContent(module, await _read(module, module.arguments));
      } catch (_) {
        checked = module.copyWith(asksConsent: true);
      }
      if (!ref.mounted) {
        return;
      }
      if (checked != module) {
        putModule(checked);
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
    return changed;
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
        final replaced = mitmAttachments(current)[fileName];
        if (replaced != null && replaced != name) {
          await _oneDeletionAtATime(() => _dropAttachments([replaced]));
        }
      }
    } finally {
      _held.remove(name);
    }
  }

  Future<void> fetchResources(MitmModule module) async {
    await ref
        .read(coreHandlerProvider)
        .api
        .fetchMitmModule(name: '${module.id}');
    if (ref.mounted) {
      ref.invalidate(mitmModuleStatusProvider);
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
    final stored = mitmAttachments(current)[fileName];
    if (stored != null) {
      await _oneDeletionAtATime(() => _dropAttachments([stored]));
    }
  }

  Future<void> deleteModule(MitmModule module) async {
    ref.read(mitmModulesProvider.notifier).del(module.id);
    final path = await _pathOf(module);
    await _oneDeletionAtATime(() async {
      await File(path).safeDelete();
      await _dropAttachments(mitmAttachments(module).values);
    });
  }

  Future<void> _dropAttachments(Iterable<String> names) async {
    final directory = await appPath.mitmResourcesDirPath;
    final modules = [
      ...await database.mitmModulesDao.query().get(),
      ...?ref.read(mitmModulesProvider).value,
    ];
    for (final name in names) {
      if (!_held.contains(name) &&
          !modules.any(
            (module) => mitmAttachments(module).containsValue(name),
          )) {
        await File(join(directory, name)).safeDelete();
      }
    }
  }

  Future<void> _oneDeletionAtATime(Future<void> Function() delete) =>
      _deleting = _deleting.then((_) {}, onError: (_) {}).then((_) => delete());

  Future<String> _pathOf(MitmModule module) async {
    return join(await appPath.mitmModulesDirPath, module.fileName);
  }

  Future<MitmModuleDetails> _read(
    MitmModule module,
    Map<String, String> arguments,
  ) => readMitmModule(ref, module, arguments: arguments);

  Future<MitmModule?> _current(int id) async => (await ref.read(
    mitmModulesProvider.future,
  )).where((item) => item.id == id).firstOrNull;

  Future<MitmModule> _save(
    MitmModule module,
    String text, {
    bool added = false,
    bool first = false,
    bool edited = false,
    String? url,
    bool Function()? superseded,
  }) async {
    final content = await readMitmModule(ref, module, text: text);
    if (superseded?.call() ?? false) {
      return await _current(module.id) ?? module;
    }
    if (content.isEmpty && !edited) {
      throw MessageException(currentAppLocalizations.mitmModuleInvalid);
    }
    _held.add(module.fileName);
    try {
      await File(await _pathOf(module)).writeAsStringAtomically(text);
      if (!ref.mounted) {
        return module;
      }
      final current = added ? module : await _current(module.id);
      if (current == null || !ref.mounted) {
        return module;
      }
      // Consent covers what the old URL served; a module that is off asks
      // again when it is turned on anyway.
      final moved = url != null && url != current.url && current.enabled;
      final saved =
          _withContent(
            moved ? current.copyWith(accepted: null) : current,
            content,
          ).copyWith(
            url: url ?? current.url,
            name: content.read.meta.name ?? current.name,
            description: content.read.meta.desc ?? '',
            system: content.read.meta.system,
            resources: {
              ...mitmAttachments(current),
              for (final resource in content.read.resources)
                resource.url: ?current.resources[resource.url],
            },
            lastUpdateTime: DateTime.now(),
          );
      putModule(saved, first: first);
      return saved;
    } finally {
      _held.remove(module.fileName);
      if (ref.mounted) {
        unawaited(_cleanAfterSave());
      }
    }
  }

  MitmModule _withContent(MitmModule current, MitmModuleDetails content) {
    final next = current.copyWith(
      scripts: content.read.declaredScripts.length,
      asksConsent: content.read.asksConsent,
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

  Future<String> _storeResource(String source, List<int> bytes) async {
    final name = mitmResourceName(source, bytes);
    _held.add(name);
    final file = File(join(await appPath.mitmResourcesDirPath, name));
    if (!await file.exists()) {
      await file.safeWriteAsBytes(bytes);
    }
    return name;
  }

  /// Removes every module file no module names, judged file by file so that what a
  /// save writes or names while it runs stays.
  Future<void> clean() => _oneDeletionAtATime(_sweep);

  Future<void> _sweep() async {
    final directory = Directory(await appPath.mitmModulesDirPath);
    if (!await directory.exists()) {
      return;
    }
    final stored = await database.mitmModulesDao.query().get();
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
          !modules.any((module) => module.fileName == name)) {
        await entity.safeDelete();
      }
    }
  }

  Future<void> autoUpdate() async {
    final setting = ref.read(patchClashConfigProvider);
    if (_autoUpdating || !ref.mounted || !setting.mitm.enable) {
      return;
    }
    _autoUpdating = true;
    try {
      final interval = Duration(hours: setting.geoUpdateInterval);
      for (final module in await database.mitmModulesDao.query().get()) {
        final missing = !await File(await _pathOf(module)).exists();
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
        if (!module.isRemote && missing) {
          continue;
        }
        try {
          final updated = await updateModule(module);
          if (due && updated.enabled) {
            await fetchResources(updated);
          }
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
