// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get rule => 'Rule';

  @override
  String get rules => 'Rules';

  @override
  String get global => 'Global';

  @override
  String get direct => 'Direct';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get proxies => 'Proxies';

  @override
  String get profile => 'Profile';

  @override
  String get profiles => 'Profiles';

  @override
  String get tools => 'Tools';

  @override
  String get logs => 'Logs';

  @override
  String get resources => 'Resources';

  @override
  String get trafficUsage => 'Traffic usage';

  @override
  String get networkSpeed => 'Network speed';

  @override
  String get outboundMode => 'Outbound mode';

  @override
  String get serviceStatus => 'Service status';

  @override
  String get serviceRestricted => 'Access restricted';

  @override
  String get serviceAvailable => 'Available';

  @override
  String get serviceUnavailable => 'Unavailable';

  @override
  String get serviceFailed => 'Check failed';

  @override
  String get serviceDisallowedIsp => 'Disallowed ISP';

  @override
  String get serviceBlocked => 'Blocked';

  @override
  String get serviceUnsupportedRegion => 'Region not supported';

  @override
  String get serviceOriginalsOnly => 'Originals only';

  @override
  String get serviceComingSoon => 'Coming soon';

  @override
  String get servicePending => 'Not checked';

  @override
  String get serviceManage => 'Manage services';

  @override
  String get serviceCheckAll => 'Check all';

  @override
  String get upload => 'Upload';

  @override
  String get download => 'Download';

  @override
  String get usedTraffic => 'Used traffic';

  @override
  String get totalTraffic => 'Total traffic';

  @override
  String get expireTime => 'Expiration time';

  @override
  String get nullProfileDesc => 'Add a profile to get started';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get defaultText => 'Default';

  @override
  String get more => 'More';

  @override
  String get other => 'Other';

  @override
  String get about => 'About';

  @override
  String get en => 'English';

  @override
  String get es => 'Spanish';

  @override
  String get fr => 'French';

  @override
  String get ja => 'Japanese';

  @override
  String get ko => 'Korean';

  @override
  String get ru => 'Russian';

  @override
  String get zhCN => 'Simplified Chinese';

  @override
  String get theme => 'Theme';

  @override
  String get extend => 'Extend';

  @override
  String get runtimeConfig => 'Runtime config';

  @override
  String get allowLan => 'Allow LAN';

  @override
  String get tun => 'TUN';

  @override
  String get tunDesc => 'TUN works only in administrator mode.';

  @override
  String get minimizeOnExit => 'Minimize on exit';

  @override
  String get autoLaunch => 'Auto launch';

  @override
  String get silentLaunch => 'Silent launch';

  @override
  String get autoRun => 'Auto run';

  @override
  String get autoRunDesc => 'Auto run starts the proxy when the app opens.';

  @override
  String get logcat => 'Logcat';

  @override
  String get logcatDesc => 'Turning off Logcat hides the logs entry.';

  @override
  String get autoCheckUpdate => 'Auto check for updates';

  @override
  String get checkCertificate => 'Verify TLS certificates';

  @override
  String get checkCertificateDesc =>
      'With TLS verification off, subscriptions and backups are open to man-in-the-middle attacks.';

  @override
  String get accessControl => 'Access control';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get update => 'Update';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get seconds => 'seconds';

  @override
  String get qrcode => 'QR code';

  @override
  String get qrcodeDesc => 'Scan a QR code to obtain a profile';

  @override
  String get url => 'URL';

  @override
  String get link => 'Link';

  @override
  String get file => 'File';

  @override
  String get name => 'Name';

  @override
  String get profileNameNullValidationDesc => 'Please enter the profile name';

  @override
  String get rename => 'Rename';

  @override
  String get profileUrlNullValidationDesc => 'Please enter the profile URL';

  @override
  String get profileUrlInvalidValidationDesc =>
      'Please enter a valid profile URL';

  @override
  String get autoUpdate => 'Auto update';

  @override
  String get autoUpdateInterval => 'Auto-update interval';

  @override
  String get profileAutoUpdateIntervalNullValidationDesc =>
      'Please enter the auto-update interval';

  @override
  String get profileAutoUpdateIntervalInvalidValidationDesc =>
      'Please enter a valid interval';

  @override
  String get themeMode => 'Theme mode';

  @override
  String get themeColor => 'Theme color';

  @override
  String get preview => 'Preview';

  @override
  String get auto => 'Auto';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get importFromLink => 'Import from link';

  @override
  String get sendFromPhone => 'Send from phone';

  @override
  String get sendFromPhoneTip =>
      'Scan the code with your phone\'s camera and paste the link on the page that opens. Both devices need to be on the same network.';

  @override
  String get sendFromPhoneNoNetwork =>
      'This device is not connected to a local network';

  @override
  String get sendFromPhonePermissionDenied =>
      'Receiving a link from your phone needs the Nearby devices permission, which lets FlClash reach the local network. Turn it on in the app\'s settings.';

  @override
  String get sendFromPhonePageTitle => 'Send a link to FlClash';

  @override
  String get sendFromPhonePageHint => 'Subscription link or proxy share link';

  @override
  String get send => 'Send';

  @override
  String get sendFromPhonePageSent =>
      'Sent. Confirm the import on the other device.';

  @override
  String get sendFromPhoneConfirmTitle => 'Import the link from your phone?';

  @override
  String get shareQrcodeTip =>
      'Scan with FlClash on another device to import this profile.';

  @override
  String get qrcodeTooLongTip =>
      'This link is too long for a QR code. Use Copy link instead.';

  @override
  String get submit => 'Submit';

  @override
  String createProfileFromUrlTip(Object url) {
    return 'Do you want to create a profile from $url?';
  }

  @override
  String get create => 'Create';

  @override
  String get pleaseUploadValidQrcode => 'Please upload a valid QR code';

  @override
  String get blacklistMode => 'Blacklist mode';

  @override
  String get whitelistMode => 'Whitelist mode';

  @override
  String get selectAll => 'Select all';

  @override
  String get cancelSelectAll => 'Deselect all';

  @override
  String get appAccessControl => 'App access control';

  @override
  String get accessControlAllowDesc => 'Only selected apps go through the VPN';

  @override
  String get accessControlNotAllowDesc =>
      'Selected apps are excluded from the VPN';

  @override
  String get accessControlDisabledDesc => 'App access control is disabled';

  @override
  String accessControlSelectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
    );
    return '$_temp0';
  }

  @override
  String get port => 'Port';

  @override
  String get logLevel => 'Log level';

  @override
  String get show => 'Show';

  @override
  String get exit => 'Exit';

  @override
  String get systemProxy => 'System proxy';

  @override
  String get safeMode => 'Safe mode';

  @override
  String safeModeAppTitle(Object appName) {
    return '$appName (Safe mode)';
  }

  @override
  String get project => 'Project';

  @override
  String get core => 'Core';

  @override
  String get tabAnimation => 'Tab animation';

  @override
  String get desc =>
      'A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.';

  @override
  String get startVpn => 'Starting VPN…';

  @override
  String get stopVpn => 'Stopping VPN…';

  @override
  String get localNetworkDeniedTip =>
      'Local network permission denied: using the gvisor stack, LAN is unreachable.';

  @override
  String get compatible => 'Compatibility mode';

  @override
  String get notSelectedTip => 'The current proxy group cannot be selected';

  @override
  String get changeProxyFailedTip =>
      'Failed to switch proxy; the previous selection has been restored';

  @override
  String get databaseWriteFailedTip =>
      'Failed to save the change; it has been rolled back';

  @override
  String get tip => 'Tip';

  @override
  String get account => 'Account';

  @override
  String get backup => 'Backup';

  @override
  String get backupSuccess => 'Backup successful';

  @override
  String get noInfo => 'No info';

  @override
  String get pleaseBindWebDAV => 'Please bind WebDAV';

  @override
  String get bind => 'Bind';

  @override
  String get connectivity => 'Connectivity: ';

  @override
  String get webDAVConfiguration => 'WebDAV configuration';

  @override
  String get address => 'Address';

  @override
  String get addressTip => 'Please enter a valid WebDAV address';

  @override
  String get password => 'Password';

  @override
  String get authentication => 'Authentication';

  @override
  String get authenticationSystemProxyDesc =>
      'The system proxy is not applied while authentication is on.';

  @override
  String get checkUpdate => 'Check for updates';

  @override
  String get discoverNewVersion => 'New version found';

  @override
  String get checkUpdateError => 'The app is already up to date';

  @override
  String get goDownload => 'Download';

  @override
  String get unknown => 'Unknown';

  @override
  String get country => 'Region';

  @override
  String get search => 'Search';

  @override
  String get allowBypass => 'Allow apps to bypass VPN';

  @override
  String get externalController => 'External controller';

  @override
  String get externalControllerDesc =>
      'The external controller lets you control the core on port 9090.';

  @override
  String get externalControllerSecret => 'External controller secret';

  @override
  String get ipv6Desc => 'IPv6 traffic is received only while IPv6 is on.';

  @override
  String get app => 'App';

  @override
  String get general => 'General';

  @override
  String get startupAndBackground => 'Startup and background';

  @override
  String get requestsAndUpdates => 'Requests and updates';

  @override
  String get logsAndDiagnostics => 'Logs and diagnostics';

  @override
  String get userAgent => 'User-Agent';

  @override
  String get unifiedDelay => 'Unified delay';

  @override
  String get tcpConcurrent => 'TCP concurrent';

  @override
  String get geodataLoader => 'Geo low-memory mode';

  @override
  String get requests => 'Requests';

  @override
  String get recentRequests => 'Recent requests';

  @override
  String get alwaysFindProcess => 'Always find process';

  @override
  String get init => 'Init';

  @override
  String get infiniteTime => 'Never expires';

  @override
  String get connections => 'Connections';

  @override
  String get liveConnections => 'Live connections';

  @override
  String get inbound => 'Inbound';

  @override
  String get intranetIP => 'Intranet IP';

  @override
  String get view => 'View';

  @override
  String get cut => 'Cut';

  @override
  String get copy => 'Copy';

  @override
  String get clipboardWriteFailed =>
      'Couldn\'t copy to the clipboard. The selection may be too large';

  @override
  String get paste => 'Paste';

  @override
  String get testUrl => 'Test URL';

  @override
  String get delayTestTimeout => 'Delay test timeout';

  @override
  String get sync => 'Sync';

  @override
  String get exclude => 'Hide from recent tasks';

  @override
  String get compact => 'Compact';

  @override
  String get tab => 'Tab';

  @override
  String get list => 'List';

  @override
  String get delay => 'Delay';

  @override
  String get style => 'Style';

  @override
  String get size => 'Size';

  @override
  String get sort => 'Sort';

  @override
  String get columns => 'Columns';

  @override
  String get proxyGroup => 'Proxy group';

  @override
  String get go => 'Go';

  @override
  String get externalLink => 'External link';

  @override
  String get otherContributors => 'Other contributors';

  @override
  String get appIconDesign => 'App icon design';

  @override
  String get autoCloseConnections => 'Auto close connections';

  @override
  String get onlyStatisticsProxy => 'Only count proxy traffic';

  @override
  String get showNotificationStopAction => 'Stop button in notification';

  @override
  String get pureBlackMode => 'Pure black mode';

  @override
  String get sidebar => 'Sidebar';

  @override
  String get backgroundBlur => 'Background blur';

  @override
  String get liquidGlass => 'Liquid Glass';

  @override
  String get keepAliveIntervalDesc => 'TCP keep-alive interval';

  @override
  String get entries => ' entries';

  @override
  String get local => 'Local';

  @override
  String get remote => 'Remote';

  @override
  String get mode => 'Mode';

  @override
  String get time => 'Time';

  @override
  String get source => 'Source';

  @override
  String get action => 'Action';

  @override
  String get intelligentSelected => 'Smart selection';

  @override
  String get clipboardImport => 'Import from clipboard';

  @override
  String get clipboardNoPackageNames =>
      'No package names found in the clipboard';

  @override
  String get clipboardExport => 'Export to clipboard';

  @override
  String get layout => 'Layout';

  @override
  String get tight => 'Tight';

  @override
  String get standard => 'Standard';

  @override
  String get ultra => 'Ultra';

  @override
  String get loose => 'Loose';

  @override
  String get profilesSort => 'Sort profiles';

  @override
  String get start => 'Start';

  @override
  String get runTime => 'Run time';

  @override
  String get stop => 'Stop';

  @override
  String get key => 'Key';

  @override
  String get value => 'Value';

  @override
  String get options => 'Options';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get loopback => 'UWP loopback exemption';

  @override
  String get providers => 'External resources';

  @override
  String get proxyProviders => 'Proxy providers';

  @override
  String get ruleProviders => 'Rule providers';

  @override
  String get providerUrlTip => 'Only remote providers are supported';

  @override
  String get ruleSetEmptyTip => 'The rule set has no usable entries';

  @override
  String get ruleSetMixedTip =>
      'The rule set mixes domains and IP ranges, so its type cannot be told';

  @override
  String get ruleSetInvalidTip => 'This mrs file cannot be read';

  @override
  String get subscriptionInfo => 'Subscription info';

  @override
  String get server => 'Server';

  @override
  String get ntpInterval => 'Sync interval (minutes)';

  @override
  String get dialerProxy => 'Dialer proxy';

  @override
  String get writeToSystem => 'Write to system';

  @override
  String get writeToSystemDesc =>
      'Write to system also sets the system clock; Android ignores it.';

  @override
  String get sniffer => 'Sniffer';

  @override
  String get overrideDestination => 'Override destination';

  @override
  String get forceDnsMapping => 'Force DNS mapping';

  @override
  String get forceDnsMappingDesc =>
      'Force DNS mapping also sniffs connections whose domain came from a DNS mapping.';

  @override
  String get parsePureIp => 'Parse pure IP';

  @override
  String get forceDomain => 'Force domains';

  @override
  String get forceDomainDesc =>
      'Force domains are sniffed too; other connections that already have a domain are left alone.';

  @override
  String get skipDomain => 'Skip domains';

  @override
  String get skipSrcAddress => 'Skip source addresses';

  @override
  String get skipDstAddress => 'Skip destination addresses';

  @override
  String get sniffProtocols => 'Protocols';

  @override
  String get ports => 'Ports';

  @override
  String get overrideEntries => 'Override entries';

  @override
  String get addOverrideEntry => 'Add override entry';

  @override
  String get dnsOverrideDesc =>
      'Entries added here replace the DNS of every URL and file profile; anything not added keeps the profile\'s own setting. Custom profiles set their DNS in their content.';

  @override
  String get settingEntries => 'settings';

  @override
  String get addSettingEntry => 'Add setting';

  @override
  String get profileSettingsDesc =>
      'Applies to this profile only; anything not added uses its default.';

  @override
  String get healthCheck => 'Health check';

  @override
  String get discardChanges => 'Discard the changes?';

  @override
  String get quickEdit => 'Quick edit';

  @override
  String get status => 'Status';

  @override
  String get statusDesc => 'With DNS off, the system DNS is used.';

  @override
  String get respectRules => 'Respect rules';

  @override
  String get respectRulesDesc =>
      'Respect rules routes DNS connections by the rules and needs a Proxy Server Nameserver.';

  @override
  String get dnsMode => 'DNS mode';

  @override
  String get fakeipRange => 'Fake-IP range';

  @override
  String get fakeipFilter => 'Fake-IP filter';

  @override
  String get useHosts => 'Use hosts';

  @override
  String get useSystemHosts => 'Use system hosts';

  @override
  String get fallbackFilter => 'Fallback filter';

  @override
  String get domain => 'Domain';

  @override
  String get listenRoutingMark => 'Listen routing mark';

  @override
  String get listenRoutingMarkDesc =>
      'Listen routing mark works only on Linux.';

  @override
  String get ipv6Timeout => 'IPv6 timeout (ms)';

  @override
  String get cacheAlgorithm => 'Cache algorithm';

  @override
  String get cacheMaxSize => 'Cache size';

  @override
  String get fakeipRange6 => 'Fake-IP range (IPv6)';

  @override
  String get fakeipFilterMode => 'Fake-IP filter mode';

  @override
  String get fakeipTtl => 'Fake-IP TTL';

  @override
  String get reset => 'Reset';

  @override
  String get actionView => 'Show/Hide';

  @override
  String get actionStart => 'Start/Stop';

  @override
  String get actionMode => 'Switch mode';

  @override
  String get actionProxy => 'System proxy';

  @override
  String get actionTun => 'TUN';

  @override
  String get actionRuleMode => 'Rule mode';

  @override
  String get actionGlobalMode => 'Global mode';

  @override
  String get actionDirectMode => 'Direct mode';

  @override
  String get actionDelayTest => 'Test all delays';

  @override
  String get actionUpdateProfiles => 'Update profiles';

  @override
  String get disclaimer => 'Disclaimer';

  @override
  String get disclaimerDesc =>
      'Before using FlClash (\"the Software\"), please read this statement carefully and make sure you understand it. Tapping \"Agree\" means you have read and understood what follows. If you do not want to continue, tap \"Exit\".';

  @override
  String get disclaimerSoftwareTitle => 'Nature of the software';

  @override
  String get disclaimerSoftwareContent =>
      'The Software is an open-source network proxy client built on the Clash.Meta (mihomo) core. It only provides local tooling such as configuration management, rule-based routing, and traffic forwarding.';

  @override
  String get disclaimerNoServiceStatement =>
      'The Software itself does not provide any proxy server, node, subscription, or network access service, and has no partnership, agency, or guarantee relationship with any provider of such services.';

  @override
  String get disclaimerUsageTitle => 'About use';

  @override
  String get disclaimerUsageContent =>
      'Any commercial activity anyone carries out with the Software, including paid distribution, bundled sales, or use as part of a commercial service, is unrelated to the Software\'s developers, who do not endorse, support, or guarantee it.\n\nYou are responsible for complying with the laws where you live, and you bear the consequences of any unlawful use of the Software.';

  @override
  String get disclaimerResponsibilityTitle => 'Your responsibility';

  @override
  String get disclaimerResponsibilityContent =>
      'You are responsible for making sure that using the Software is lawful where you live, and you alone bear the legal responsibility for everything you do with it and its consequences.\n\nThe subscriptions, nodes, and configurations you import are your own choice. Whether their source is lawful, their content is safe, and their service is reliable is a matter between you and their providers.';

  @override
  String get disclaimerThirdPartyTitle => 'Third-party content';

  @override
  String get disclaimerThirdPartyContent =>
      'Subscription links, configuration files, rule sets, scripts, external resources, and external links are all provided by third parties. The developers cannot and do not review or guarantee their legality, accuracy, security, or availability.\n\nAny data leak, financial loss, account ban, or other loss caused by third-party content is to be settled between you and the third party; the developers bear no responsibility for it.';

  @override
  String get disclaimerWarrantyTitle => 'No warranty';

  @override
  String get disclaimerWarrantyContent =>
      'The Software is provided \"as is\" and \"as available\", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, non-infringement, uninterrupted availability, freedom from errors, or freedom from security vulnerabilities.\n\nThe developers do not guarantee that the Software will meet your needs or that it will run without interruption or error.';

  @override
  String get disclaimerLiabilityTitle => 'Limitation of liability';

  @override
  String get disclaimerLiabilityContent =>
      'To the maximum extent permitted by applicable law, neither the developers nor any contributor shall be liable for any direct, indirect, incidental, special, punitive, or consequential damages arising from the use of or inability to use the Software, including but not limited to data loss, device damage, network failures, business interruption, lost profits, or any resulting legal dispute, even if advised of the possibility of such damages.';

  @override
  String get disclaimerPrivacyTitle => 'Data collection and privacy';

  @override
  String get disclaimerPrivacyContent =>
      'The Software does not collect or upload your subscription URLs, node details, configuration content, visited websites, connection records, traffic content, or logs. This data stays on your device and the developers have no access to it.\n\nThe Software only reaches the network when you use a feature that needs it, such as fetching the subscription URL you provided when updating a profile, or contacting GitHub when checking for updates.\n\nThe Software includes no analytics or crash reporting service on any platform.';

  @override
  String get disclaimerLicenseTitle => 'Open-source license';

  @override
  String get disclaimerLicenseContent =>
      'The Software is open source under the GPL-3.0 license. Under that license you may run, study, modify, and distribute it; when you distribute the Software or a modified version, you must provide its source code under GPL-3.0 as well and keep the original copyright notices.\n\nThird-party components in the Software, including the Clash.Meta core, follow their own licenses. The original authors are not responsible for any problem arising from versions modified or distributed by others.';

  @override
  String get disclaimerChangesTitle => 'Changes to this statement';

  @override
  String get disclaimerChangesContent =>
      'This statement may be revised in later releases; each release carries the version that applies to it.';

  @override
  String get disclaimerAcceptTitle => 'Relation to the open-source license';

  @override
  String get disclaimerAcceptContent =>
      'This statement explains the nature, risks, and responsibilities of using the Software. It is not an additional term beyond GPL-3.0 and does not limit any right that license grants you, including to run, copy, modify, and distribute the Software. Where the two differ, GPL-3.0 prevails.';

  @override
  String get disclaimerRestateTitle => 'Restate the statement';

  @override
  String get disclaimerRestateTip =>
      'To confirm you understand, enter the following statement in full in the field below:';

  @override
  String get disclaimerRestateHint => 'Enter the statement above';

  @override
  String get disclaimerRestateMismatch => 'Does not match the statement';

  @override
  String get disclaimerAcknowledgeTitle => 'Confirm the statement';

  @override
  String get disclaimerAcknowledgeTip =>
      'To confirm you understand, read the following statement and check the box below:';

  @override
  String get disclaimerAcknowledgeLabel =>
      'I have read and understand this statement';

  @override
  String get agree => 'Agree';

  @override
  String get hotkeyManagement => 'Hotkey management';

  @override
  String get hotkeyDesc =>
      'Global hotkeys work even while the window is hidden. Tap an action to record its key combination.';

  @override
  String get hotkeyNotSet => 'Not set';

  @override
  String get pressKeyboard => 'Press a key combination';

  @override
  String hotkeyNeedsModifier(Object modifiers) {
    return 'Include at least one of $modifiers';
  }

  @override
  String hotkeyConflictWith(Object action) {
    return 'Already used by “$action”. Saving moves it here.';
  }

  @override
  String get hotkeyUnavailable =>
      'Not registered, it may be taken by another app';

  @override
  String get remove => 'Remove';

  @override
  String get noNetwork => 'No network';

  @override
  String get exportLogs => 'Export logs';

  @override
  String get exportSuccess => 'Export successful';

  @override
  String get iconStyle => 'Icon style';

  @override
  String get iconStyleFilled => 'Filled';

  @override
  String get iconStylePlain => 'Plain';

  @override
  String get iconStyleHidden => 'Hidden';

  @override
  String get filter => 'Filter';

  @override
  String get groupBy => 'Group by';

  @override
  String get hideTimeoutProxies => 'Hide timed-out proxies';

  @override
  String get stackMode => 'Stack mode';

  @override
  String get network => 'Network';

  @override
  String get bypassDomain => 'Bypass domains';

  @override
  String get pacMode => 'PAC mode';

  @override
  String get pacScript => 'PAC script';

  @override
  String get bypassDomainDesc =>
      'Bypass domains apply only while the system proxy is on.';

  @override
  String get bypassLocalWindowsOnly => 'Windows only: host names without a dot';

  @override
  String get resetTip => 'Are you sure you want to reset?';

  @override
  String get icon => 'Icon';

  @override
  String get noData => 'No data';

  @override
  String get fontFamily => 'Font family';

  @override
  String get installedFonts => 'Installed fonts';

  @override
  String get toggle => 'Toggle';

  @override
  String get system => 'System';

  @override
  String get routeAddress => 'Route addresses';

  @override
  String get interfaceNameMode => 'Outbound interface';

  @override
  String get interfaceNameModeClear => 'Clear';

  @override
  String get interfaceNameModeFollow => 'Follow config';

  @override
  String get interfaceNameModeCustom => 'Custom';

  @override
  String get interfaceName => 'Interface name';

  @override
  String get copyEnvVar => 'Copy environment variables';

  @override
  String get memoryInfo => 'Memory info';

  @override
  String get total => 'Total';

  @override
  String get releaseMemory => 'Release memory';

  @override
  String get memoryCoreHeapInuse => 'Heap in use';

  @override
  String get memoryCoreHeapIdle => 'Heap idle';

  @override
  String get memoryCoreStack => 'Goroutine stacks';

  @override
  String get memoryCoreRuntime => 'Runtime overhead';

  @override
  String get memoryCoreNotRunning => 'Core is not running';

  @override
  String get memoryAppResident => 'Resident memory';

  @override
  String get memoryAppShared => 'App & shared';

  @override
  String get memoryEstimateDesc =>
      'Estimated from process resident memory; it may differ from what the system reports.';

  @override
  String get memoryEstimateSharedDesc =>
      'The Core runs inside the app process. Its share is estimated from runtime stats, and the rest counts as app and shared memory.';

  @override
  String get memoryReleased => 'Memory released';

  @override
  String memoryReleasedSize(Object size) {
    return 'Released $size';
  }

  @override
  String get releaseMemoryFailed => 'Failed to release memory';

  @override
  String get dialog => 'Dialog';

  @override
  String get cancel => 'Cancel';

  @override
  String get fileIsUpdate => 'The file has been modified. Save the changes?';

  @override
  String get profileHasUpdate =>
      'The profile has been modified. Turn off auto update?';

  @override
  String get hasCacheChange => 'Cache the changes?';

  @override
  String get copySuccess => 'Copied successfully';

  @override
  String get copyLink => 'Copy link';

  @override
  String get exportFile => 'Export file';

  @override
  String get cacheCorrupt => 'The cache is corrupted. Clear it?';

  @override
  String get detectionTip => 'Relies on a third-party API; for reference only';

  @override
  String get listen => 'Listen';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get lineWrap => 'Word wrap';

  @override
  String get none => 'None';

  @override
  String get advancedConfig => 'Advanced configuration';

  @override
  String get addRule => 'Add rule';

  @override
  String get content => 'Content';

  @override
  String get ruleTarget => 'Rule target';

  @override
  String get exitDefault => 'Default';

  @override
  String get customExit => 'Custom exit';

  @override
  String get inputExitName => 'Enter the exit name';

  @override
  String get scriptFailed => 'The script failed';

  @override
  String get sourceIp => 'Source IP';

  @override
  String get noResolve => 'Don\'t resolve IP';

  @override
  String get saveChanges => 'Save the changes?';

  @override
  String get applyNow => 'Apply now';

  @override
  String get applied => 'Applied';

  @override
  String get cannotSave => 'Can\'t save';

  @override
  String get navigationBarStyle => 'Bottom bar';

  @override
  String get floating => 'Floating';

  @override
  String get docked => 'Docked';

  @override
  String get slide => 'Slide';

  @override
  String get fade => 'Fade';

  @override
  String get pureBlack => 'Pure black';

  @override
  String get customColor => 'Custom color';

  @override
  String get colorStyle => 'Color style';

  @override
  String get grid => 'Grid';

  @override
  String get spectrum => 'Spectrum';

  @override
  String get sliders => 'Sliders';

  @override
  String get hue => 'Hue';

  @override
  String get saturation => 'Saturation';

  @override
  String get brightness => 'Brightness';

  @override
  String get hex => 'Hex';

  @override
  String get monochromeScheme => 'Monochrome';

  @override
  String get vividStyle => 'Vivid';

  @override
  String get tintedStyle => 'Tinted';

  @override
  String get softStyle => 'Soft';

  @override
  String get developerMode => 'Developer mode';

  @override
  String get developerModeEnableTip => 'Developer mode is enabled.';

  @override
  String get messageTest => 'Message test';

  @override
  String get messageTestTip => 'This is a message.';

  @override
  String get crashTest => 'Crash test';

  @override
  String get crashDetected => 'Crash detected';

  @override
  String crashDetectedTip(Object name) {
    return 'The app failed to finish launching twice in a row. To break the loop, the profile $name has been deselected and automatic setup was skipped. You can select it again at any time.';
  }

  @override
  String get launchInterrupted => 'Launch did not finish';

  @override
  String get launchInterruptedTip =>
      'The app exited unexpectedly while it was starting up last time. Automatic setup was skipped for this launch; you can start it manually to retry.';

  @override
  String get clearData => 'Clear data';

  @override
  String get textScale => 'Text scaling';

  @override
  String get textScalePreview => 'Text in the app will look like this';

  @override
  String get followSystem => 'Follow system';

  @override
  String get internet => 'Internet';

  @override
  String get systemApp => 'System apps';

  @override
  String get noNetworkApp => 'No-network apps';

  @override
  String get restoreStrategy => 'Restore strategy';

  @override
  String get restoreStrategyOverride => 'Override';

  @override
  String get restoreStrategyCompatible => 'Compatible';

  @override
  String get logsTest => 'Logs test';

  @override
  String emptyTip(Object label) {
    return '$label cannot be empty';
  }

  @override
  String urlTip(Object label) {
    return '$label must be a URL';
  }

  @override
  String get invalidLinkTip => 'Not a subscription link or a proxy share link';

  @override
  String numberTip(Object label) {
    return '$label must be a number';
  }

  @override
  String numberRangeTip(Object label, Object min, Object max) {
    return '$label must be between $min and $max';
  }

  @override
  String get interval => 'Interval';

  @override
  String existsTip(Object label) {
    return '$label already exists';
  }

  @override
  String maxLengthTip(Object label, Object max) {
    return '$label must be at most $max characters';
  }

  @override
  String get singleImport => 'Single import';

  @override
  String get batchImport => 'Batch import';

  @override
  String get batchUrlInputTip => 'One URL per line';

  @override
  String get batchLinkInputTip => 'One link per line';

  @override
  String batchPreviewTip(Object count, Object skipped) {
    return '$count to add, $skipped skipped as existing';
  }

  @override
  String lineIssueTip(Object line, Object message) {
    return 'Line $line: $message';
  }

  @override
  String singleValueTip(Object label) {
    return '$label must be a single item';
  }

  @override
  String deleteTip(Object label) {
    return 'Are you sure you want to delete this $label?';
  }

  @override
  String deleteMultipTip(Object label) {
    return 'Are you sure you want to delete the selected $label?';
  }

  @override
  String nullTip(Object label) {
    return 'No $label yet';
  }

  @override
  String get script => 'Script';

  @override
  String get color => 'Color';

  @override
  String get unnamed => 'Unnamed';

  @override
  String get pleaseEnterScriptName => 'Please enter a script name';

  @override
  String get mixedPort => 'Mixed port';

  @override
  String get socksPort => 'SOCKS port';

  @override
  String get redirPort => 'Redir port';

  @override
  String get tproxyPort => 'TProxy port';

  @override
  String portTip(Object label) {
    return '$label must be between 1024 and 49151';
  }

  @override
  String get portConflictTip => 'Please enter a different port';

  @override
  String get import => 'Import';

  @override
  String get importFile => 'Import from file';

  @override
  String get importUrl => 'Import from URL';

  @override
  String get startFromScratch => 'Start from scratch';

  @override
  String details(Object label) {
    return '$label details';
  }

  @override
  String get creationTime => 'Creation time';

  @override
  String get process => 'Process';

  @override
  String get host => 'Host';

  @override
  String get destination => 'Destination';

  @override
  String get destinationGeoIP => 'Destination GeoIP';

  @override
  String get destinationIPASN => 'Destination IP ASN';

  @override
  String get specialProxy => 'Special proxy';

  @override
  String get specialRules => 'Special rules';

  @override
  String get remoteDestination => 'Remote destination';

  @override
  String get networkType => 'Network type';

  @override
  String get proxyChains => 'Proxy chain';

  @override
  String get log => 'Log';

  @override
  String get connection => 'Connection';

  @override
  String get request => 'Request';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get connecting => 'Connecting…';

  @override
  String get restartCoreTip => 'Are you sure you want to restart the core?';

  @override
  String get forceRestartCoreTip =>
      'Are you sure you want to force restart the core?';

  @override
  String get dnsHijacking => 'DNS hijacking';

  @override
  String get coreStatus => 'Core status';

  @override
  String get appendSystemDns => 'Append system DNS';

  @override
  String get editRule => 'Edit rule';

  @override
  String get addedRules => 'Added rules';

  @override
  String get addedRulesAfterScript =>
      'Inserted after the script runs, ahead of the profile\'s rules';

  @override
  String get controlGlobalAddedRules => 'Control global added rules';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get rulePresetBlockQuic => 'Block QUIC';

  @override
  String get rulePresetBlockStun => 'Block STUN';

  @override
  String get rulePresetBlockDot => 'Block DNS over TLS';

  @override
  String get rulePresetBlockLoopback => 'Block proxy loopback';

  @override
  String get rulePresetSystemServicesDirect => 'Apple and Microsoft direct';

  @override
  String get rulePresetBittorrentDirect => 'BitTorrent direct';

  @override
  String get rulePresetLanDirect => 'LAN direct';

  @override
  String get extendScript => 'Extend script';

  @override
  String get goToConfigureScript => 'Go to script configuration';

  @override
  String get goToConfigureAddedRules => 'Go to added rules configuration';

  @override
  String get editGlobalRules => 'Edit global rules';

  @override
  String get confirmForceCrashCore =>
      'Are you sure you want to force crash the core?';

  @override
  String get confirmClearAllData => 'Are you sure you want to clear all data?';

  @override
  String get loading => 'Loading…';

  @override
  String yearsAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String monthsAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String minutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String get justNow => 'Just now';

  @override
  String yearsAgoShort(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}y ago',
    );
    return '$_temp0';
  }

  @override
  String monthsAgoShort(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}mo ago',
    );
    return '$_temp0';
  }

  @override
  String daysAgoShort(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}d ago',
    );
    return '$_temp0';
  }

  @override
  String hoursAgoShort(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}h ago',
    );
    return '$_temp0';
  }

  @override
  String minutesAgoShort(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}m ago',
    );
    return '$_temp0';
  }

  @override
  String get noLongerRemind => 'Don\'t remind me again';

  @override
  String get turnOn => 'Turn on';

  @override
  String get turnOff => 'Turn off';

  @override
  String get vpnConfigChangeDetected => 'VPN settings changed. Tap to restart';

  @override
  String get restart => 'Restart';

  @override
  String get speedStatistics => 'Speed statistics';

  @override
  String get resetPageChangesTip =>
      'This page has changes. Are you sure you want to reset?';

  @override
  String get customProfile => 'Custom';

  @override
  String get customResources => 'Custom';

  @override
  String get unknownNetworkError => 'Unknown network error';

  @override
  String get backupFromNewerVersion =>
      'This backup comes from a newer version of the app. Update the app before restoring it';

  @override
  String get networkTimeoutError =>
      'The request timed out. Check your network or proxy, then try again';

  @override
  String get networkHostLookupError =>
      'Couldn\'t resolve the server address. Check that the URL is correct and DNS is working';

  @override
  String get monochromeIcon => 'Monochrome icon';

  @override
  String get networkConnectionError =>
      'Couldn\'t connect to the server. Check your network connection or proxy settings';

  @override
  String get networkTlsError =>
      'Secure connection failed. The server\'s certificate may be invalid, or the connection is being intercepted';

  @override
  String get networkCancelledError => 'The request was cancelled';

  @override
  String networkAccessDeniedError(Object code) {
    return 'The server denied access (HTTP $code). The link may have expired, or the credentials are wrong';
  }

  @override
  String networkNotFoundError(Object code) {
    return 'Nothing was found at this address (HTTP $code). Check that the URL is correct';
  }

  @override
  String get networkRateLimitedError =>
      'Too many requests (HTTP 429). Wait a moment and try again';

  @override
  String networkServerError(Object code) {
    return 'The server ran into a problem (HTTP $code). Try again later';
  }

  @override
  String networkBadResponseError(Object code) {
    return 'The server rejected the request (HTTP $code)';
  }

  @override
  String networkRequestFailed(Object detail) {
    return 'Network request failed: $detail';
  }

  @override
  String get invalidBackupFile => 'Invalid backup file';

  @override
  String get pruneCache => 'Prune cache';

  @override
  String get backupAndRestore => 'Backup and restore';

  @override
  String get restore => 'Restore';

  @override
  String get restoreSuccess => 'Restore successful';

  @override
  String get restoreOnlyConfig => 'Restore profiles only';

  @override
  String get restoreAllData => 'Restore all data';

  @override
  String get addProfile => 'Add profile';

  @override
  String get delayTest => 'Delay test';

  @override
  String get proxyGroupEmpty => 'Proxy group is empty';

  @override
  String get confirmExitWindow =>
      'Are you sure you want to exit the current window?';

  @override
  String get optional => 'Optional';

  @override
  String get maxFailedTimes => 'Max failures';

  @override
  String get testInterval => 'Test interval';

  @override
  String get excludeFilter => 'Exclude filter';

  @override
  String get expectedStatus => 'Expected status';

  @override
  String get strategy => 'Strategy';

  @override
  String get tolerance => 'Tolerance';

  @override
  String get inputProxyGroupName => 'Enter the proxy group name';

  @override
  String get helperCorruptTip =>
      'Helper service unavailable; TUN mode cannot be enabled. Reinstall FlClash to restore it.';

  @override
  String get tunAuthorizationFailed =>
      'TUN could not be authorized, so it was turned off.';

  @override
  String get sudoPasswordTitle => 'Enter your password for sudo';

  @override
  String coreBlockedByPolicyTip(Object code) {
    return 'Windows refused to run FlClashCore.exe (error $code). An app control policy such as Smart App Control or AppLocker blocks unsigned programs; allow FlClash in that policy or turn it off, then try again.';
  }

  @override
  String get coreBlockedBySmartAppControlTip =>
      'Windows Smart App Control blocked FlClashCore.exe because it is not signed. Open Windows Security → App & browser control → Smart App Control settings, choose Off, then start FlClash again. Smart App Control cannot be turned back on without reinstalling Windows.';

  @override
  String get hideFromList => 'Hide from list';

  @override
  String get testWhenUsed => 'Test when used';

  @override
  String get disableUDP => 'Disable UDP';

  @override
  String get confirmDeleteProxyGroup =>
      'Are you sure you want to delete this proxy group?';

  @override
  String get ruleEmpty => 'Rule is empty';

  @override
  String get inputRuleContent => 'Enter the rule content';

  @override
  String get ruleSet => 'Rule set';

  @override
  String get selectRuleSet => 'Please select a rule set';

  @override
  String get splitStrategy => 'Split strategy';

  @override
  String get selectSplitStrategy => 'Please select a split strategy';

  @override
  String get noResolveHostname => 'Don\'t resolve hostname';

  @override
  String get matchSourceIp => 'Match source IP';

  @override
  String get basicInfo => 'Basic info';

  @override
  String get additionalParameters => 'Additional parameters';

  @override
  String get proxyType => 'Proxy type';

  @override
  String get basicStrategy => 'Basic strategies';

  @override
  String get editProxy => 'Edit proxy';

  @override
  String get addNodes => 'Add nodes';

  @override
  String get addProxyGroup => 'Add proxy group';

  @override
  String get editProxyGroup => 'Edit proxy group';

  @override
  String get iconUrl => 'Icon URL';

  @override
  String get iconRecords => 'Icon records';

  @override
  String get custom => 'Custom';

  @override
  String get ruleActionDomainDesc => 'Match the full domain';

  @override
  String get ruleActionDomainSuffixDesc => 'Match a domain suffix';

  @override
  String get ruleActionDomainKeywordDesc => 'Match a domain keyword';

  @override
  String get ruleActionDomainRegexDesc => 'Match a domain regex';

  @override
  String get ruleActionDomainWildcardDesc =>
      'Wildcard match; only * and ? are supported';

  @override
  String get ruleActionGeositeDesc => 'Match domains in Geosite';

  @override
  String get ruleActionIpCidrDesc => 'Match an IP address range';

  @override
  String get ruleActionIpCidr6Desc =>
      'Match an IP address range; IP-CIDR6 is just an alias';

  @override
  String get ruleActionIpSuffixDesc => 'Match an IP suffix range';

  @override
  String get ruleActionIpAsnDesc => 'Match the IP\'s ASN';

  @override
  String get ruleActionGeoipDesc => 'Match the IP\'s country code';

  @override
  String get ruleActionSrcGeoipDesc => 'Match the source IP\'s country code';

  @override
  String get ruleActionSrcIpAsnDesc => 'Match the source IP\'s ASN';

  @override
  String get ruleActionSrcIpCidrDesc => 'Match a source IP address range';

  @override
  String get ruleActionSrcIpSuffixDesc => 'Match a source IP suffix range';

  @override
  String get ruleActionDstPortDesc => 'Match the destination port range';

  @override
  String get ruleActionSrcPortDesc => 'Match the source port range';

  @override
  String get ruleActionInPortDesc => 'Match the inbound port';

  @override
  String get ruleActionInTypeDesc => 'Match the inbound type';

  @override
  String get ruleActionInUserDesc =>
      'Match the inbound username; separate multiple usernames with /';

  @override
  String get ruleActionInNameDesc => 'Match the inbound name';

  @override
  String get ruleActionRematchNameDesc =>
      'Match the rematch name; separate multiple names with /';

  @override
  String get ruleActionProcessPathDesc => 'Match by the full process path';

  @override
  String get ruleActionProcessPathRegexDesc => 'Match by process path regex';

  @override
  String get ruleActionProcessPathWildcardDesc =>
      'Match by process path wildcard; only * and ? are supported';

  @override
  String get ruleActionProcessNameDesc =>
      'Match by process name; matches the package name on Android';

  @override
  String get ruleActionProcessNameRegexDesc =>
      'Match by process name regex; matches the package name on Android';

  @override
  String get ruleActionProcessNameWildcardDesc =>
      'Match by process name wildcard; only * and ? are supported';

  @override
  String get ruleActionUidDesc => 'Match the Linux user ID';

  @override
  String get ruleActionNetworkDesc => 'Match TCP or UDP';

  @override
  String get ruleActionDscpDesc =>
      'Match the DSCP mark (tproxy UDP inbound only)';

  @override
  String get ruleActionRuleSetDesc =>
      'Reference a rule set; requires rule-providers';

  @override
  String get ruleActionAndDesc => 'Logical rule AND';

  @override
  String get ruleActionOrDesc => 'Logical rule OR';

  @override
  String get ruleActionNotDesc => 'Logical rule NOT';

  @override
  String get ruleActionSubRuleDesc =>
      'Match into a sub-rule; mind the parentheses';

  @override
  String get ruleActionMatchDesc => 'Match all requests, no conditions needed';

  @override
  String get contentNotEmpty => 'Content cannot be empty';

  @override
  String get splitStrategyNotEmpty => 'Split strategy cannot be empty';

  @override
  String get timeout => 'Timeout';

  @override
  String get delayFailed => 'Failed';

  @override
  String invalidSubRule(Object subRule) {
    return '$subRule is an invalid SUB_RULE';
  }

  @override
  String invalidPolicy(Object target) {
    return '$target is an invalid policy';
  }

  @override
  String invalidProxyProvider(Object providerName) {
    return '$providerName is an invalid proxy provider';
  }

  @override
  String invalidRuleSet(Object ruleSet) {
    return '$ruleSet is an invalid rule set';
  }

  @override
  String get invalidNetworkContent => 'Only tcp or udp is supported';

  @override
  String get invalidRangeContent =>
      'Enter numbers or ranges such as 80 or 8000-9000, separated by /';

  @override
  String get invalidDscpContent => 'A DSCP mark cannot exceed 63';

  @override
  String get invalidCidrContent =>
      'Enter an IP range in CIDR form such as 192.168.0.0/16';

  @override
  String get invalidPortRangeContent =>
      'Enter a port or a range such as 443 or 8000-9000';

  @override
  String get invalidHostContent => 'Enter a domain or an IP address';

  @override
  String get invalidListenContent =>
      'Enter an address and port such as 0.0.0.0:1053';

  @override
  String invalidProxy(Object proxyName) {
    return '$proxyName is an invalid proxy';
  }

  @override
  String get locationPermissionRequired => 'Location permission required';

  @override
  String locationPermissionGuide(Object appName) {
    return '1. Open System Settings > Privacy & Security\n2. Choose Location Services\n3. Find and check $appName in the list\n\nWhen you are done, return to the app to continue. Thank you for your cooperation.';
  }

  @override
  String get prerequisites => 'Prerequisites';

  @override
  String get ignoreBatteryOptimization => 'Ignore battery optimization';

  @override
  String get locationPermission => 'Location permission';

  @override
  String get locationPermissionDesc =>
      'The system requires location permission to read the Wi-Fi name. On Android choose \"Allow all the time\", otherwise the Wi-Fi name cannot be read while the app is in the background.';

  @override
  String get excludeSsids => 'Exclude SSIDs';

  @override
  String get excludeSsidsDesc =>
      'When connected to Wi-Fi with an excluded SSID, the app\'s running state switches automatically.';

  @override
  String get ssidsEmpty => 'SSIDs are empty';

  @override
  String get onDemand => 'On demand';

  @override
  String get locationPermissionDeniedMessage =>
      'Location permission was denied, so the current Wi-Fi name cannot be read. Please enable location permission manually in system settings.';

  @override
  String get addSsid => 'Add SSID';

  @override
  String get editSsid => 'Edit SSID';

  @override
  String get authorized => 'Authorized';

  @override
  String get tapToAuthorize => 'Tap to authorize';

  @override
  String get suspended => 'Suspended…';

  @override
  String get resourceUpdateInterval => 'Auto-update interval';

  @override
  String get resourceUpdateIntervalTip =>
      'The auto-update interval must be greater than 0';

  @override
  String get hours => 'hours';

  @override
  String get minutes => 'minutes';

  @override
  String get geoResources => 'Geo';

  @override
  String geoSkipped(Object name) {
    return '$name is already up to date';
  }

  @override
  String geoUpdated(Object name) {
    return '$name updated';
  }

  @override
  String secondsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String proxiesCount(num count, Object label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label proxies',
      one: '1 proxy',
    );
    return '$_temp0';
  }

  @override
  String rulesCount(num count, Object label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label rules',
      one: '1 rule',
    );
    return '$_temp0';
  }

  @override
  String proxyGroupsCount(num count, Object label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label proxy groups',
      one: '1 proxy group',
    );
    return '$_temp0';
  }

  @override
  String get changelogBreaking => 'Breaking changes';

  @override
  String get changelogFeatures => 'New features';

  @override
  String get changelogFixes => 'Bug fixes';

  @override
  String get changelogPerformance => 'Performance';

  @override
  String get changelogReverts => 'Reverts';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get minimize => 'Minimize';

  @override
  String get maximize => 'Maximize';

  @override
  String get unmaximize => 'Restore down';

  @override
  String get pinWindow => 'Pin window';

  @override
  String get unpinWindow => 'Unpin window';

  @override
  String get exitFullScreen => 'Exit full screen';

  @override
  String get torch => 'Flashlight';

  @override
  String get pickFromAlbum => 'Choose from album';

  @override
  String get closeConnections => 'Close connections';

  @override
  String get scrollToSelected => 'Scroll to selected';

  @override
  String get showMore => 'Expand';

  @override
  String get showLess => 'Collapse';

  @override
  String get previousMatch => 'Previous match';

  @override
  String get nextMatch => 'Next match';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noSearchResults => 'No matching results';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get authorize => 'Authorize';

  @override
  String get installedAppsPermissionRequired => 'App list permission required';

  @override
  String get installedAppsPermissionDesc =>
      'This system hides the installed app list until the permission is granted. Authorize it to configure the per-app proxy.';

  @override
  String get installedAppsPermissionDeniedMessage =>
      'The app list permission was denied, so installed apps cannot be listed. Please grant it manually in system settings.';

  @override
  String get outboundIp => 'Outbound IP';

  @override
  String get ipAddress => 'IP address';

  @override
  String get ipQualityLevel => 'Level';

  @override
  String get ipQualityGood => 'Good';

  @override
  String get ipQualityNormal => 'Normal';

  @override
  String get ipQualityRisky => 'Risky';

  @override
  String get ipType => 'Type';

  @override
  String get ipTypeResidential => 'Residential';

  @override
  String get ipTypeMobile => 'Mobile network';

  @override
  String get ipTypeBusiness => 'Business';

  @override
  String get ipTypeHosting => 'Data center';

  @override
  String get ipFlags => 'Flags';

  @override
  String get ipFlagProxy => 'Proxy';

  @override
  String get ipFlagVpn => 'VPN';

  @override
  String get ipFlagTor => 'Tor';

  @override
  String get ipFlagAbuser => 'Abuse history';

  @override
  String get ipOrganization => 'Organization';

  @override
  String get ipAsn => 'ASN';

  @override
  String get ipQualitySource => 'Answered by';

  @override
  String get ipQualitySources => 'Sources';

  @override
  String get ipQualityFailed => 'Couldn\'t determine the IP type';

  @override
  String get ipQualityRetry => 'Check again';

  @override
  String get ipSourceNoType => 'No type';

  @override
  String get ipSourceRateLimited => 'Rate limited';

  @override
  String get ipSourceIpMismatch => 'Different outbound IP';

  @override
  String get hideIp => 'Hide IP';

  @override
  String get editorUnavailable => 'Editor unavailable';

  @override
  String get replace => 'Replace';

  @override
  String get replaceAll => 'Replace all';

  @override
  String get cameraPermissionRequired => 'Camera permission required';

  @override
  String get cameraPermissionDesc =>
      'Allow camera access in system settings to scan QR codes, or choose a QR code image from the album.';

  @override
  String get cameraUnavailable => 'Camera unavailable';

  @override
  String get retry => 'Retry';

  @override
  String get invalidProfileQrcode =>
      'This QR code doesn\'t contain a profile link';

  @override
  String get dnsQueries => 'DNS queries';

  @override
  String get recordType => 'Record type';

  @override
  String get answers => 'Answers';

  @override
  String get responseCode => 'Response code';

  @override
  String get error => 'Error';

  @override
  String get initiator => 'Initiator';

  @override
  String get cache => 'Cache';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get nonTextProviderFile => 'This external resource is not a text file';

  @override
  String get addCustomProxy => 'Add proxy';

  @override
  String get definitionNotMap =>
      'The configuration must be a YAML mapping with a name and a type';

  @override
  String get ruleTextInvalid =>
      'The rule must start with a supported type, such as DOMAIN,example.com,DIRECT';

  @override
  String get ruleListInvalid =>
      'The rules must be a YAML list with one rule per item, such as - DOMAIN,example.com,DIRECT';

  @override
  String get shareLinksInvalid => 'No proxy could be read from the links';

  @override
  String shareLinkUnreadable(Object link) {
    return 'No proxy could be read from $link';
  }

  @override
  String proxiesProfileLabel(Object name, Object count) {
    return '$name and others ($count proxies)';
  }

  @override
  String get singleShareLinkOnly =>
      'Enter one link here; edit several from the quick edit of the list';

  @override
  String get username => 'Username';

  @override
  String get emptyFallback => 'Empty fallback';

  @override
  String get defaultSelected => 'Default selection';

  @override
  String get hashByInUser => 'Hash by inbound user';

  @override
  String get appProxiesEmpty => 'No local proxies';

  @override
  String get nodes => 'Nodes';

  @override
  String get localProxies => 'Local proxies';

  @override
  String get customIssueEmptyName => 'The name is empty';

  @override
  String customIssueReservedName(Object name) {
    return '$name is a built-in policy name and cannot be used here';
  }

  @override
  String customIssueDuplicateName(Object name) {
    return 'The name $name is already used by another proxy or proxy group';
  }

  @override
  String customIssueCoreRejected(Object message) {
    return 'The core cannot parse this proxy: $message';
  }

  @override
  String customIssueMissingProxies(Object names) {
    return 'These proxies or policies do not exist: $names';
  }

  @override
  String customIssueMissingProviders(Object names) {
    return 'These proxy providers do not exist: $names';
  }

  @override
  String get customIssueNoProxySource =>
      'No proxies or proxy providers are selected, so the core rejects this group';

  @override
  String customIssueGroupLoop(Object path) {
    return 'Proxy groups reference each other in a loop: $path';
  }

  @override
  String customIssueInvalidEmptyFallback(Object name) {
    return 'The empty fallback must be a proxy, but $name does not exist or is a proxy group';
  }

  @override
  String customIssueInvalidFilter(Object name, Object message) {
    return '$name is not a valid regex: $message';
  }

  @override
  String customIssueMissingDialer(Object name) {
    return 'The dialer proxy $name does not exist';
  }

  @override
  String customIssueDialerLoop(Object proxy, Object target) {
    return '$proxy dials through $target, which leads back to $proxy, so the dial loops';
  }

  @override
  String dialerProxyLoopStopped(Object name) {
    return 'Dialing through $name leads back to the proxy that uses it, so the connection was stopped';
  }

  @override
  String customIssuesSummary(Object count) {
    return '$count items have problems, and applying this profile may fail';
  }

  @override
  String providerInUse(Object label, Object profiles) {
    return '$label is still used by $profiles, which will not work properly once it is deleted. Are you sure you want to delete it?';
  }

  @override
  String proxyGroupInUse(Object label) {
    return '$label is still named by rules, proxy groups, dialer proxies, DNS or NTP in this profile, which stop working once it is deleted. Are you sure you want to delete it?';
  }

  @override
  String proxiesRemovedTip(Object removed) {
    return 'These proxies will be deleted: $removed. A line whose name changed counts as a new proxy, and custom profiles naming the deleted ones will flag them as missing. Apply anyway?';
  }

  @override
  String proxiesReplacedTip(Object removed, Object added) {
    return 'These proxies will be deleted: $removed. These will be added: $added. A line whose name changed counts as a new proxy, and custom profiles naming the deleted ones will flag them as missing. Apply anyway?';
  }

  @override
  String get fontSize => 'Size';

  @override
  String get large => 'Large';

  @override
  String get extraLarge => 'Extra large';

  @override
  String get switchProfile => 'Switch profile';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get filters => 'Filters';

  @override
  String get label => 'Label';

  @override
  String get regex => 'Regex';

  @override
  String get matchCase => 'Match case';

  @override
  String get iconSets => 'Icon sets';

  @override
  String get invalidIconSet => 'Not a valid icon set';

  @override
  String get recommendedIcons => 'Suggested';

  @override
  String get localImage => 'Local image';

  @override
  String get iconSetsEmptyTip =>
      'No icon sets yet. Add them in Custom profile resources → Icon sets';

  @override
  String get outbound => 'Outbound';

  @override
  String get strictRoute => 'Strict route';

  @override
  String get congestionController => 'TCP congestion control';

  @override
  String get congestionControllerDesc =>
      'TCP congestion control works only with the mips stack.';

  @override
  String get routeExcludeAddress => 'Route exclude addresses';

  @override
  String get keepAliveIdle => 'TCP keep-alive idle';

  @override
  String get disableKeepAlive => 'Disable TCP keep-alive';

  @override
  String get routingMark => 'Routing mark';

  @override
  String get strictRouteDesc =>
      'Strict route keeps traffic such as DNS from bypassing TUN, and with IPv6 off it blocks this device\'s IPv6 connections.';

  @override
  String get initFailed => 'Startup failed';

  @override
  String get initFailedTip =>
      'FlClash ran into an error while starting and can\'t continue. Copy the details to report the problem. If it keeps happening, clearing the data usually lets the app start again.';

  @override
  String get errorDetails => 'Error details';

  @override
  String get stackTrace => 'Stack trace';

  @override
  String get clearDataAndExitTip =>
      'This deletes all profiles, settings, and local data, then closes the app. Open it again to start fresh.';

  @override
  String clearDataFailed(Object detail) {
    return 'Couldn\'t clear the data: $detail';
  }

  @override
  String get bypassPrivateRoute => 'Bypass private addresses';

  @override
  String get disableIcmpForwarding => 'Disable ICMP forwarding';

  @override
  String get disableIcmpForwardingDesc =>
      'With ICMP forwarding disabled, TUN answers ping itself, so ping no longer shows the real latency.';

  @override
  String get excludeInterface => 'Excluded interfaces';

  @override
  String get includeInterface => 'Included interfaces';

  @override
  String get includeInterfaceDesc =>
      'Only traffic arriving on included interfaces goes through TUN, and excluded interfaces no longer apply.';

  @override
  String get includeUid => 'Included user IDs';

  @override
  String get excludeUid => 'Excluded user IDs';

  @override
  String get excludeSrcPort => 'Excluded source ports';

  @override
  String get excludeDstPort => 'Excluded destination ports';

  @override
  String get udpTimeout => 'UDP timeout';

  @override
  String get udpTimeoutDesc =>
      'The UDP timeout is in seconds and works only with the gvisor, system and mixed stacks.';

  @override
  String get dnsHijackDesc =>
      'Without this entry, TUN hijacks every DNS query to port 53 (any:53).';

  @override
  String get tunOverrideDesc =>
      'Entries added here replace the TUN settings of every profile; anything not added keeps the profile\'s own setting. Entries a custom profile adds itself take precedence.';

  @override
  String get generalOverrideDesc =>
      'Entries added here replace the setting of every profile; anything not added keeps the profile\'s own setting, or the core default when the profile has none.';

  @override
  String get profileTunSettingsDesc =>
      'Applies to this profile only and takes precedence over the TUN override entries in the network settings.';

  @override
  String settingsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count settings',
      one: '1 setting',
    );
    return '$_temp0';
  }

  @override
  String sectionsInEffect(Object count) {
    return '$count in effect';
  }

  @override
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get additionalPrefix => 'Name prefix';

  @override
  String get additionalSuffix => 'Name suffix';

  @override
  String get skipCertVerify => 'Skip certificate verification';

  @override
  String get ipVersion => 'IP version';

  @override
  String get addFilters => 'Add filters';

  @override
  String failedItem(Object label, Object message) {
    return '$label: $message';
  }

  @override
  String failedCount(Object count) {
    return '$count items failed. Tap to view';
  }

  @override
  String get importConfigInvalid =>
      'This file is not a config that can be imported';

  @override
  String get importConfigReplaceTip =>
      'Importing replaces the proxy groups, rules and settings this profile has now';

  @override
  String get networkName => 'Network name';

  @override
  String get networkSecret => 'Network secret';

  @override
  String get peers => 'Peers';

  @override
  String get virtualIpv4 => 'Virtual IPv4';

  @override
  String get hostname => 'Hostname';

  @override
  String get exitNodes => 'Exit nodes';

  @override
  String get cipher => 'Cipher';

  @override
  String get protocol => 'Protocol';

  @override
  String get protocolParam => 'Protocol parameter';

  @override
  String get obfs => 'Obfuscation';

  @override
  String get obfsParam => 'Obfuscation parameter';

  @override
  String get obfsPassword => 'Obfuscation password';

  @override
  String get obfsMode => 'Obfuscation mode';

  @override
  String get obfsHost => 'Obfuscation host';

  @override
  String get plugin => 'Plugin';

  @override
  String get pluginMode => 'Plugin mode';

  @override
  String get pluginHost => 'Plugin host';

  @override
  String get pluginPath => 'Plugin path';

  @override
  String get pluginUsername => 'Plugin username';

  @override
  String get pluginPassword => 'Plugin password';

  @override
  String get pluginCipher => 'Plugin cipher';

  @override
  String get privateKey => 'Private key';

  @override
  String get publicKey => 'Public key';

  @override
  String get privateKeyPassphrase => 'Private key passphrase';

  @override
  String get preSharedKey => 'Pre-shared key';

  @override
  String get secretKey => 'Key';

  @override
  String get transport => 'Transport';

  @override
  String get uploadBandwidth => 'Upload bandwidth';

  @override
  String get downloadBandwidth => 'Download bandwidth';

  @override
  String get protocolVersion => 'Protocol version';

  @override
  String get portHopping => 'Port hopping';

  @override
  String get hopInterval => 'Hop interval';

  @override
  String get congestionControl => 'Congestion control';

  @override
  String get udpRelayMode => 'UDP relay mode';

  @override
  String get allowedIps => 'Allowed IPs';

  @override
  String get remoteDnsResolve => 'Remote DNS resolution';

  @override
  String get clientFingerprint => 'Client fingerprint';

  @override
  String get requestHeaders => 'Request headers';

  @override
  String transportHeaders(Object transport) {
    return '$transport Headers';
  }

  @override
  String get required => 'Required';

  @override
  String get ageSecretKey => 'Age secret key';

  @override
  String get ageEncryptedProfile => 'Encrypted profile';

  @override
  String get ageSecretKeyRequiredTip =>
      'This profile is encrypted with age and needs an age secret key to decrypt';

  @override
  String get currentOutboundDesc =>
      'Holds the start button and can\'t be removed';

  @override
  String get running => 'Running';

  @override
  String get root => 'Root';

  @override
  String get notRunning => 'Not running';

  @override
  String trafficPeak(Object value) {
    return 'Peak $value';
  }

  @override
  String trafficTotal(Object value) {
    return 'Total $value';
  }

  @override
  String get ipQualityShort => 'Quality';

  @override
  String get ipTypeUnknown => 'Unknown type';

  @override
  String get tapIconToRetry => 'Tap the icon to retry';

  @override
  String get networkTakeover => 'Traffic takeover';

  @override
  String portValue(Object port) {
    return 'Port $port';
  }

  @override
  String serviceAbnormalCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count issues',
      one: '1 issue',
    );
    return '$_temp0';
  }

  @override
  String get serviceAllAvailable => 'All available';

  @override
  String get serviceShownOnDashboard => 'Shown on the dashboard';

  @override
  String groupTimeoutCount(Object count) {
    return '$count timed out';
  }

  @override
  String get groupCountUnit => 'groups';

  @override
  String groupCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groups',
      one: '1 group',
    );
    return '$_temp0';
  }

  @override
  String get proxyGroupsAfterStart =>
      'Groups show up here once the core starts';

  @override
  String get usedShort => 'used';

  @override
  String profileUpdatedAt(Object time) {
    return 'Updated $time';
  }

  @override
  String profileExpiresIn(Object date, num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Expires $date, $_temp0 left';
  }

  @override
  String profileDaysLeft(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get target => 'Target';

  @override
  String get outboundExit => 'Exit';

  @override
  String get duration => 'Duration';

  @override
  String get traffic => 'Traffic';

  @override
  String get totalDownload => 'Downloaded';

  @override
  String get totalUpload => 'Uploaded';

  @override
  String get initiatorShort => 'From';

  @override
  String get result => 'Result';

  @override
  String get elapsed => 'Took';

  @override
  String get connectionStats => 'Connection stats';

  @override
  String get connectionStatsDesc =>
      'Live connections, recent requests and DNS queries';

  @override
  String get memoryInfoDesc => 'Memory the app and the core use';

  @override
  String get editDashboard => 'Edit dashboard';

  @override
  String get done => 'Done';

  @override
  String get dashboardAddableSection => 'Available to add';

  @override
  String customImportDroppedSubRules(num count, Object label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$label SUB-RULE rules were dropped, since custom profiles do not support sub-rules',
      one:
          '1 SUB-RULE rule was dropped, since custom profiles do not support sub-rules',
    );
    return '$_temp0';
  }

  @override
  String get autoInclude => 'Auto-include';

  @override
  String get allReferencedProxies => 'All referenced proxies';

  @override
  String get allReferencedProxyProviders => 'All referenced proxy providers';

  @override
  String get clearDnsCache => 'Clear DNS cache';

  @override
  String get dnsCacheCleared => 'DNS cache cleared';

  @override
  String get clearDnsCacheFailed => 'Failed to clear DNS cache';

  @override
  String get select => 'Select';

  @override
  String get preferred => 'Preferred';

  @override
  String get addToLocalProxies => 'Add to local proxies';

  @override
  String addedToLocalProxies(Object name) {
    return 'Added $name to local proxies';
  }

  @override
  String alreadyInLocalProxies(Object name) {
    return '$name is already in local proxies';
  }

  @override
  String get mitm => 'MITM';

  @override
  String get httpsDecryption => 'HTTPS decryption';

  @override
  String get httpCapture => 'HTTP capture';

  @override
  String get httpCaptureDesc =>
      'Records requests to the hosts listed under Hostname, to view in connection details. Records stay in memory only.';

  @override
  String get httpCaptureNoHosts =>
      'No host is listed, so nothing is recorded. Add hosts under Hostname on the MITM page, or from the details of a connection.';

  @override
  String get httpCaptureLimit => 'Maximum records';

  @override
  String httpCaptureLimitDesc(Object memory, Object body) {
    return 'The oldest records go first once this many are kept or they fill $memory of memory. Each body keeps its first $body.';
  }

  @override
  String get httpRequests => 'HTTP requests';

  @override
  String get httpRequestsMissing =>
      'Requests made before capture was on, or since cleared, are not listed.';

  @override
  String get httpRequestCleared => 'This request is no longer kept';

  @override
  String get httpCaptureOff => 'Capture is off';

  @override
  String get inProgress => 'In progress';

  @override
  String get method => 'Method';

  @override
  String get originalUrl => 'Original URL';

  @override
  String get timeToFirstByte => 'Time to first byte';

  @override
  String get requestBody => 'Request body';

  @override
  String get response => 'Response';

  @override
  String get responseBody => 'Response body';

  @override
  String get responseHeaders => 'Response headers';

  @override
  String get matchedRules => 'Matched rules';

  @override
  String get overview => 'Overview';

  @override
  String get viewAll => 'View all';

  @override
  String get copyAsBase64 => 'Copy as Base64';

  @override
  String get copyAsCurl => 'Copy as cURL';

  @override
  String get closeConnection => 'Close connection';

  @override
  String get copyHost => 'Copy host';

  @override
  String get copyDestination => 'Copy destination';

  @override
  String get copyRequest => 'Copy request';

  @override
  String get copyResponse => 'Copy response';

  @override
  String get copyResponseBody => 'Copy response body';

  @override
  String get httpBodyProtobufGuess =>
      'Read as Protobuf without its schema: field numbers only, and the types are guesses.';

  @override
  String get exportHar => 'Export HAR';

  @override
  String get mitmAddRejectRule => 'Add a reject rule';

  @override
  String get mitmAddMapLocalRule => 'Add a map local rule';

  @override
  String get httpExportPrivateTitle => 'Contains private data';

  @override
  String get httpExportPrivate =>
      'A request can carry cookies, tokens, passwords and form contents. Check what you share, and with whom.';

  @override
  String get mitmRuleCopiedForStash =>
      'This module is a Stash override, so the rule was copied for you to add by hand.';

  @override
  String get binaryData => 'Binary data';

  @override
  String get httpBodyNotKept => 'Not recorded while memory was short.';

  @override
  String get httpBodyTruncated => 'Only the start of this body was recorded.';

  @override
  String httpBodyUndecoded(Object encoding) {
    return 'Could not decode $encoding, so this is the data as it was sent.';
  }

  @override
  String get mitmEnableTip =>
      'FlClash will be able to read everything sent to the decrypted hosts, cookies and passwords included. Turn this on only for hosts you mean to rewrite.';

  @override
  String get generateCertificate => 'Generate certificate';

  @override
  String get regenerateCertificate => 'Regenerate certificate';

  @override
  String get regenerateCertificateTip =>
      'The new certificate replaces the current one, which FlClash takes out of this device\'s trusted roots where it can. Every other device that trusts the current one has to install the new one.';

  @override
  String get exportCertificate => 'Export certificate';

  @override
  String get installCertificate => 'Install to system';

  @override
  String get installCertificateSuccess => 'Certificate installed';

  @override
  String validUntil(Object date) {
    return 'Valid until $date';
  }

  @override
  String get mitmCertificateExportTip =>
      'Export it and trust it on the devices you want to decrypt.';

  @override
  String get mitmTrustReady => 'Trusted';

  @override
  String get mitmTrustUntrusted => 'Not fully trusted';

  @override
  String get mitmTrustNotInstalled => 'Not installed';

  @override
  String get mitmTrustChecking => 'Checking…';

  @override
  String get mitmCertificateAndroidReadyTip =>
      'Only apps that trust user certificates, mostly browsers, are decrypted.';

  @override
  String get mitmAndroidRootDesc =>
      'Without root, only apps that trust user certificates, mostly browsers, can be decrypted. With root, every app can.';

  @override
  String get mitmCertificateLinuxTip =>
      'Flatpak browsers need the exported certificate imported by hand.';

  @override
  String mitmCertutilMissing(Object command) {
    return 'Chrome and Firefox keep their own certificate stores, which need certutil: $command';
  }

  @override
  String mitmMissingStores(Object stores) {
    return 'Not yet in: $stores';
  }

  @override
  String get httpRequestsReadFailed => 'Couldn\'t read the requests';

  @override
  String get requestBodyReadFailed => 'Couldn\'t read the request body';

  @override
  String get responseBodyReadFailed => 'Couldn\'t read the response body';

  @override
  String mitmGrpcOverLimit(Object size) {
    return 'Inflates past $size MB; shown compressed';
  }

  @override
  String mitmUntrustedStores(Object stores) {
    return 'Installed but not trusted in: $stores';
  }

  @override
  String get mitmSystemStoreFailed =>
      'Adding the certificate to the system\'s trusted roots failed';

  @override
  String get mitmRootUntilReboot =>
      'No Magisk, KernelSU or APatch was found to keep the certificate. Install it again after the device restarts.';

  @override
  String get mitmRootPendingReboot =>
      'The certificate takes effect after the device restarts.';

  @override
  String get mitmInstallSystemCaTip =>
      'Root was found, so the certificate goes into the system\'s trusted certificates as a FlClash MITM CA module for Magisk, KernelSU or APatch. Every app on this device will then trust it, and anyone holding its private key could decrypt this device\'s HTTPS traffic. To undo it, regenerate the certificate or remove the module in the root manager and restart. If root is denied, it is installed as a user certificate instead.';

  @override
  String get mitmInstallUserCaTip =>
      'No root was found, so the certificate can only be installed as a user certificate. Only apps that trust user certificates, mostly browsers, are decrypted; other apps fail on the hosts you list, so leave those hosts out. On Android 11 and later you finish the install yourself in system settings.';

  @override
  String mitmCertificateSavedTip(Object fileName) {
    return 'Saved $fileName to Downloads. Install it in Settings under Security › Encryption & credentials › Install a certificate › CA certificate.';
  }

  @override
  String get openSettings => 'Open settings';

  @override
  String mitmRemoveOldCertificateTip(Object name) {
    return 'Remove the old certificate, $name, in Settings under Security › Encryption & credentials › Trusted credentials › User, then install the new one.';
  }

  @override
  String mitmOldCertificateLeftTip(Object name) {
    return 'The old certificate, $name, could not be removed. Remove it from the trusted roots yourself.';
  }

  @override
  String mitmOldSystemCertificateLeftTip(Object name) {
    return 'The old certificate, $name, is still among the system\'s trusted CAs. Allow FlClash root access in your root manager and regenerate, or remove the FlClash MITM CA module there and restart.';
  }

  @override
  String get removeCertificate => 'Remove certificate';

  @override
  String get removeCertificateSuccess => 'Certificate removed';

  @override
  String get mitmSystemStoreRemoveFailed =>
      'Removing the certificate from the system\'s trusted roots failed';

  @override
  String get mitmRemoveInSettings => 'Remove in Settings';

  @override
  String mitmRemoveUserCertificateTip(Object name) {
    return 'Android doesn\'t let apps remove user certificates. Remove $name in Settings under Security › Encryption & credentials › Trusted credentials › User.';
  }

  @override
  String get mitmCannotRemove => 'Can\'t remove';

  @override
  String get mitmRemoveSystemCertificateTip =>
      'The FlClash MITM CA root module added the certificate to the system. Allow FlClash root access in your root manager and try again, or remove the module there and restart.';

  @override
  String get mitmDecryptHost => 'Decrypt this host';

  @override
  String mitmDecryptHostTip(Object host) {
    return 'Add $host to the hostname list? FlClash can then read what is sent to it, cookies and passwords included.';
  }

  @override
  String get mitmClientRefusedCertificate =>
      'The client refused the certificate. Install the CA, or exclude this host if the app pins its certificate.';

  @override
  String get mitmExcludeHost => 'Exclude from decryption';

  @override
  String mitmExcludeHostTip(Object host) {
    return 'Add -$host to the top of the hostname list? The host is then never decrypted.';
  }

  @override
  String get urlRewrite => 'URL rewrite';

  @override
  String get headerRewrite => 'Header rewrite';

  @override
  String get bodyRewrite => 'Body rewrite';

  @override
  String get mapLocal => 'Map local';

  @override
  String get requestBodyMock => 'Request body mock';

  @override
  String get clientSourceAddress => 'Client addresses';

  @override
  String get skipVerifyHostname => 'Hosts without certificate checks';

  @override
  String get mitmModules => 'Modules';

  @override
  String get mitmModule => 'Module';

  @override
  String get mitmModuleInvalid =>
      'This is not a Surge module, a Loon plugin, a Quantumult X snippet or a Stash override';

  @override
  String get arguments => 'Arguments';

  @override
  String get mitmRoutingRules => 'Routing rules';

  @override
  String get mitmIgnoredLines => 'Ignored lines';

  @override
  String get mitmModuleRulesDesc =>
      'Routing rules go in front of the profile’s own.';

  @override
  String get mitmRequestRulesDesc =>
      'The module’s URL-REGEX and USER-AGENT rules became URL rewrites, judged request by request: on every plain HTTP request, and on HTTPS only for hosts in the MITM hostname list.';

  @override
  String mitmModuleSystemTip(Object system) {
    return 'Written for $system; some lines may not match apps on this device.';
  }

  @override
  String mitmModuleRequirementTip(Object requirement) {
    return 'The module requires $requirement, which this device does not meet; it may not work as intended.';
  }

  @override
  String mitmExitModules(Object modules) {
    return 'From modules: $modules';
  }

  @override
  String get mitmModuleRiskTitle => 'Turn on this module?';

  @override
  String get mitmNetworkRisk =>
      'When the config is generated, it changes the network settings below, ahead of what you set for the same ones in FlClash. Turning the module off or deleting it undoes this.';

  @override
  String mitmSkipVerifyRisk(Object hosts) {
    return 'Turning it on stops checking the certificates of these hosts\' servers, so a server posing as one of them goes unnoticed: $hosts';
  }

  @override
  String mitmClientSourceRisk(Object addresses) {
    return 'It decrypts only for these clients: $addresses. With TUN on, this device\'s apps reach FlClash from the TUN\'s address, so they may be left out.';
  }

  @override
  String get mitmClientSourceTunTip =>
      'With TUN on, this device\'s apps come from the TUN\'s address; a list that leaves it out leaves their traffic undecrypted.';

  @override
  String get mitmNetworkChanges => 'Network settings';

  @override
  String mitmChangeReplace(Object values) {
    return 'Replaced with $values';
  }

  @override
  String mitmChangeInsert(Object values) {
    return 'Adds $values first';
  }

  @override
  String mitmChangeAppend(Object values) {
    return 'Adds $values';
  }

  @override
  String get mitmChangeOverridesYours => 'Goes over your setting';

  @override
  String mitmChangeReplacedBy(Object module) {
    return 'Overridden by the module $module';
  }

  @override
  String mitmSkipSection(Object section) {
    return 'The [$section] section is not supported';
  }

  @override
  String get mitmSkipSetting => 'This setting is not supported';

  @override
  String get mitmSkipScriptType => 'This script type is not supported';

  @override
  String get mitmSkipRule => 'This rule type is not supported';

  @override
  String get mitmSkipHttpRulePolicy =>
      'URL-REGEX and USER-AGENT rules only take a REJECT policy';

  @override
  String get mitmSkipFinalRule =>
      'Module rules go first, so a final rule would hide every rule after it';

  @override
  String get mitmSkipDeviceRule =>
      'This rule needs device or network details FlClash cannot read';

  @override
  String get mitmSkipRequirement =>
      'This line’s requirement is not met on this device';

  @override
  String get mitmSkipManagedCa =>
      'FlClash manages the CA certificate; a module cannot change it';

  @override
  String get mitmSkipProxies =>
      'A module cannot change proxies or proxy groups';

  @override
  String get mitmSkipAppOnly =>
      'A feature of the app this was written for that FlClash does not have';

  @override
  String get mitmSkipReflect =>
      'FlClash cannot send packets back to their sender';

  @override
  String get mitmSkipConditional => 'Conditional rewrites are not supported';

  @override
  String get mitmSkipSkipVerifyAll =>
      'Certificate checks are not turned off for every host';

  @override
  String get mitmSkipRelativeData =>
      'The file this line names is not attached; use a URL or attach it';

  @override
  String get mitmSkipNotDownloaded => 'Its file has not been downloaded';

  @override
  String get mitmSkipUnreadable => 'This line cannot be read';

  @override
  String get mitmAddLocalFile => 'Add a local file';

  @override
  String get mitmNewModule => 'New module';

  @override
  String get mitmAttachments => 'Attachments';

  @override
  String get mitmAttachmentsDesc =>
      'Lines refer to attachments by file name, as in script-path=a.js.';

  @override
  String mitmFileTooLarge(Object size) {
    return 'The file is larger than $size MB';
  }

  @override
  String get mitmSkipDisabled => 'Turned off by an argument';

  @override
  String get mitmSkipEvent => 'This event is not supported';

  @override
  String get mitmRunScript => 'Run now';

  @override
  String get mitmScriptCron => 'Scheduled';

  @override
  String get mitmScriptEvent => 'Event';

  @override
  String get mitmScriptGeneric => 'Generic';

  @override
  String get mitmExcluded => 'Excluded';

  @override
  String get mitmScriptNoOutput => 'The script finished without output';

  @override
  String get mitmScriptRiskTitle => 'Run this module\'s scripts?';

  @override
  String get mitmModulesTurnedOff => 'Modules turned off';

  @override
  String mitmModuleTurnedOffDesc(Object name) {
    return 'An update to $name brought scripts or network changes you have not agreed to';
  }

  @override
  String mitmModulesTurnedOffDesc(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count modules got updates with scripts or network changes you have not agreed to',
    );
    return '$_temp0';
  }

  @override
  String get mitmScriptRisk =>
      'Its scripts read and change the traffic of the hosts they match, cookies and tokens included, and can send requests of their own. Turn it on only if you trust where it comes from. Once on, its updates take effect without asking again.';

  @override
  String get mitmModuleUnreadableRisk =>
      'The module file could not be read, so what it changes is unknown. Turn it on only if you trust where it comes from.';

  @override
  String get skipServerCertVerify => 'Skip server certificate verification';

  @override
  String get blockQuic => 'Block QUIC';

  @override
  String get http2 => 'HTTP/2';

  @override
  String get decryptUntrusted => 'Decrypt without local trust';

  @override
  String invalidOfCount(Object invalid, Object total) {
    return '$invalid of $total invalid';
  }

  @override
  String get batchLineInputTip => 'One item per line';

  @override
  String get downloadingUpdate => 'Downloading update';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get updateDownloadTest => 'Update download test';

  @override
  String get liveStatusTest => 'Live status cards test';

  @override
  String get updateDownloadStarted =>
      'Downloading the update. Follow its progress on the dashboard.';

  @override
  String get updateReady => 'Update ready';

  @override
  String get updateReadyTip => 'The update has downloaded. Tap to install it.';

  @override
  String get stopUpdateDownloadTip => 'Stop downloading the update?';

  @override
  String get forceRestartCoreAsk => 'Force restart the core?';

  @override
  String get forceRestartCoreAskDesc => 'Connections in progress will drop';

  @override
  String get stopUpdateDownloadDesc => 'What has downloaded is deleted';

  @override
  String get stopDownload => 'Stop';

  @override
  String get updateInstallFailed =>
      'The update could not be installed. You can download it from the release page instead.';

  @override
  String get updateNotVerified =>
      'The downloaded update could not be verified.';

  @override
  String get updateRestartTip =>
      'FlClash closes to install the update and opens again when it is done.';

  @override
  String get updateDownloadFailed => 'The update could not be downloaded.';

  @override
  String get defaultNameserverDesc =>
      'Resolves the hostnames of the other DNS servers. Use IP addresses only.';

  @override
  String get nameserverDesc =>
      'The default DNS servers, such as 223.5.5.5, tls://1.1.1.1 or https://dns.google/dns-query.';

  @override
  String get fallbackDesc =>
      'Used instead of Nameserver when the fallback filter treats its answer as polluted.';

  @override
  String get proxyServerNameserverDesc =>
      'Resolves proxy server hostnames only.';

  @override
  String get proxyServerNameserverPolicyDesc =>
      'Matching proxy server hostnames use the DNS server given here instead of Proxy Server Nameserver.';

  @override
  String get directNameserverDesc =>
      'Resolves domains for connections that go direct.';

  @override
  String get nameserverPolicyDesc =>
      'Matching domains use the DNS server given here instead of Nameserver and Fallback.';

  @override
  String get fakeipFilterDesc =>
      'These domains get real IPs instead of Fake-IPs. In whitelist mode, only they get Fake-IPs.';

  @override
  String get fallbackFilterGeositeDesc =>
      'Domains in these GeoSite categories are resolved by Fallback directly.';

  @override
  String get fallbackFilterIpcidrDesc =>
      'When Nameserver returns an IP in these ranges, the Fallback answer is used.';

  @override
  String get fallbackFilterDomainDesc =>
      'These domains are resolved by Fallback directly.';

  @override
  String get liveStatus => 'Live status';

  @override
  String get coreStopped => 'Core stopped';

  @override
  String get coreStoppedDesc => 'The app lost its connection to the core';

  @override
  String coreStoppedWithReason(Object reason) {
    return 'The app lost its connection to the core: $reason';
  }

  @override
  String mixedPortReset(Object value, Object port) {
    return 'The mixed port cannot be $value, so it was set back to $port';
  }

  @override
  String get restartCore => 'Restart core';

  @override
  String get installUpdate => 'Install update';

  @override
  String liveStatusPosition(Object index, Object count) {
    return '$index of $count';
  }

  @override
  String get coreStarting => 'Starting core';

  @override
  String get coreStartingDesc => 'Connecting to the core';

  @override
  String get coreRunning => 'Core running';

  @override
  String get coreRunningDesc => 'The app is connected to the core';

  @override
  String get forceRestartCore => 'Force restart';

  @override
  String get vpnPermissionNotGranted =>
      'VPN permission was not granted, so the VPN did not start. An always-on VPN set for another app also blocks it.';

  @override
  String get vpnServiceStartFailed => 'The VPN service could not start.';
}
