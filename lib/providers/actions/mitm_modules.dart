part of '../action.dart';

MitmModuleContent _parseMitmModule((String, Map<String, String>) source) =>
    parseMitmModule(source.$1, values: source.$2);

bool _bringsNewScripts(
  ({
    String before,
    Map<String, String> resourcesBefore,
    String after,
    Map<String, String> resourcesAfter,
    Map<String, String> values,
  })
  source,
) {
  return mitmScriptScope(
        source.after,
        values: source.values,
        resources: source.resourcesAfter,
      )
      .difference(
        mitmScriptScope(
          source.before,
          values: source.values,
          resources: source.resourcesBefore,
        ),
      )
      .isNotEmpty;
}

@Riverpod(keepAlive: true)
class MitmModulesAction extends _$MitmModulesAction {
  var _autoUpdating = false;

  /// Files written before a row or a line names them, which [clean] keeps.
  final _held = <String>[];

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

  /// Downloads the resources of the lines the new values bring in, which the
  /// last save did not see. Returns the module if the values turned it off by
  /// declaring more scripts than the user accepted.
  Future<MitmModule?> setArguments(
    MitmModule module,
    Map<String, String> arguments,
  ) async {
    putModule(module.copyWith(arguments: arguments));
    final held = <String>[];
    MitmModule? turnedOff;
    try {
      final text = await File(await _pathOf(module)).readAsString();
      final content = await compute(_parseMitmModule, (text, arguments));
      if (ref.mounted &&
          module.enabled &&
          content.declaredScripts > module.scripts) {
        turnedOff = (await _current(
          module.id,
        ))?.copyWith(enabled: false, scripts: content.declaredScripts);
        if (turnedOff != null && ref.mounted) {
          putModule(turnedOff);
        }
      }
      final missing = content.resourceUrls.difference({
        ...module.resources.keys,
      });
      if (missing.isEmpty || !ref.mounted) {
        return turnedOff;
      }
      final fetched = await _download(missing, previous: const {}, held: held);
      final current = await _current(module.id);
      if (fetched.isNotEmpty && current != null && ref.mounted) {
        final saved = current.copyWith(
          resources: {...current.resources, ...fetched},
        );
        putModule(saved);
        turnedOff = turnedOff == null ? null : saved;
      }
      return turnedOff;
    } on FileSystemException catch (e) {
      commonPrint.log(
        'MITM module ${module.name}: ${compactError(e)}',
        logLevel: LogLevel.warning,
      );
      return turnedOff;
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
    await File(await _pathOf(module)).safeDelete();
    await clean();
  }

  Future<String> _pathOf(MitmModule module) async {
    return join(await appPath.mitmModulesDirPath, module.fileName);
  }

  Future<MitmModule?> _current(int id) async => (await ref.read(
    mitmModulesProvider.future,
  )).where((item) => item.id == id).firstOrNull;

  /// A module [added] with scripts starts off until the user accepts them, and
  /// one an update brings new or changed scripts to turns off until they accept
  /// again; with no earlier text, as after a restore, only the count can tell.
  /// What the user changed while it downloaded stays.
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
      final previous = added || edited ? null : await _readText(module);
      final resources = await _download(
        content.resourceUrls,
        previous: module.resources,
        held: held,
      );
      await File(await _pathOf(module)).writeAsStringAtomically(text);
      if (!ref.mounted) {
        return module;
      }
      final current = added ? module : await _current(module.id);
      if (current == null || !ref.mounted) {
        return module;
      }
      final merged = {...mitmAttachments(current), ...resources};
      final bringsNew =
          previous != null &&
          current.enabled &&
          await compute(_bringsNewScripts, (
            before: previous,
            resourcesBefore: current.resources,
            after: text,
            resourcesAfter: merged,
            values: current.arguments,
          ));
      if (!ref.mounted) {
        return module;
      }
      final saved = current.copyWith(
        name: content.name ?? current.name,
        description: content.description ?? '',
        system: content.system,
        enabled: added
            ? content.declaredScripts == 0
            : current.enabled &&
                  !bringsNew &&
                  content.declaredScripts <= current.scripts,
        scripts: content.declaredScripts,
        resources: merged,
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

  Future<String?> _readText(MitmModule module) async {
    try {
      return await File(await _pathOf(module)).readAsString();
    } on FileSystemException {
      return null;
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
  Future<void> clean() async {
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
    if (!mitmFeature || _autoUpdating || !ref.mounted || !setting.mitm.enable) {
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
          final updated = await updateModule(module);
          if (module.enabled && !updated.enabled) {
            dialogs.showBanner(
              currentAppLocalizations.mitmModuleScriptsChanged(updated.name),
              level: BannerLevel.warning,
            );
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
