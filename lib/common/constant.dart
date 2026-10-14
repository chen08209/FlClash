// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:material_ui/material_ui.dart';

const appName = 'FlClash';
const appHelperService = 'FlClashHelperService';
const coreManifestName = 'manifest.json';
const coreName = 'clash.meta';
const browserUa =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
const packageName = 'com.follow.clash';
final unixSocketPath = '/tmp/FlClashSocket_${Random().nextInt(10000)}.sock';
final windowsPipeName = '\\\\.\\pipe\\FlClashCore_${_randomPipeId()}';
const helperPort = 47890;
const helperPortKey =
    'SYSTEM\\CurrentControlSet\\Services\\$appHelperService\\Runtime';
const helperPortValue = 'Port';
const helperSocketPath = '/run/flclash/helper.sock';
const helperProtocolVersionHeader = 'x-flclash-helper-protocol';
final helperProtocolVersion = Platform.isWindows ? '8' : '6';
const maxTextScale = 1.4;
const minTextScale = 0.8;
final baseInfoEdgeInsets = EdgeInsets.symmetric(
  vertical: 16.mAp,
  horizontal: 16.mAp,
);
final listHeaderPadding = EdgeInsets.only(
  left: 16.mAp,
  right: 16.mAp,
  top: 24.mAp,
  bottom: 8.mAp,
);

const listRowMinHeight = 56.0;
const listRowVerticalPadding = 10.0;
const pageToolbarHeight = 64.0;
const sheetToolbarHeight = 48.0;
const sheetAppBarHeight = 68.0;

const watchExecution = false;

const safeModeBuild = bool.fromEnvironment('SAFE_MODE');

const disclaimerVersion = 1;

String _randomPipeId() {
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

/// How long the Core may spend on one delay test. It spends this twice in the
/// worst case - once queueing for a slot, once on the probe itself - so the
/// guard below has to outlast twice this value.
const delayTestTimeoutDuration = Duration(seconds: 8);

const delayTestGuardDuration = Duration(seconds: 30);

const delayTimedOutValue = -1;

const probeTimeoutDuration = Duration(seconds: 10);

const downloadTimeoutDuration = Duration(seconds: 20);

/// A healthy source answers within a second; past this the outbound is down.
const outboundIpTimeoutDuration = Duration(seconds: 6);

/// The Core may spend a method's own timeout twice, once queueing for a probe
/// slot and once on the request, before the transport is considered
/// unresponsive. [budgetFactor] covers methods that spend it more than once.
Duration coreGuardFor(int timeout, {int budgetFactor = 2}) =>
    Duration(milliseconds: timeout * budgetFactor) + const Duration(seconds: 5);

Duration probeGuardDuration(ProbeParams params) => coreGuardFor(params.timeout);

/// Kept in step with serviceSweepBudgetFactor in core/service_check.go.
const serviceSweepBudgetFactor = 6;

const coreConnectionWaitDuration = Duration(seconds: 10);

/// Keep at or below the Core's delay-test concurrency (`delayTestConcurrency`
/// in core/delay.go).
const maxConcurrentDelayTests = 32;
const maxConcurrentImports = 4;
const maxConcurrentIconLoads = 8;
const animateDuration = Duration(milliseconds: 100);
const midDuration = Duration(milliseconds: 200);
const commonDuration = Duration(milliseconds: 300);

const renderThrottleDuration = Duration(milliseconds: 300);
const defaultUpdateDuration = Duration(days: 1);
const MMDB = 'GEOIP.metadb';
const ASN = 'ASN.mmdb';
const GEOIP = 'GEOIP.dat';
const GEOSITE = 'GEOSITE.dat';

/// The macOS sidebar material is the finished look; the Windows accent
/// effects need a tint over them to keep the rail readable.
final double kSidebarBlurOpacity = system.isMacOS ? 0 : 0.5;
final double kHeaderHeight = getWindowHeaderHeight(
  isDesktop: system.isDesktop,
  isMacOS: system.isMacOS,
);
const profilesDirectoryName = 'profiles';
const providersDirectoryName = 'providers';
const proxiesProviderDirectoryName = 'proxies';
const rulesProviderDirectoryName = 'rules';

const localhost = '127.0.0.1';
const clashConfigKey = 'clash_config';
const configKey = 'config';
const systemDnsRecordKey = 'system_dns_record';
const bootRecordKey = 'boot_record';
const defaultSystemDnsFallback = '223.5.5.5';
const double dialogCommonWidth = 300;
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

const defaultPrimaryColor = 0XFFD8C0C3;

const maxLogsLength = 5000;
const maxRequestsLength = 2000;
const maxDnsQueriesLength = 3000;
const pausedMaxLogsLength = maxLogsLength * 2;
const pausedMaxRequestsLength = maxRequestsLength * 2;
const pausedMaxDnsQueriesLength = maxDnsQueriesLength * 2;

const trafficSampleLength = 30;

const defaultPrimaryColors = [
  0xFF795548,
  0xFF03A9F4,
  0xFFFFFF00,
  0XFFBBC9CC,
  0XFFABD397,
  defaultPrimaryColor,
  0XFF665390,
];

const scriptTemplate = '''
const main = (config) => {
  return config;
}''';

const backupDatabaseName = 'database.sqlite';
const configJsonName = 'config.json';
