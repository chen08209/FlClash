// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/widgets.dart';

const appName = 'FlClash';

/// What the system shows for the installed package, as the packaging files
/// name it.
const packageDisplayName = rsSideBySide ? 'FlClash RS' : appName;

/// Keeps registrations and backups apart from a FlClash install beside it:
/// the autostart entry, whose Windows Run value the installer reads under
/// [packageDisplayName] (value names ignore case), and the WebDAV backup root.
const sideBySideName = rsSideBySide ? 'FlClash rs' : appName;
const _appSlug = rsSideBySide ? 'flclash-rs' : 'flclash';

/// The status card's glow while su is granted stays off until the card shows
/// something that needs root again.
const suAccessGlowShown = false;

/// Kept on every line: subscription servers match it in the User-Agent and
/// the Helper accepts a Core socket only under a directory of this name.
const productName = 'FlClash';
const appHelperService = 'FlClashHelperService';
const helperServiceName = rsSideBySide
    ? 'FlClashRsHelperService'
    : 'FlClashHelperService';
const coreManifestName = 'manifest.json';
const browserUa =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
const packageName = 'com.follow.clash';
final unixSocketPath = _privateSocketPath();
final windowsPipeName = '\\\\.\\pipe\\FlClashCore_${_randomId()}';
const helperPort = 47890;
const helperPortKey =
    'SYSTEM\\CurrentControlSet\\Services\\$helperServiceName\\Runtime';
const helperPortValue = 'Port';
const helperSocketPath = '/run/$_appSlug/helper.sock';
const helperUnitPath = '/etc/systemd/system/$_appSlug-helper.service';
const linuxUrlHandlerDesktopId = '$_appSlug-url-handler.desktop';
const helperProtocolVersionHeader = 'x-flclash-helper-protocol';
final helperProtocolVersion = Platform.isWindows ? '9' : '7';
const maxTextScale = 1.4;
const minTextScale = 0.8;

const watchExecution = false;

const safeModeBuild = bool.fromEnvironment('SAFE_MODE');

/// Gates what only the Concord core of the rs line can serve, such as MITM.
/// The rs line strips each check with `tool/strip_rs_feature.dart` instead of
/// turning it on, so a check must take a form that tool reads.
const rsFeature = false;

/// Native and packaging files cannot read this;
/// `test/tool/side_by_side_identity_test.dart` lists each and both its values.
const rsSideBySide = true;

const disclaimerVersion = 1;

String _privateSocketPath() {
  final runtime = Platform.environment['XDG_RUNTIME_DIR'];
  final String base;
  if (Platform.isLinux) {
    base = runtime != null && RegExp(r'^/run/user/\d{1,10}$').hasMatch(runtime)
        ? runtime
        : '/tmp';
  } else {
    base = runtime == null || runtime.isEmpty
        ? Directory.systemTemp.path
        : runtime;
  }
  return '$base/$productName/${_randomId()}.sock';
}

String _randomId() {
  final random = Random.secure();
  return List.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

/// Depends on [context]'s text scaler, so the caller rebuilds when the system
/// font scale changes.
double systemTextScaleOf(BuildContext context) {
  MediaQuery.textScalerOf(context);
  return WidgetsBinding.instance.platformDispatcher.textScaleFactor;
}

/// How long, in milliseconds, the Core may spend on one manual delay test. It
/// spends this twice in the worst case - once queueing for a slot, once on the
/// probe itself - so the guard below has to outlast twice the longest option.
const delayTestTimeoutOptions = [500, 1000, 2000, 5000, 8000];

const defaultDelayTestTimeout = 8000;

const delayTestGuardDuration = Duration(seconds: 30);

const delayTimedOutValue = -1;

const probeTimeoutDuration = Duration(seconds: 10);

/// The window a checked move opens, whose later moves are checked together
/// when it ends. Outlasts the Core's one-second pick poll, so groups
/// re-picking on neighbouring polls cost one route check more.
const probeSettleDuration = Duration(milliseconds: 1500);

/// Spans a config load, whose providers, rule sets and url-test picks land
/// over a few seconds, so an exit moving with each costs one probe more.
const probeThrottleDuration = Duration(seconds: 5);

/// Covers a burst of resets: a network switch reports more than once, and a
/// launch applies the config and starts the listeners back to back.
const probeMoveSettleDuration = Duration(milliseconds: 300);

/// How long after a failure that came back early a watched probe target is
/// asked the once more that confirms it.
const probeConfirmDelay = Duration(seconds: 1);

const downloadTimeoutDuration = Duration(seconds: 20);

/// A healthy source answers within a second; past this the outbound is down.
const outboundIpTimeoutDuration = Duration(seconds: 6);

/// The Core may spend a method's own timeout twice, once queueing for a probe
/// slot and once on the request, before the transport is considered
/// unresponsive. [budgetFactor] covers methods that spend it more than once.
Duration coreGuardFor(int timeout, {int budgetFactor = 2}) =>
    Duration(milliseconds: timeout * budgetFactor) + const Duration(seconds: 5);

/// Kept in step with the Core's service sweep budget.
const serviceSweepBudgetFactor = 6;

/// The width of one `delay.run`.
const maxConcurrentDelayTests = 32;
const maxConcurrentImports = 4;
const maxConcurrentIconLoads = 8;

/// The largest well an app's icon fills: a desktop detail header's.
const appIconExtent = 52.0;

const renderThrottleDuration = Duration(milliseconds: 300);
const defaultUpdateDuration = Duration(days: 1);
const MMDB = 'GEOIP.metadb';
const ASN = 'ASN.mmdb';
const GEOSITE = 'GEOSITE.dat';

final double kHeaderHeight = getWindowHeaderHeight(
  isDesktop: system.isDesktop,
  isMacOS: system.isMacOS,
);
const profilesDirectoryName = 'profiles';
const providersDirectoryName = 'providers';
const proxiesProviderDirectoryName = 'proxies';
const rulesProviderDirectoryName = 'rules';

/// The Core reads the CA here, and map-local files only from [mitmResourcesDirectoryName].
const mitmDirectoryName = 'mitm';
const mitmModulesDirectoryName = 'modules';
const mitmResourcesDirectoryName = 'resources';

const localhost = '127.0.0.1';
const clashConfigKey = 'clash_config';
const configKey = 'config';
const systemDnsRecordKey = 'system_dns_record';
const bootRecordKey = 'boot_record';
const appliedConfigMd5Key = 'applied_config_md5';
const hostCredentialKey = 'host_credential';
const repository = 'chen08209/FlClash';
const maxMobileWidth = 600;
const maxLaptopWidth = 840;
const defaultTestUrl = 'https://www.gstatic.com/generate_204';

const shareLinkSchemes = {
  'hysteria',
  'hysteria2',
  'hy2',
  'hysteria2+realm',
  'hy2+realm',
  'tuic',
  'trojan',
  'vless',
  'vmess',
  'ss',
  'ssr',
  'socks',
  'socks5',
  'socks5h',
  'anytls',
  'mierus',
};

const stringListEquality = ListEquality<String>();
const intListEquality = ListEquality<int>();
const ruleListEquality = ListEquality<Rule>();
const scriptListEquality = ListEquality<Script>();
const mitmModuleListEquality = ListEquality<MitmModule>();
const profileListEquality = ListEquality<Profile>();
const proxyGroupsEquality = ListEquality<ProxyGroup>();
const customProxiesEquality = ListEquality<CustomProxy>();
const clashProviderListEquality = ListEquality<ClashProvider>();
const iconSetListEquality = ListEquality<IconSet>();
const hotKeyActionListEquality = ListEquality<HotKeyAction>();
const stringAndStringMapEntryListEquality =
    ListEquality<MapEntry<String, String>>();
const keyboardModifierListEquality = SetEquality<KeyboardModifier>();

const proxiesListStoreKey = PageStorageKey<String>('proxies_list');
const toolsStoreKey = PageStorageKey<String>('tools');
const profilesStoreKey = PageStorageKey<String>('profiles');

const defaultPrimaryColor = 0xFF007AFF;

const maxLogsLength = 5000;
const maxRequestsLength = 2000;
const maxDnsQueriesLength = 3000;
const pausedMaxLogsLength = maxLogsLength * 2;
const pausedMaxDnsQueriesLength = maxDnsQueriesLength * 2;

const trafficSampleLength = 30;

// iOS 27's system colors but the deeper blue of earlier iOS, in the order of the
// macOS accent colors.
const defaultPrimaryColors = [
  defaultPrimaryColor,
  0xFFCB30E0,
  0xFFFF2D55,
  0xFFFF383C,
  0xFFFF8D28,
  0xFFFFCC00,
  0xFF34C759,
  0xFF8E8E93,
];

const scriptTemplate = '''
const main = (config) => {
  return config;
}''';

const backupDatabaseName = 'database.sqlite';
const configJsonName = 'config.json';
