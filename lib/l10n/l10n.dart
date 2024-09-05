// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppLocalizations {
  AppLocalizations();

  static AppLocalizations? _current;

  static AppLocalizations get current {
    assert(_current != null,
        'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalizations();
      AppLocalizations._current = instance;

      return instance;
    });
  }

  static AppLocalizations of(BuildContext context) {
    final instance = AppLocalizations.maybeOf(context);
    assert(instance != null,
        'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?');
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `Rule`
  String get rule {
    return Intl.message(
      'Rule',
      name: 'rule',
      desc: '',
      args: [],
    );
  }

  /// `Global`
  String get global {
    return Intl.message(
      'Global',
      name: 'global',
      desc: '',
      args: [],
    );
  }

  /// `Direct`
  String get direct {
    return Intl.message(
      'Direct',
      name: 'direct',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message(
      'Dashboard',
      name: 'dashboard',
      desc: '',
      args: [],
    );
  }

  /// `Proxies`
  String get proxies {
    return Intl.message(
      'Proxies',
      name: 'proxies',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Profiles`
  String get profiles {
    return Intl.message(
      'Profiles',
      name: 'profiles',
      desc: '',
      args: [],
    );
  }

  /// `Tools`
  String get tools {
    return Intl.message(
      'Tools',
      name: 'tools',
      desc: '',
      args: [],
    );
  }

  /// `Logs`
  String get logs {
    return Intl.message(
      'Logs',
      name: 'logs',
      desc: '',
      args: [],
    );
  }

  /// `Log capture records`
  String get logsDesc {
    return Intl.message(
      'Log capture records',
      name: 'logsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Resources`
  String get resources {
    return Intl.message(
      'Resources',
      name: 'resources',
      desc: '',
      args: [],
    );
  }

  /// `External resource related info`
  String get resourcesDesc {
    return Intl.message(
      'External resource related info',
      name: 'resourcesDesc',
      desc: '',
      args: [],
    );
  }

  /// `Traffic usage`
  String get trafficUsage {
    return Intl.message(
      'Traffic usage',
      name: 'trafficUsage',
      desc: '',
      args: [],
    );
  }

  /// `Core info`
  String get coreInfo {
    return Intl.message(
      'Core info',
      name: 'coreInfo',
      desc: '',
      args: [],
    );
  }

  /// `Unable to obtain core info`
  String get nullCoreInfoDesc {
    return Intl.message(
      'Unable to obtain core info',
      name: 'nullCoreInfoDesc',
      desc: '',
      args: [],
    );
  }

  /// `Network speed`
  String get networkSpeed {
    return Intl.message(
      'Network speed',
      name: 'networkSpeed',
      desc: '',
      args: [],
    );
  }

  /// `Outbound mode`
  String get outboundMode {
    return Intl.message(
      'Outbound mode',
      name: 'outboundMode',
      desc: '',
      args: [],
    );
  }

  /// `Network detection`
  String get networkDetection {
    return Intl.message(
      'Network detection',
      name: 'networkDetection',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get upload {
    return Intl.message(
      'Upload',
      name: 'upload',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message(
      'Download',
      name: 'download',
      desc: '',
      args: [],
    );
  }

  /// `No proxy`
  String get noProxy {
    return Intl.message(
      'No proxy',
      name: 'noProxy',
      desc: '',
      args: [],
    );
  }

  /// `Please create a profile or add a valid profile`
  String get noProxyDesc {
    return Intl.message(
      'Please create a profile or add a valid profile',
      name: 'noProxyDesc',
      desc: '',
      args: [],
    );
  }

  /// `No profile, Please add a profile`
  String get nullProfileDesc {
    return Intl.message(
      'No profile, Please add a profile',
      name: 'nullProfileDesc',
      desc: '',
      args: [],
    );
  }

  /// `No logs`
  String get nullLogsDesc {
    return Intl.message(
      'No logs',
      name: 'nullLogsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get defaultText {
    return Intl.message(
      'Default',
      name: 'defaultText',
      desc: '',
      args: [],
    );
  }

  /// `More`
  String get more {
    return Intl.message(
      'More',
      name: 'more',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get other {
    return Intl.message(
      'Other',
      name: 'other',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get en {
    return Intl.message(
      'English',
      name: 'en',
      desc: '',
      args: [],
    );
  }

  /// `Simplified Chinese`
  String get zh_CN {
    return Intl.message(
      'Simplified Chinese',
      name: 'zh_CN',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Set dark mode,adjust the color`
  String get themeDesc {
    return Intl.message(
      'Set dark mode,adjust the color',
      name: 'themeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Override`
  String get override {
    return Intl.message(
      'Override',
      name: 'override',
      desc: '',
      args: [],
    );
  }

  /// `Override Proxy related config`
  String get overrideDesc {
    return Intl.message(
      'Override Proxy related config',
      name: 'overrideDesc',
      desc: '',
      args: [],
    );
  }

  /// `AllowLan`
  String get allowLan {
    return Intl.message(
      'AllowLan',
      name: 'allowLan',
      desc: '',
      args: [],
    );
  }

  /// `Allow access proxy through the LAN`
  String get allowLanDesc {
    return Intl.message(
      'Allow access proxy through the LAN',
      name: 'allowLanDesc',
      desc: '',
      args: [],
    );
  }

  /// `TUN`
  String get tun {
    return Intl.message(
      'TUN',
      name: 'tun',
      desc: '',
      args: [],
    );
  }

  /// `only effective in administrator mode`
  String get tunDesc {
    return Intl.message(
      'only effective in administrator mode',
      name: 'tunDesc',
      desc: '',
      args: [],
    );
  }

  /// `Minimize on exit`
  String get minimizeOnExit {
    return Intl.message(
      'Minimize on exit',
      name: 'minimizeOnExit',
      desc: '',
      args: [],
    );
  }

  /// `Modify the default system exit event`
  String get minimizeOnExitDesc {
    return Intl.message(
      'Modify the default system exit event',
      name: 'minimizeOnExitDesc',
      desc: '',
      args: [],
    );
  }

  /// `AutoLaunch`
  String get autoLaunch {
    return Intl.message(
      'AutoLaunch',
      name: 'autoLaunch',
      desc: '',
      args: [],
    );
  }

  /// `Follow the system self startup`
  String get autoLaunchDesc {
    return Intl.message(
      'Follow the system self startup',
      name: 'autoLaunchDesc',
      desc: '',
      args: [],
    );
  }

  /// `SilentLaunch`
  String get silentLaunch {
    return Intl.message(
      'SilentLaunch',
      name: 'silentLaunch',
      desc: '',
      args: [],
    );
  }

  /// `Start in the background`
  String get silentLaunchDesc {
    return Intl.message(
      'Start in the background',
      name: 'silentLaunchDesc',
      desc: '',
      args: [],
    );
  }

  /// `AutoRun`
  String get autoRun {
    return Intl.message(
      'AutoRun',
      name: 'autoRun',
      desc: '',
      args: [],
    );
  }

  /// `Auto run when the application is opened`
  String get autoRunDesc {
    return Intl.message(
      'Auto run when the application is opened',
      name: 'autoRunDesc',
      desc: '',
      args: [],
    );
  }

  /// `Logcat`
  String get logcat {
    return Intl.message(
      'Logcat',
      name: 'logcat',
      desc: '',
      args: [],
    );
  }

  /// `Disabling will hide the log entry`
  String get logcatDesc {
    return Intl.message(
      'Disabling will hide the log entry',
      name: 'logcatDesc',
      desc: '',
      args: [],
    );
  }

  /// `Auto check updates`
  String get autoCheckUpdate {
    return Intl.message(
      'Auto check updates',
      name: 'autoCheckUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Auto check for updates when the app starts`
  String get autoCheckUpdateDesc {
    return Intl.message(
      'Auto check for updates when the app starts',
      name: 'autoCheckUpdateDesc',
      desc: '',
      args: [],
    );
  }

  /// `AccessControl`
  String get accessControl {
    return Intl.message(
      'AccessControl',
      name: 'accessControl',
      desc: '',
      args: [],
    );
  }

  /// `Configure application access proxy`
  String get accessControlDesc {
    return Intl.message(
      'Configure application access proxy',
      name: 'accessControlDesc',
      desc: '',
      args: [],
    );
  }

  /// `Application`
  String get application {
    return Intl.message(
      'Application',
      name: 'application',
      desc: '',
      args: [],
    );
  }

  /// `Modify application related settings`
  String get applicationDesc {
    return Intl.message(
      'Modify application related settings',
      name: 'applicationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Years`
  String get years {
    return Intl.message(
      'Years',
      name: 'years',
      desc: '',
      args: [],
    );
  }

  /// `Months`
  String get months {
    return Intl.message(
      'Months',
      name: 'months',
      desc: '',
      args: [],
    );
  }

  /// `Hours`
  String get hours {
    return Intl.message(
      'Hours',
      name: 'hours',
      desc: '',
      args: [],
    );
  }

  /// `Days`
  String get days {
    return Intl.message(
      'Days',
      name: 'days',
      desc: '',
      args: [],
    );
  }

  /// `Minutes`
  String get minutes {
    return Intl.message(
      'Minutes',
      name: 'minutes',
      desc: '',
      args: [],
    );
  }

  /// `Seconds`
  String get seconds {
    return Intl.message(
      'Seconds',
      name: 'seconds',
      desc: '',
      args: [],
    );
  }

  /// ` Ago`
  String get ago {
    return Intl.message(
      ' Ago',
      name: 'ago',
      desc: '',
      args: [],
    );
  }

  /// `Just`
  String get just {
    return Intl.message(
      'Just',
      name: 'just',
      desc: '',
      args: [],
    );
  }

  /// `QR code`
  String get qrcode {
    return Intl.message(
      'QR code',
      name: 'qrcode',
      desc: '',
      args: [],
    );
  }

  /// `Scan QR code to obtain profile`
  String get qrcodeDesc {
    return Intl.message(
      'Scan QR code to obtain profile',
      name: 'qrcodeDesc',
      desc: '',
      args: [],
    );
  }

  /// `URL`
  String get url {
    return Intl.message(
      'URL',
      name: 'url',
      desc: '',
      args: [],
    );
  }

  /// `Obtain profile through URL`
  String get urlDesc {
    return Intl.message(
      'Obtain profile through URL',
      name: 'urlDesc',
      desc: '',
      args: [],
    );
  }

  /// `File`
  String get file {
    return Intl.message(
      'File',
      name: 'file',
      desc: '',
      args: [],
    );
  }

  /// `Directly upload profile`
  String get fileDesc {
    return Intl.message(
      'Directly upload profile',
      name: 'fileDesc',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Please input the profile name`
  String get profileNameNullValidationDesc {
    return Intl.message(
      'Please input the profile name',
      name: 'profileNameNullValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Please input the profile URL`
  String get profileUrlNullValidationDesc {
    return Intl.message(
      'Please input the profile URL',
      name: 'profileUrlNullValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Please input a valid profile URL`
  String get profileUrlInvalidValidationDesc {
    return Intl.message(
      'Please input a valid profile URL',
      name: 'profileUrlInvalidValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Auto update`
  String get autoUpdate {
    return Intl.message(
      'Auto update',
      name: 'autoUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Auto update interval (minutes)`
  String get autoUpdateInterval {
    return Intl.message(
      'Auto update interval (minutes)',
      name: 'autoUpdateInterval',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the auto update interval time`
  String get profileAutoUpdateIntervalNullValidationDesc {
    return Intl.message(
      'Please enter the auto update interval time',
      name: 'profileAutoUpdateIntervalNullValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Please input a valid interval time format`
  String get profileAutoUpdateIntervalInvalidValidationDesc {
    return Intl.message(
      'Please input a valid interval time format',
      name: 'profileAutoUpdateIntervalInvalidValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Theme mode`
  String get themeMode {
    return Intl.message(
      'Theme mode',
      name: 'themeMode',
      desc: '',
      args: [],
    );
  }

  /// `Theme color`
  String get themeColor {
    return Intl.message(
      'Theme color',
      name: 'themeColor',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get preview {
    return Intl.message(
      'Preview',
      name: 'preview',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get auto {
    return Intl.message(
      'Auto',
      name: 'auto',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message(
      'Light',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `Import from URL`
  String get importFromURL {
    return Intl.message(
      'Import from URL',
      name: 'importFromURL',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message(
      'Submit',
      name: 'submit',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to pass`
  String get doYouWantToPass {
    return Intl.message(
      'Do you want to pass',
      name: 'doYouWantToPass',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `Sort by default`
  String get defaultSort {
    return Intl.message(
      'Sort by default',
      name: 'defaultSort',
      desc: '',
      args: [],
    );
  }

  /// `Sort by delay`
  String get delaySort {
    return Intl.message(
      'Sort by delay',
      name: 'delaySort',
      desc: '',
      args: [],
    );
  }

  /// `Sort by name`
  String get nameSort {
    return Intl.message(
      'Sort by name',
      name: 'nameSort',
      desc: '',
      args: [],
    );
  }

  /// `Please upload file`
  String get pleaseUploadFile {
    return Intl.message(
      'Please upload file',
      name: 'pleaseUploadFile',
      desc: '',
      args: [],
    );
  }

  /// `Please upload a valid QR code`
  String get pleaseUploadValidQrcode {
    return Intl.message(
      'Please upload a valid QR code',
      name: 'pleaseUploadValidQrcode',
      desc: '',
      args: [],
    );
  }

  /// `Blacklist mode`
  String get blacklistMode {
    return Intl.message(
      'Blacklist mode',
      name: 'blacklistMode',
      desc: '',
      args: [],
    );
  }

  /// `Whitelist mode`
  String get whitelistMode {
    return Intl.message(
      'Whitelist mode',
      name: 'whitelistMode',
      desc: '',
      args: [],
    );
  }

  /// `Filter system app`
  String get filterSystemApp {
    return Intl.message(
      'Filter system app',
      name: 'filterSystemApp',
      desc: '',
      args: [],
    );
  }

  /// `Cancel filter system app`
  String get cancelFilterSystemApp {
    return Intl.message(
      'Cancel filter system app',
      name: 'cancelFilterSystemApp',
      desc: '',
      args: [],
    );
  }

  /// `Select all`
  String get selectAll {
    return Intl.message(
      'Select all',
      name: 'selectAll',
      desc: '',
      args: [],
    );
  }

  /// `Cancel select all`
  String get cancelSelectAll {
    return Intl.message(
      'Cancel select all',
      name: 'cancelSelectAll',
      desc: '',
      args: [],
    );
  }

  /// `App access control`
  String get appAccessControl {
    return Intl.message(
      'App access control',
      name: 'appAccessControl',
      desc: '',
      args: [],
    );
  }

  /// `Only allow selected app to enter VPN`
  String get accessControlAllowDesc {
    return Intl.message(
      'Only allow selected app to enter VPN',
      name: 'accessControlAllowDesc',
      desc: '',
      args: [],
    );
  }

  /// `The selected application will be excluded from VPN`
  String get accessControlNotAllowDesc {
    return Intl.message(
      'The selected application will be excluded from VPN',
      name: 'accessControlNotAllowDesc',
      desc: '',
      args: [],
    );
  }

  /// `Selected`
  String get selected {
    return Intl.message(
      'Selected',
      name: 'selected',
      desc: '',
      args: [],
    );
  }

  /// `unable to update current profile`
  String get unableToUpdateCurrentProfileDesc {
    return Intl.message(
      'unable to update current profile',
      name: 'unableToUpdateCurrentProfileDesc',
      desc: '',
      args: [],
    );
  }

  /// `No more info`
  String get noMoreInfoDesc {
    return Intl.message(
      'No more info',
      name: 'noMoreInfoDesc',
      desc: '',
      args: [],
    );
  }

  /// `profile parse error`
  String get profileParseErrorDesc {
    return Intl.message(
      'profile parse error',
      name: 'profileParseErrorDesc',
      desc: '',
      args: [],
    );
  }

  /// `ProxyPort`
  String get proxyPort {
    return Intl.message(
      'ProxyPort',
      name: 'proxyPort',
      desc: '',
      args: [],
    );
  }

  /// `Set the Clash listening port`
  String get proxyPortDesc {
    return Intl.message(
      'Set the Clash listening port',
      name: 'proxyPortDesc',
      desc: '',
      args: [],
    );
  }

  /// `Port`
  String get port {
    return Intl.message(
      'Port',
      name: 'port',
      desc: '',
      args: [],
    );
  }

  /// `LogLevel`
  String get logLevel {
    return Intl.message(
      'LogLevel',
      name: 'logLevel',
      desc: '',
      args: [],
    );
  }

  /// `Show`
  String get show {
    return Intl.message(
      'Show',
      name: 'show',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exit {
    return Intl.message(
      'Exit',
      name: 'exit',
      desc: '',
      args: [],
    );
  }

  /// `System proxy`
  String get systemProxy {
    return Intl.message(
      'System proxy',
      name: 'systemProxy',
      desc: '',
      args: [],
    );
  }

  /// `Project`
  String get project {
    return Intl.message(
      'Project',
      name: 'project',
      desc: '',
      args: [],
    );
  }

  /// `Core`
  String get core {
    return Intl.message(
      'Core',
      name: 'core',
      desc: '',
      args: [],
    );
  }

  /// `Tab animation`
  String get tabAnimation {
    return Intl.message(
      'Tab animation',
      name: 'tabAnimation',
      desc: '',
      args: [],
    );
  }

  /// `When enabled, the home tab will add a toggle animation`
  String get tabAnimationDesc {
    return Intl.message(
      'When enabled, the home tab will add a toggle animation',
      name: 'tabAnimationDesc',
      desc: '',
      args: [],
    );
  }

  /// `A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.`
  String get desc {
    return Intl.message(
      'A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.',
      name: 'desc',
      desc: '',
      args: [],
    );
  }

  /// `Staring VPN...`
  String get startVpn {
    return Intl.message(
      'Staring VPN...',
      name: 'startVpn',
      desc: '',
      args: [],
    );
  }

  /// `Stopping VPN...`
  String get stopVpn {
    return Intl.message(
      'Stopping VPN...',
      name: 'stopVpn',
      desc: '',
      args: [],
    );
  }

  /// `Discovery a new version`
  String get discovery {
    return Intl.message(
      'Discovery a new version',
      name: 'discovery',
      desc: '',
      args: [],
    );
  }

  /// `Compatibility mode`
  String get compatible {
    return Intl.message(
      'Compatibility mode',
      name: 'compatible',
      desc: '',
      args: [],
    );
  }

  /// `Opening it will lose part of its application ability and gain the support of full amount of Clash.`
  String get compatibleDesc {
    return Intl.message(
      'Opening it will lose part of its application ability and gain the support of full amount of Clash.',
      name: 'compatibleDesc',
      desc: '',
      args: [],
    );
  }

  /// `The current proxy group cannot be selected.`
  String get notSelectedTip {
    return Intl.message(
      'The current proxy group cannot be selected.',
      name: 'notSelectedTip',
      desc: '',
      args: [],
    );
  }

  /// `tip`
  String get tip {
    return Intl.message(
      'tip',
      name: 'tip',
      desc: '',
      args: [],
    );
  }

  /// `Backup and Recovery`
  String get backupAndRecovery {
    return Intl.message(
      'Backup and Recovery',
      name: 'backupAndRecovery',
      desc: '',
      args: [],
    );
  }

  /// `Sync data via WebDAV or file`
  String get backupAndRecoveryDesc {
    return Intl.message(
      'Sync data via WebDAV or file',
      name: 'backupAndRecoveryDesc',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: '',
      args: [],
    );
  }

  /// `Backup`
  String get backup {
    return Intl.message(
      'Backup',
      name: 'backup',
      desc: '',
      args: [],
    );
  }

  /// `Recovery`
  String get recovery {
    return Intl.message(
      'Recovery',
      name: 'recovery',
      desc: '',
      args: [],
    );
  }

  /// `Only recovery profiles`
  String get recoveryProfiles {
    return Intl.message(
      'Only recovery profiles',
      name: 'recoveryProfiles',
      desc: '',
      args: [],
    );
  }

  /// `Recovery all data`
  String get recoveryAll {
    return Intl.message(
      'Recovery all data',
      name: 'recoveryAll',
      desc: '',
      args: [],
    );
  }

  /// `Recovery success`
  String get recoverySuccess {
    return Intl.message(
      'Recovery success',
      name: 'recoverySuccess',
      desc: '',
      args: [],
    );
  }

  /// `Backup success`
  String get backupSuccess {
    return Intl.message(
      'Backup success',
      name: 'backupSuccess',
      desc: '',
      args: [],
    );
  }

  /// `No info`
  String get noInfo {
    return Intl.message(
      'No info',
      name: 'noInfo',
      desc: '',
      args: [],
    );
  }

  /// `Please bind WebDAV`
  String get pleaseBindWebDAV {
    return Intl.message(
      'Please bind WebDAV',
      name: 'pleaseBindWebDAV',
      desc: '',
      args: [],
    );
  }

  /// `Bind`
  String get bind {
    return Intl.message(
      'Bind',
      name: 'bind',
      desc: '',
      args: [],
    );
  }

  /// `Connectivity：`
  String get connectivity {
    return Intl.message(
      'Connectivity：',
      name: 'connectivity',
      desc: '',
      args: [],
    );
  }

  /// `WebDAV configuration`
  String get webDAVConfiguration {
    return Intl.message(
      'WebDAV configuration',
      name: 'webDAVConfiguration',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `WebDAV server address`
  String get addressHelp {
    return Intl.message(
      'WebDAV server address',
      name: 'addressHelp',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid WebDAV address`
  String get addressTip {
    return Intl.message(
      'Please enter a valid WebDAV address',
      name: 'addressTip',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Password cannot be empty`
  String get passwordTip {
    return Intl.message(
      'Password cannot be empty',
      name: 'passwordTip',
      desc: '',
      args: [],
    );
  }

  /// `Account cannot be empty`
  String get accountTip {
    return Intl.message(
      'Account cannot be empty',
      name: 'accountTip',
      desc: '',
      args: [],
    );
  }

  /// `Check for updates`
  String get checkUpdate {
    return Intl.message(
      'Check for updates',
      name: 'checkUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Discover the new version`
  String get discoverNewVersion {
    return Intl.message(
      'Discover the new version',
      name: 'discoverNewVersion',
      desc: '',
      args: [],
    );
  }

  /// `The current application is already the latest version`
  String get checkUpdateError {
    return Intl.message(
      'The current application is already the latest version',
      name: 'checkUpdateError',
      desc: '',
      args: [],
    );
  }

  /// `Go to download`
  String get goDownload {
    return Intl.message(
      'Go to download',
      name: 'goDownload',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: '',
      args: [],
    );
  }

  /// `GeoData`
  String get geoData {
    return Intl.message(
      'GeoData',
      name: 'geoData',
      desc: '',
      args: [],
    );
  }

  /// `External resources`
  String get externalResources {
    return Intl.message(
      'External resources',
      name: 'externalResources',
      desc: '',
      args: [],
    );
  }

  /// `Checking...`
  String get checking {
    return Intl.message(
      'Checking...',
      name: 'checking',
      desc: '',
      args: [],
    );
  }

  /// `Country`
  String get country {
    return Intl.message(
      'Country',
      name: 'country',
      desc: '',
      args: [],
    );
  }

  /// `Check error`
  String get checkError {
    return Intl.message(
      'Check error',
      name: 'checkError',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Allow applications to bypass VPN`
  String get allowBypass {
    return Intl.message(
      'Allow applications to bypass VPN',
      name: 'allowBypass',
      desc: '',
      args: [],
    );
  }

  /// `Some apps can bypass VPN when turned on`
  String get allowBypassDesc {
    return Intl.message(
      'Some apps can bypass VPN when turned on',
      name: 'allowBypassDesc',
      desc: '',
      args: [],
    );
  }

  /// `ExternalController`
  String get externalController {
    return Intl.message(
      'ExternalController',
      name: 'externalController',
      desc: '',
      args: [],
    );
  }

  /// `Once enabled, the Clash kernel can be controlled on port 9090`
  String get externalControllerDesc {
    return Intl.message(
      'Once enabled, the Clash kernel can be controlled on port 9090',
      name: 'externalControllerDesc',
      desc: '',
      args: [],
    );
  }

  /// `When turned on it will be able to receive IPv6 traffic`
  String get ipv6Desc {
    return Intl.message(
      'When turned on it will be able to receive IPv6 traffic',
      name: 'ipv6Desc',
      desc: '',
      args: [],
    );
  }

  /// `App`
  String get app {
    return Intl.message(
      'App',
      name: 'app',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get general {
    return Intl.message(
      'General',
      name: 'general',
      desc: '',
      args: [],
    );
  }

  /// `Attach HTTP proxy to VpnService`
  String get systemProxyDesc {
    return Intl.message(
      'Attach HTTP proxy to VpnService',
      name: 'systemProxyDesc',
      desc: '',
      args: [],
    );
  }

  /// `Unified delay`
  String get unifiedDelay {
    return Intl.message(
      'Unified delay',
      name: 'unifiedDelay',
      desc: '',
      args: [],
    );
  }

  /// `Remove extra delays such as handshaking`
  String get unifiedDelayDesc {
    return Intl.message(
      'Remove extra delays such as handshaking',
      name: 'unifiedDelayDesc',
      desc: '',
      args: [],
    );
  }

  /// `TCP concurrent`
  String get tcpConcurrent {
    return Intl.message(
      'TCP concurrent',
      name: 'tcpConcurrent',
      desc: '',
      args: [],
    );
  }

  /// `Enabling it will allow TCP concurrency`
  String get tcpConcurrentDesc {
    return Intl.message(
      'Enabling it will allow TCP concurrency',
      name: 'tcpConcurrentDesc',
      desc: '',
      args: [],
    );
  }

  /// `Geo Low Memory Mode`
  String get geodataLoader {
    return Intl.message(
      'Geo Low Memory Mode',
      name: 'geodataLoader',
      desc: '',
      args: [],
    );
  }

  /// `Enabling will use the Geo low memory loader`
  String get geodataLoaderDesc {
    return Intl.message(
      'Enabling will use the Geo low memory loader',
      name: 'geodataLoaderDesc',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get requests {
    return Intl.message(
      'Requests',
      name: 'requests',
      desc: '',
      args: [],
    );
  }

  /// `View recently request records`
  String get requestsDesc {
    return Intl.message(
      'View recently request records',
      name: 'requestsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Find process`
  String get findProcessMode {
    return Intl.message(
      'Find process',
      name: 'findProcessMode',
      desc: '',
      args: [],
    );
  }

  /// `There is a risk of flashback after opening`
  String get findProcessModeDesc {
    return Intl.message(
      'There is a risk of flashback after opening',
      name: 'findProcessModeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Init`
  String get init {
    return Intl.message(
      'Init',
      name: 'init',
      desc: '',
      args: [],
    );
  }

  /// `Long term effective`
  String get infiniteTime {
    return Intl.message(
      'Long term effective',
      name: 'infiniteTime',
      desc: '',
      args: [],
    );
  }

  /// `Expiration time`
  String get expirationTime {
    return Intl.message(
      'Expiration time',
      name: 'expirationTime',
      desc: '',
      args: [],
    );
  }

  /// `Connections`
  String get connections {
    return Intl.message(
      'Connections',
      name: 'connections',
      desc: '',
      args: [],
    );
  }

  /// `View current connections data`
  String get connectionsDesc {
    return Intl.message(
      'View current connections data',
      name: 'connectionsDesc',
      desc: '',
      args: [],
    );
  }

  /// `No requests`
  String get nullRequestsDesc {
    return Intl.message(
      'No requests',
      name: 'nullRequestsDesc',
      desc: '',
      args: [],
    );
  }

  /// `No connections`
  String get nullConnectionsDesc {
    return Intl.message(
      'No connections',
      name: 'nullConnectionsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Intranet IP`
  String get intranetIP {
    return Intl.message(
      'Intranet IP',
      name: 'intranetIP',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get view {
    return Intl.message(
      'View',
      name: 'view',
      desc: '',
      args: [],
    );
  }

  /// `Cut`
  String get cut {
    return Intl.message(
      'Cut',
      name: 'cut',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  /// `Paste`
  String get paste {
    return Intl.message(
      'Paste',
      name: 'paste',
      desc: '',
      args: [],
    );
  }

  /// `Test url`
  String get testUrl {
    return Intl.message(
      'Test url',
      name: 'testUrl',
      desc: '',
      args: [],
    );
  }

  /// `Sync`
  String get sync {
    return Intl.message(
      'Sync',
      name: 'sync',
      desc: '',
      args: [],
    );
  }

  /// `Hidden from recent tasks`
  String get exclude {
    return Intl.message(
      'Hidden from recent tasks',
      name: 'exclude',
      desc: '',
      args: [],
    );
  }

  /// `When the app is in the background, the app is hidden from the recent task`
  String get excludeDesc {
    return Intl.message(
      'When the app is in the background, the app is hidden from the recent task',
      name: 'excludeDesc',
      desc: '',
      args: [],
    );
  }

  /// `One column`
  String get oneColumn {
    return Intl.message(
      'One column',
      name: 'oneColumn',
      desc: '',
      args: [],
    );
  }

  /// `Two columns`
  String get twoColumns {
    return Intl.message(
      'Two columns',
      name: 'twoColumns',
      desc: '',
      args: [],
    );
  }

  /// `Three columns`
  String get threeColumns {
    return Intl.message(
      'Three columns',
      name: 'threeColumns',
      desc: '',
      args: [],
    );
  }

  /// `Four columns`
  String get fourColumns {
    return Intl.message(
      'Four columns',
      name: 'fourColumns',
      desc: '',
      args: [],
    );
  }

  /// `Standard`
  String get expand {
    return Intl.message(
      'Standard',
      name: 'expand',
      desc: '',
      args: [],
    );
  }

  /// `Shrink`
  String get shrink {
    return Intl.message(
      'Shrink',
      name: 'shrink',
      desc: '',
      args: [],
    );
  }

  /// `Min`
  String get min {
    return Intl.message(
      'Min',
      name: 'min',
      desc: '',
      args: [],
    );
  }

  /// `Tab`
  String get tab {
    return Intl.message(
      'Tab',
      name: 'tab',
      desc: '',
      args: [],
    );
  }

  /// `List`
  String get list {
    return Intl.message(
      'List',
      name: 'list',
      desc: '',
      args: [],
    );
  }

  /// `Delay`
  String get delay {
    return Intl.message(
      'Delay',
      name: 'delay',
      desc: '',
      args: [],
    );
  }

  /// `Style`
  String get style {
    return Intl.message(
      'Style',
      name: 'style',
      desc: '',
      args: [],
    );
  }

  /// `Size`
  String get size {
    return Intl.message(
      'Size',
      name: 'size',
      desc: '',
      args: [],
    );
  }

  /// `Sort`
  String get sort {
    return Intl.message(
      'Sort',
      name: 'sort',
      desc: '',
      args: [],
    );
  }

  /// `Columns`
  String get columns {
    return Intl.message(
      'Columns',
      name: 'columns',
      desc: '',
      args: [],
    );
  }

  /// `Proxies setting`
  String get proxiesSetting {
    return Intl.message(
      'Proxies setting',
      name: 'proxiesSetting',
      desc: '',
      args: [],
    );
  }

  /// `Proxy group`
  String get proxyGroup {
    return Intl.message(
      'Proxy group',
      name: 'proxyGroup',
      desc: '',
      args: [],
    );
  }

  /// `Go`
  String get go {
    return Intl.message(
      'Go',
      name: 'go',
      desc: '',
      args: [],
    );
  }

  /// `External link`
  String get externalLink {
    return Intl.message(
      'External link',
      name: 'externalLink',
      desc: '',
      args: [],
    );
  }

  /// `Other contributors`
  String get otherContributors {
    return Intl.message(
      'Other contributors',
      name: 'otherContributors',
      desc: '',
      args: [],
    );
  }

  /// `Auto lose connections`
  String get autoCloseConnections {
    return Intl.message(
      'Auto lose connections',
      name: 'autoCloseConnections',
      desc: '',
      args: [],
    );
  }

  /// `Auto close connections after change node`
  String get autoCloseConnectionsDesc {
    return Intl.message(
      'Auto close connections after change node',
      name: 'autoCloseConnectionsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Only statistics proxy`
  String get onlyStatisticsProxy {
    return Intl.message(
      'Only statistics proxy',
      name: 'onlyStatisticsProxy',
      desc: '',
      args: [],
    );
  }

  /// `When turned on, only statistics proxy traffic`
  String get onlyStatisticsProxyDesc {
    return Intl.message(
      'When turned on, only statistics proxy traffic',
      name: 'onlyStatisticsProxyDesc',
      desc: '',
      args: [],
    );
  }

  /// `Sure you want to delete the current profile?`
  String get deleteProfileTip {
    return Intl.message(
      'Sure you want to delete the current profile?',
      name: 'deleteProfileTip',
      desc: '',
      args: [],
    );
  }

  /// `Prue black mode`
  String get prueBlackMode {
    return Intl.message(
      'Prue black mode',
      name: 'prueBlackMode',
      desc: '',
      args: [],
    );
  }

  /// `Tcp keep alive interval`
  String get keepAliveIntervalDesc {
    return Intl.message(
      'Tcp keep alive interval',
      name: 'keepAliveIntervalDesc',
      desc: '',
      args: [],
    );
  }

  /// ` entries`
  String get entries {
    return Intl.message(
      ' entries',
      name: 'entries',
      desc: '',
      args: [],
    );
  }

  /// `Local`
  String get local {
    return Intl.message(
      'Local',
      name: 'local',
      desc: '',
      args: [],
    );
  }

  /// `Remote`
  String get remote {
    return Intl.message(
      'Remote',
      name: 'remote',
      desc: '',
      args: [],
    );
  }

  /// `Backup local data to WebDAV`
  String get remoteBackupDesc {
    return Intl.message(
      'Backup local data to WebDAV',
      name: 'remoteBackupDesc',
      desc: '',
      args: [],
    );
  }

  /// `Recovery data from WebDAV`
  String get remoteRecoveryDesc {
    return Intl.message(
      'Recovery data from WebDAV',
      name: 'remoteRecoveryDesc',
      desc: '',
      args: [],
    );
  }

  /// `Backup local data to local`
  String get localBackupDesc {
    return Intl.message(
      'Backup local data to local',
      name: 'localBackupDesc',
      desc: '',
      args: [],
    );
  }

  /// `Recovery data from file`
  String get localRecoveryDesc {
    return Intl.message(
      'Recovery data from file',
      name: 'localRecoveryDesc',
      desc: '',
      args: [],
    );
  }

  /// `Mode`
  String get mode {
    return Intl.message(
      'Mode',
      name: 'mode',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get time {
    return Intl.message(
      'Time',
      name: 'time',
      desc: '',
      args: [],
    );
  }

  /// `Source`
  String get source {
    return Intl.message(
      'Source',
      name: 'source',
      desc: '',
      args: [],
    );
  }

  /// `All apps`
  String get allApps {
    return Intl.message(
      'All apps',
      name: 'allApps',
      desc: '',
      args: [],
    );
  }

  /// `Only third-party apps`
  String get onlyOtherApps {
    return Intl.message(
      'Only third-party apps',
      name: 'onlyOtherApps',
      desc: '',
      args: [],
    );
  }

  /// `Action`
  String get action {
    return Intl.message(
      'Action',
      name: 'action',
      desc: '',
      args: [],
    );
  }

  /// `Intelligent selection`
  String get intelligentSelected {
    return Intl.message(
      'Intelligent selection',
      name: 'intelligentSelected',
      desc: '',
      args: [],
    );
  }

  /// `Clipboard import`
  String get clipboardImport {
    return Intl.message(
      'Clipboard import',
      name: 'clipboardImport',
      desc: '',
      args: [],
    );
  }

  /// `Export clipboard`
  String get clipboardExport {
    return Intl.message(
      'Export clipboard',
      name: 'clipboardExport',
      desc: '',
      args: [],
    );
  }

  /// `Layout`
  String get layout {
    return Intl.message(
      'Layout',
      name: 'layout',
      desc: '',
      args: [],
    );
  }

  /// `Tight`
  String get tight {
    return Intl.message(
      'Tight',
      name: 'tight',
      desc: '',
      args: [],
    );
  }

  /// `Standard`
  String get standard {
    return Intl.message(
      'Standard',
      name: 'standard',
      desc: '',
      args: [],
    );
  }

  /// `Loose`
  String get loose {
    return Intl.message(
      'Loose',
      name: 'loose',
      desc: '',
      args: [],
    );
  }

  /// `Profiles sort`
  String get profilesSort {
    return Intl.message(
      'Profiles sort',
      name: 'profilesSort',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message(
      'Start',
      name: 'start',
      desc: '',
      args: [],
    );
  }

  /// `Stop`
  String get stop {
    return Intl.message(
      'Stop',
      name: 'stop',
      desc: '',
      args: [],
    );
  }

  /// `Processing app related settings`
  String get appDesc {
    return Intl.message(
      'Processing app related settings',
      name: 'appDesc',
      desc: '',
      args: [],
    );
  }

  /// `Modify VPN related settings`
  String get vpnDesc {
    return Intl.message(
      'Modify VPN related settings',
      name: 'vpnDesc',
      desc: '',
      args: [],
    );
  }

  /// `Overwrite general settings`
  String get generalDesc {
    return Intl.message(
      'Overwrite general settings',
      name: 'generalDesc',
      desc: '',
      args: [],
    );
  }

  /// `Update DNS related settings`
  String get dnsDesc {
    return Intl.message(
      'Update DNS related settings',
      name: 'dnsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Key`
  String get key {
    return Intl.message(
      'Key',
      name: 'key',
      desc: '',
      args: [],
    );
  }

  /// `Value`
  String get value {
    return Intl.message(
      'Value',
      name: 'value',
      desc: '',
      args: [],
    );
  }

  /// `The key cannot be empty`
  String get keyNotEmpty {
    return Intl.message(
      'The key cannot be empty',
      name: 'keyNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `The value cannot be empty`
  String get valueNotEmpty {
    return Intl.message(
      'The value cannot be empty',
      name: 'valueNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Add Hosts`
  String get hostsDesc {
    return Intl.message(
      'Add Hosts',
      name: 'hostsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Changes take effect after restarting the VPN`
  String get vpnTip {
    return Intl.message(
      'Changes take effect after restarting the VPN',
      name: 'vpnTip',
      desc: '',
      args: [],
    );
  }

  /// `Auto routes all system traffic through VpnService`
  String get vpnEnableDesc {
    return Intl.message(
      'Auto routes all system traffic through VpnService',
      name: 'vpnEnableDesc',
      desc: '',
      args: [],
    );
  }

  /// `Options`
  String get options {
    return Intl.message(
      'Options',
      name: 'options',
      desc: '',
      args: [],
    );
  }

  /// `Loopback unlock tool`
  String get loopback {
    return Intl.message(
      'Loopback unlock tool',
      name: 'loopback',
      desc: '',
      args: [],
    );
  }

  /// `Used for UWP loopback unlocking`
  String get loopbackDesc {
    return Intl.message(
      'Used for UWP loopback unlocking',
      name: 'loopbackDesc',
      desc: '',
      args: [],
    );
  }

  /// `Providers`
  String get providers {
    return Intl.message(
      'Providers',
      name: 'providers',
      desc: '',
      args: [],
    );
  }

  /// `Proxy providers`
  String get proxyProviders {
    return Intl.message(
      'Proxy providers',
      name: 'proxyProviders',
      desc: '',
      args: [],
    );
  }

  /// `Rule providers`
  String get ruleProviders {
    return Intl.message(
      'Rule providers',
      name: 'ruleProviders',
      desc: '',
      args: [],
    );
  }

  /// `Override Dns`
  String get overrideDns {
    return Intl.message(
      'Override Dns',
      name: 'overrideDns',
      desc: '',
      args: [],
    );
  }

  /// `Turning it on will override the DNS options in the profile`
  String get overrideDnsDesc {
    return Intl.message(
      'Turning it on will override the DNS options in the profile',
      name: 'overrideDnsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message(
      'Status',
      name: 'status',
      desc: '',
      args: [],
    );
  }

  /// `System DNS will be used when turned off`
  String get statusDesc {
    return Intl.message(
      'System DNS will be used when turned off',
      name: 'statusDesc',
      desc: '',
      args: [],
    );
  }

  /// `Prioritize the use of DOH's http/3`
  String get preferH3Desc {
    return Intl.message(
      'Prioritize the use of DOH\'s http/3',
      name: 'preferH3Desc',
      desc: '',
      args: [],
    );
  }

  /// `Respect rules`
  String get respectRules {
    return Intl.message(
      'Respect rules',
      name: 'respectRules',
      desc: '',
      args: [],
    );
  }

  /// `DNS connection following rules, need to configure proxy-server-nameserver`
  String get respectRulesDesc {
    return Intl.message(
      'DNS connection following rules, need to configure proxy-server-nameserver',
      name: 'respectRulesDesc',
      desc: '',
      args: [],
    );
  }

  /// `DNS mode`
  String get dnsMode {
    return Intl.message(
      'DNS mode',
      name: 'dnsMode',
      desc: '',
      args: [],
    );
  }

  /// `Fakeip range`
  String get fakeipRange {
    return Intl.message(
      'Fakeip range',
      name: 'fakeipRange',
      desc: '',
      args: [],
    );
  }

  /// `Fakeip filter`
  String get fakeipFilter {
    return Intl.message(
      'Fakeip filter',
      name: 'fakeipFilter',
      desc: '',
      args: [],
    );
  }

  /// `Default nameserver`
  String get defaultNameserver {
    return Intl.message(
      'Default nameserver',
      name: 'defaultNameserver',
      desc: '',
      args: [],
    );
  }

  /// `For resolving DNS server`
  String get defaultNameserverDesc {
    return Intl.message(
      'For resolving DNS server',
      name: 'defaultNameserverDesc',
      desc: '',
      args: [],
    );
  }

  /// `Nameserver`
  String get nameserver {
    return Intl.message(
      'Nameserver',
      name: 'nameserver',
      desc: '',
      args: [],
    );
  }

  /// `For resolving domain`
  String get nameserverDesc {
    return Intl.message(
      'For resolving domain',
      name: 'nameserverDesc',
      desc: '',
      args: [],
    );
  }

  /// `Use hosts`
  String get useHosts {
    return Intl.message(
      'Use hosts',
      name: 'useHosts',
      desc: '',
      args: [],
    );
  }

  /// `Use system hosts`
  String get useSystemHosts {
    return Intl.message(
      'Use system hosts',
      name: 'useSystemHosts',
      desc: '',
      args: [],
    );
  }

  /// `Nameserver policy`
  String get nameserverPolicy {
    return Intl.message(
      'Nameserver policy',
      name: 'nameserverPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Specify the corresponding nameserver policy`
  String get nameserverPolicyDesc {
    return Intl.message(
      'Specify the corresponding nameserver policy',
      name: 'nameserverPolicyDesc',
      desc: '',
      args: [],
    );
  }

  /// `Proxy nameserver`
  String get proxyNameserver {
    return Intl.message(
      'Proxy nameserver',
      name: 'proxyNameserver',
      desc: '',
      args: [],
    );
  }

  /// `Domain for resolving proxy nodes`
  String get proxyNameserverDesc {
    return Intl.message(
      'Domain for resolving proxy nodes',
      name: 'proxyNameserverDesc',
      desc: '',
      args: [],
    );
  }

  /// `Fallback`
  String get fallback {
    return Intl.message(
      'Fallback',
      name: 'fallback',
      desc: '',
      args: [],
    );
  }

  /// `Generally use offshore DNS`
  String get fallbackDesc {
    return Intl.message(
      'Generally use offshore DNS',
      name: 'fallbackDesc',
      desc: '',
      args: [],
    );
  }

  /// `Fallback filter`
  String get fallbackFilter {
    return Intl.message(
      'Fallback filter',
      name: 'fallbackFilter',
      desc: '',
      args: [],
    );
  }

  /// `Geoip code`
  String get geoipCode {
    return Intl.message(
      'Geoip code',
      name: 'geoipCode',
      desc: '',
      args: [],
    );
  }

  /// `Ipcidr`
  String get ipcidr {
    return Intl.message(
      'Ipcidr',
      name: 'ipcidr',
      desc: '',
      args: [],
    );
  }

  /// `Domain`
  String get domain {
    return Intl.message(
      'Domain',
      name: 'domain',
      desc: '',
      args: [],
    );
  }

  /// `Reset Dns`
  String get resetDns {
    return Intl.message(
      'Reset Dns',
      name: 'resetDns',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
