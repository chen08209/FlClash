import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'reconcile.dart';

String _digest(Uint8List bytes) => sha256.convert(bytes).toString();

class YamlConflict {
  const YamlConflict(this.name, this.local, this.remote);

  final String name;
  final String local;
  final String remote;
}

class ICloudYamlSync extends ChangeNotifier {
  static const _channel = MethodChannel('flclash/icloud');
  static const _stateKey = 'icloudYamlSync';
  static const _maxBytes = 16 * 1024 * 1024;

  Timer? _timer;
  bool _stopped = false;
  int _generation = 0;
  bool busy = false;
  String? folder;
  Object? error;
  final Map<String, YamlConflict> conflicts = {};
  final Map<String, String> _bases = {};
  final Map<String, int> _ids = {};
  final Set<String> _missing = {};
  late List<Profile> Function() _profiles;
  late Future<String?> Function(Uint8List) _validate;
  late void Function(Profile) _put;
  late void Function() _changed;
  SharedPreferences? _preferences;

  Set<String> get missing => Set.unmodifiable(_missing);

  Future<void> start({
    required List<Profile> Function() profiles,
    required Future<String?> Function(Uint8List) validate,
    required void Function(Profile) put,
    required void Function() changed,
  }) async {
    final generation = ++_generation;
    _stopped = false;
    busy = true;
    _timer?.cancel();
    _bases.clear();
    _ids.clear();
    conflicts.clear();
    _missing.clear();
    _profiles = profiles;
    _validate = validate;
    _put = put;
    _changed = changed;
    try {
      _preferences = await SharedPreferences.getInstance();
      final selected = await _channel.invokeMethod<String>('folder');
      if (generation != _generation) return;
      folder = selected;
      final raw = _preferences!.getString(_stateKey);
      if (raw != null) {
        final state = jsonDecode(raw) as Map<String, dynamic>;
        if (state['folder'] == folder) {
          _bases.addAll(Map<String, String>.from(state['bases'] as Map));
          _ids.addAll(Map<String, int>.from(state['ids'] as Map));
        }
      }
    } catch (e) {
      error = e;
    }
    if (generation != _generation) return;
    busy = false;
    if (_stopped) return;
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(sync()),
    );
    notifyListeners();
    await sync();
  }

  Future<void> selectFolder() async {
    if (busy || _preferences == null) return;
    busy = true;
    notifyListeners();
    try {
      final selected = await _channel.invokeMethod<String>('select');
      if (selected != null && selected != folder) {
        folder = selected;
        _bases.clear();
        _ids.clear();
        conflicts.clear();
        _missing.clear();
        await _save();
      }
      error = null;
    } catch (e) {
      error = e;
    } finally {
      busy = false;
      if (!_stopped) notifyListeners();
    }
    await sync();
  }

  Future<void> disable() async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      await _channel.invokeMethod<void>('disable');
      folder = null;
      conflicts.clear();
      _missing.clear();
      _bases.clear();
      _ids.clear();
      await _save();
      error = null;
    } catch (e) {
      error = e;
    } finally {
      busy = false;
      if (!_stopped) notifyListeners();
    }
  }

  Future<void> _save() async {
    final saved = await _preferences!.setString(
      _stateKey,
      jsonEncode({'folder': folder, 'bases': _bases, 'ids': _ids}),
    );
    if (!saved) throw const FileSystemException('Could not save sync state');
  }

  Future<Uint8List?> _readLocal(Profile? profile) async {
    if (profile == null) return null;
    final file = File(await appPath.getProfilePath(profile.id.toString()));
    if (!await file.exists()) return null;
    if (await file.length() > _maxBytes) {
      throw const FileSystemException('YAML file exceeds 16 MiB');
    }
    return file.readAsBytes();
  }

  Future<String?> _hash(Uint8List? bytes) async =>
      bytes == null ? null : compute(_digest, bytes);

  Future<void> sync({YamlConflict? resolve, bool useLocal = false}) async {
    if (_stopped || busy || folder == null || _preferences == null) return;
    final generation = _generation;
    bool active() => !_stopped && generation == _generation;
    busy = true;
    error = null;
    notifyListeners();
    try {
      final names = await _channel.invokeListMethod<String>('list');
      if (!active()) return;
      if (names == null) {
        throw const FileSystemException('iCloud folder unavailable');
      }
      final profiles = {
        for (final profile in _profiles())
          if (profile.type != ProfileType.custom &&
              profile.ageSecretKey.isEmpty)
            profile.id: profile,
      };
      for (final profile in profiles.values) {
        if (!_ids.containsValue(profile.id)) {
          final name = profile.fileName;
          if (_ids.containsKey(name)) continue;
          _ids[name] = profile.id;
        }
      }
      final allNames = {...names, ..._ids.keys};
      conflicts.removeWhere((name, _) => !allNames.contains(name));
      _missing.clear();
      for (final name in allNames) {
        if (!active()) return;
        try {
          final profile = profiles[_ids[name]];
          final local = await _readLocal(profile);
          final remote = await _channel.invokeMethod<Uint8List>('read', {
            'name': name,
          });
          final localHash = await _hash(local);
          final remoteHash = await _hash(remote);
          var decision = reconcileYaml(
            base: _bases[name],
            local: localHash,
            remote: remoteHash,
          );
          if (resolve != null &&
              resolve.name == name &&
              resolve.local == localHash &&
              resolve.remote == remoteHash) {
            decision = useLocal ? SyncDecision.upload : SyncDecision.download;
          }
          if (!active()) return;
          conflicts.remove(name);
          switch (decision) {
            case SyncDecision.unchanged:
              if (localHash != null) _bases[name] = localHash;
            case SyncDecision.conflict:
              conflicts[name] = YamlConflict(name, localHash!, remoteHash!);
            case SyncDecision.missing:
              _missing.add(name);
            case SyncDecision.upload:
              if (await _hash(await _readLocal(profile)) != localHash) continue;
              if (!active()) return;
              await _channel.invokeMethod<void>('write', {
                'name': name,
                'bytes': local!,
                'expected': remote,
              });
              if (!active()) return;
              _bases[name] = localHash!;
            case SyncDecision.download:
              if (remote == null) continue;
              final issue = await _validate(remote);
              if (issue != null) throw MessageException(issue);
              if (!active()) return;
              // Re-check after validation; a dialog or core RPC may have yielded to an editor.
              final latest = _profiles()
                  .where((item) => item.id == profile?.id)
                  .firstOrNull;
              if (profile != null && latest == null) continue;
              if (await _hash(await _readLocal(latest)) != localHash) continue;
              final updated =
                  latest ??
                  Profile.normal(label: p.basenameWithoutExtension(name));
              final path = await appPath.getProfilePath(updated.id.toString());
              if (!active()) return;
              final target = File(path);
              if (latest == null && await target.exists()) continue;
              await target.parent.create(recursive: true);
              final staged = File('$path.icloud.tmp');
              try {
                await staged.writeAsBytes(remote, flush: true);
                final before = await target.stat();
                final current = await _hash(await _readLocal(latest));
                if (current != localHash || !active()) continue;
                final after = target.statSync();
                if (before.modified != after.modified ||
                    before.size != after.size ||
                    before.type != after.type) {
                  continue;
                }
                staged.renameSync(path);
              } finally {
                if (await staged.exists()) await staged.delete();
              }
              if (!active()) return;
              _ids[name] = updated.id;
              _put(updated.copyWith(lastUpdateDate: DateTime.now()));
              _changed();
              _bases[name] = remoteHash!;
          }
          await _save();
        } catch (e) {
          error = e;
        }
      }
    } catch (e) {
      error = e;
    } finally {
      if (active()) {
        busy = false;
        notifyListeners();
      }
    }
  }

  void stop() {
    _generation++;
    _stopped = true;
    _timer?.cancel();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

final iCloudYamlSync = ICloudYamlSync();
