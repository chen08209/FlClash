import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:path/path.dart';
import 'package:webdav_client/webdav_client.dart';

class DAVClient {
  late Client client;
  Completer<bool> pingCompleter = Completer();

  DAVClient(DAV dav) {
    client = newClient(
      dav.uri,
      user: dav.user,
      password: dav.password,
    );
    client.setHeaders(
      {
        'accept-charset': 'utf-8',
        'Content-Type': 'text/xml',
      },
    );
    client.setConnectTimeout(8000);
    client.setSendTimeout(8000);
    client.setReceiveTimeout(8000);
    pingCompleter.complete(_ping());
  }

  Future<bool> _ping() async {
    try {
      await client.ping();
      await client.mkdir("/$appName");
      await client.mkdir("/$appName/$profilesDirectoryName");
      return true;
    } catch (_) {
      return false;
    }
  }

  get root => "/$appName";

  get remoteConfig => "$root/$configKey.json";

  get remoteClashConfig => "$root/$clashConfigKey.json";

  get remoteProfiles => "$root/$profilesDirectoryName";

  backup() async {
    final appController = globalState.appController;
    final config = appController.config;
    final clashConfig = appController.clashConfig;
    await client.mkdir("$root");
    client.write(
      remoteConfig,
      utf8.encode(
        json.encode(config.toJson()),
      ),
    );
    client.write(
      remoteClashConfig,
      utf8.encode(
        json.encode(clashConfig.toJson()),
      ),
    );
    await client.remove(remoteProfiles);
    for (final profile in config.profiles) {
      final path = await appPath.getProfilePath(profile.id);
      if (path == null) continue;
      await client.writeFromFile(
        path,
        "$remoteProfiles/${basename(path)}",
      );
    }
    return true;
  }

  recovery({required RecoveryOption recoveryOption}) async {
    final profiles = await client.readDir(remoteProfiles);
    final profilesPath = await appPath.getProfilesPath();
    for (final file in profiles) {
      await client.read2File(
        "$remoteProfiles/${file.name}",
        join(
          profilesPath,
          file.name,
        ),
      );
    }
    final configRaw = utf8.decode((await client.read(remoteConfig)));
    final clashConfigRaw = utf8.decode(await client.read(remoteClashConfig));
    final config = Config.fromJson(json.decode(configRaw));
    final clashConfig = ClashConfig.fromJson(json.decode(clashConfigRaw));
    if(recoveryOption == RecoveryOption.onlyProfiles){
      globalState.appController.config.update(config, RecoveryOption.onlyProfiles);
    }else{
      globalState.appController.config.update(config, RecoveryOption.all);
      globalState.appController.clashConfig.update(clashConfig);
    }
    await globalState.appController.applyProfile();
    globalState.appController.savePreferences();
    return true;
  }
}
