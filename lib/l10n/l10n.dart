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
    assert(
      _current != null,
      'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.',
    );
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
    assert(
      instance != null,
      'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `Rule`
  String get rule {
    return Intl.message('Rule', name: 'rule', desc: '', args: []);
  }

  /// `Rules`
  String get rules {
    return Intl.message('Rules', name: 'rules', desc: '', args: []);
  }

  /// `Global`
  String get global {
    return Intl.message('Global', name: 'global', desc: '', args: []);
  }

  /// `Direct`
  String get direct {
    return Intl.message('Direct', name: 'direct', desc: '', args: []);
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message('Dashboard', name: 'dashboard', desc: '', args: []);
  }

  /// `Proxies`
  String get proxies {
    return Intl.message('Proxies', name: 'proxies', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Profiles`
  String get profiles {
    return Intl.message('Profiles', name: 'profiles', desc: '', args: []);
  }

  /// `Tools`
  String get tools {
    return Intl.message('Tools', name: 'tools', desc: '', args: []);
  }

  /// `Logs`
  String get logs {
    return Intl.message('Logs', name: 'logs', desc: '', args: []);
  }

  /// `Captured log records`
  String get logsDesc {
    return Intl.message(
      'Captured log records',
      name: 'logsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Resources`
  String get resources {
    return Intl.message('Resources', name: 'resources', desc: '', args: []);
  }

  /// `Information about external resources`
  String get resourcesDesc {
    return Intl.message(
      'Information about external resources',
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
    return Intl.message('Upload', name: 'upload', desc: '', args: []);
  }

  /// `Download`
  String get download {
    return Intl.message('Download', name: 'download', desc: '', args: []);
  }

  /// `Used traffic`
  String get usedTraffic {
    return Intl.message(
      'Used traffic',
      name: 'usedTraffic',
      desc: '',
      args: [],
    );
  }

  /// `Total traffic`
  String get totalTraffic {
    return Intl.message(
      'Total traffic',
      name: 'totalTraffic',
      desc: '',
      args: [],
    );
  }

  /// `Expiration time`
  String get expireTime {
    return Intl.message(
      'Expiration time',
      name: 'expireTime',
      desc: '',
      args: [],
    );
  }

  /// `No profiles yet, please add one first`
  String get nullProfileDesc {
    return Intl.message(
      'No profiles yet, please add one first',
      name: 'nullProfileDesc',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Default`
  String get defaultText {
    return Intl.message('Default', name: 'defaultText', desc: '', args: []);
  }

  /// `More`
  String get more {
    return Intl.message('More', name: 'more', desc: '', args: []);
  }

  /// `Other`
  String get other {
    return Intl.message('Other', name: 'other', desc: '', args: []);
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `English`
  String get en {
    return Intl.message('English', name: 'en', desc: '', args: []);
  }

  /// `Japanese`
  String get ja {
    return Intl.message('Japanese', name: 'ja', desc: '', args: []);
  }

  /// `Russian`
  String get ru {
    return Intl.message('Russian', name: 'ru', desc: '', args: []);
  }

  /// `Simplified Chinese`
  String get zhCN {
    return Intl.message('Simplified Chinese', name: 'zhCN', desc: '', args: []);
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Set dark mode and adjust colors`
  String get themeDesc {
    return Intl.message(
      'Set dark mode and adjust colors',
      name: 'themeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Override`
  String get override {
    return Intl.message('Override', name: 'override', desc: '', args: []);
  }

  /// `Allow LAN`
  String get allowLan {
    return Intl.message('Allow LAN', name: 'allowLan', desc: '', args: []);
  }

  /// `Allow proxy access over the LAN`
  String get allowLanDesc {
    return Intl.message(
      'Allow proxy access over the LAN',
      name: 'allowLanDesc',
      desc: '',
      args: [],
    );
  }

  /// `TUN`
  String get tun {
    return Intl.message('TUN', name: 'tun', desc: '', args: []);
  }

  /// `Only effective in administrator mode`
  String get tunDesc {
    return Intl.message(
      'Only effective in administrator mode',
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

  /// `Override the default system exit behavior`
  String get minimizeOnExitDesc {
    return Intl.message(
      'Override the default system exit behavior',
      name: 'minimizeOnExitDesc',
      desc: '',
      args: [],
    );
  }

  /// `Auto launch`
  String get autoLaunch {
    return Intl.message('Auto launch', name: 'autoLaunch', desc: '', args: []);
  }

  /// `Launch automatically at system startup`
  String get autoLaunchDesc {
    return Intl.message(
      'Launch automatically at system startup',
      name: 'autoLaunchDesc',
      desc: '',
      args: [],
    );
  }

  /// `Silent launch`
  String get silentLaunch {
    return Intl.message(
      'Silent launch',
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

  /// `Auto run`
  String get autoRun {
    return Intl.message('Auto run', name: 'autoRun', desc: '', args: []);
  }

  /// `Run automatically when the app opens`
  String get autoRunDesc {
    return Intl.message(
      'Run automatically when the app opens',
      name: 'autoRunDesc',
      desc: '',
      args: [],
    );
  }

  /// `Logcat`
  String get logcat {
    return Intl.message('Logcat', name: 'logcat', desc: '', args: []);
  }

  /// `Disabling hides the log entry point`
  String get logcatDesc {
    return Intl.message(
      'Disabling hides the log entry point',
      name: 'logcatDesc',
      desc: '',
      args: [],
    );
  }

  /// `Auto check for updates`
  String get autoCheckUpdate {
    return Intl.message(
      'Auto check for updates',
      name: 'autoCheckUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Check for updates automatically when the app starts`
  String get autoCheckUpdateDesc {
    return Intl.message(
      'Check for updates automatically when the app starts',
      name: 'autoCheckUpdateDesc',
      desc: '',
      args: [],
    );
  }

  /// `Verify TLS certificates`
  String get checkCertificate {
    return Intl.message(
      'Verify TLS certificates',
      name: 'checkCertificate',
      desc: '',
      args: [],
    );
  }

  /// `Reject untrusted certificates. Turning this off exposes subscriptions and backups to man-in-the-middle attacks`
  String get checkCertificateDesc {
    return Intl.message(
      'Reject untrusted certificates. Turning this off exposes subscriptions and backups to man-in-the-middle attacks',
      name: 'checkCertificateDesc',
      desc: '',
      args: [],
    );
  }

  /// `Access control`
  String get accessControl {
    return Intl.message(
      'Access control',
      name: 'accessControl',
      desc: '',
      args: [],
    );
  }

  /// `Control which apps use the proxy`
  String get accessControlDesc {
    return Intl.message(
      'Control which apps use the proxy',
      name: 'accessControlDesc',
      desc: '',
      args: [],
    );
  }

  /// `Application`
  String get application {
    return Intl.message('Application', name: 'application', desc: '', args: []);
  }

  /// `Adjust application settings`
  String get applicationDesc {
    return Intl.message(
      'Adjust application settings',
      name: 'applicationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `seconds`
  String get seconds {
    return Intl.message('seconds', name: 'seconds', desc: '', args: []);
  }

  /// `QR code`
  String get qrcode {
    return Intl.message('QR code', name: 'qrcode', desc: '', args: []);
  }

  /// `Scan a QR code to obtain a profile`
  String get qrcodeDesc {
    return Intl.message(
      'Scan a QR code to obtain a profile',
      name: 'qrcodeDesc',
      desc: '',
      args: [],
    );
  }

  /// `URL`
  String get url {
    return Intl.message('URL', name: 'url', desc: '', args: []);
  }

  /// `Obtain a profile from a URL`
  String get urlDesc {
    return Intl.message(
      'Obtain a profile from a URL',
      name: 'urlDesc',
      desc: '',
      args: [],
    );
  }

  /// `File`
  String get file {
    return Intl.message('File', name: 'file', desc: '', args: []);
  }

  /// `Upload a profile file directly`
  String get fileDesc {
    return Intl.message(
      'Upload a profile file directly',
      name: 'fileDesc',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Please enter the profile name`
  String get profileNameNullValidationDesc {
    return Intl.message(
      'Please enter the profile name',
      name: 'profileNameNullValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the profile URL`
  String get profileUrlNullValidationDesc {
    return Intl.message(
      'Please enter the profile URL',
      name: 'profileUrlNullValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid profile URL`
  String get profileUrlInvalidValidationDesc {
    return Intl.message(
      'Please enter a valid profile URL',
      name: 'profileUrlInvalidValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Auto update`
  String get autoUpdate {
    return Intl.message('Auto update', name: 'autoUpdate', desc: '', args: []);
  }

  /// `Auto-update interval (minutes)`
  String get autoUpdateInterval {
    return Intl.message(
      'Auto-update interval (minutes)',
      name: 'autoUpdateInterval',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the auto-update interval`
  String get profileAutoUpdateIntervalNullValidationDesc {
    return Intl.message(
      'Please enter the auto-update interval',
      name: 'profileAutoUpdateIntervalNullValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid interval`
  String get profileAutoUpdateIntervalInvalidValidationDesc {
    return Intl.message(
      'Please enter a valid interval',
      name: 'profileAutoUpdateIntervalInvalidValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Theme mode`
  String get themeMode {
    return Intl.message('Theme mode', name: 'themeMode', desc: '', args: []);
  }

  /// `Theme color`
  String get themeColor {
    return Intl.message('Theme color', name: 'themeColor', desc: '', args: []);
  }

  /// `Preview`
  String get preview {
    return Intl.message('Preview', name: 'preview', desc: '', args: []);
  }

  /// `Auto`
  String get auto {
    return Intl.message('Auto', name: 'auto', desc: '', args: []);
  }

  /// `Light`
  String get light {
    return Intl.message('Light', name: 'light', desc: '', args: []);
  }

  /// `Dark`
  String get dark {
    return Intl.message('Dark', name: 'dark', desc: '', args: []);
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
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Do you want to create a profile from {url}?`
  String createProfileFromUrlTip(Object url) {
    return Intl.message(
      'Do you want to create a profile from $url?',
      name: 'createProfileFromUrlTip',
      desc: '',
      args: [url],
    );
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
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

  /// `Select all`
  String get selectAll {
    return Intl.message('Select all', name: 'selectAll', desc: '', args: []);
  }

  /// `Deselect all`
  String get cancelSelectAll {
    return Intl.message(
      'Deselect all',
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

  /// `Only selected apps go through the VPN`
  String get accessControlAllowDesc {
    return Intl.message(
      'Only selected apps go through the VPN',
      name: 'accessControlAllowDesc',
      desc: '',
      args: [],
    );
  }

  /// `Selected apps are excluded from the VPN`
  String get accessControlNotAllowDesc {
    return Intl.message(
      'Selected apps are excluded from the VPN',
      name: 'accessControlNotAllowDesc',
      desc: '',
      args: [],
    );
  }

  /// `App access control is disabled`
  String get accessControlDisabledDesc {
    return Intl.message(
      'App access control is disabled',
      name: 'accessControlDisabledDesc',
      desc: '',
      args: [],
    );
  }

  /// `Selected`
  String get selected {
    return Intl.message('Selected', name: 'selected', desc: '', args: []);
  }

  /// `Port`
  String get port {
    return Intl.message('Port', name: 'port', desc: '', args: []);
  }

  /// `Log level`
  String get logLevel {
    return Intl.message('Log level', name: 'logLevel', desc: '', args: []);
  }

  /// `Show`
  String get show {
    return Intl.message('Show', name: 'show', desc: '', args: []);
  }

  /// `Exit`
  String get exit {
    return Intl.message('Exit', name: 'exit', desc: '', args: []);
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
    return Intl.message('Project', name: 'project', desc: '', args: []);
  }

  /// `Core`
  String get core {
    return Intl.message('Core', name: 'core', desc: '', args: []);
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

  /// `A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.`
  String get desc {
    return Intl.message(
      'A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.',
      name: 'desc',
      desc: '',
      args: [],
    );
  }

  /// `Starting VPN...`
  String get startVpn {
    return Intl.message(
      'Starting VPN...',
      name: 'startVpn',
      desc: '',
      args: [],
    );
  }

  /// `Stopping VPN...`
  String get stopVpn {
    return Intl.message('Stopping VPN...', name: 'stopVpn', desc: '', args: []);
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

  /// `The current proxy group cannot be selected`
  String get notSelectedTip {
    return Intl.message(
      'The current proxy group cannot be selected',
      name: 'notSelectedTip',
      desc: '',
      args: [],
    );
  }

  /// `Failed to switch proxy; the previous selection has been restored`
  String get changeProxyFailedTip {
    return Intl.message(
      'Failed to switch proxy; the previous selection has been restored',
      name: 'changeProxyFailedTip',
      desc: '',
      args: [],
    );
  }

  /// `Failed to save the change; it has been rolled back`
  String get databaseWriteFailedTip {
    return Intl.message(
      'Failed to save the change; it has been rolled back',
      name: 'databaseWriteFailedTip',
      desc: '',
      args: [],
    );
  }

  /// `Tip`
  String get tip {
    return Intl.message('Tip', name: 'tip', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Backup`
  String get backup {
    return Intl.message('Backup', name: 'backup', desc: '', args: []);
  }

  /// `Backup successful`
  String get backupSuccess {
    return Intl.message(
      'Backup successful',
      name: 'backupSuccess',
      desc: '',
      args: [],
    );
  }

  /// `No info`
  String get noInfo {
    return Intl.message('No info', name: 'noInfo', desc: '', args: []);
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
    return Intl.message('Bind', name: 'bind', desc: '', args: []);
  }

  /// `Connectivity: `
  String get connectivity {
    return Intl.message(
      'Connectivity: ',
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
    return Intl.message('Address', name: 'address', desc: '', args: []);
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
    return Intl.message('Password', name: 'password', desc: '', args: []);
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

  /// `New version found`
  String get discoverNewVersion {
    return Intl.message(
      'New version found',
      name: 'discoverNewVersion',
      desc: '',
      args: [],
    );
  }

  /// `The app is already up to date`
  String get checkUpdateError {
    return Intl.message(
      'The app is already up to date',
      name: 'checkUpdateError',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get goDownload {
    return Intl.message('Download', name: 'goDownload', desc: '', args: []);
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `Region`
  String get country {
    return Intl.message('Region', name: 'country', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Allow apps to bypass VPN`
  String get allowBypass {
    return Intl.message(
      'Allow apps to bypass VPN',
      name: 'allowBypass',
      desc: '',
      args: [],
    );
  }

  /// `When enabled, some apps can bypass the VPN`
  String get allowBypassDesc {
    return Intl.message(
      'When enabled, some apps can bypass the VPN',
      name: 'allowBypassDesc',
      desc: '',
      args: [],
    );
  }

  /// `External controller`
  String get externalController {
    return Intl.message(
      'External controller',
      name: 'externalController',
      desc: '',
      args: [],
    );
  }

  /// `When enabled, the Clash core can be controlled on port 9090`
  String get externalControllerDesc {
    return Intl.message(
      'When enabled, the Clash core can be controlled on port 9090',
      name: 'externalControllerDesc',
      desc: '',
      args: [],
    );
  }

  /// `When enabled, IPv6 traffic can be received`
  String get ipv6Desc {
    return Intl.message(
      'When enabled, IPv6 traffic can be received',
      name: 'ipv6Desc',
      desc: '',
      args: [],
    );
  }

  /// `App`
  String get app {
    return Intl.message('App', name: 'app', desc: '', args: []);
  }

  /// `General`
  String get general {
    return Intl.message('General', name: 'general', desc: '', args: []);
  }

  /// `Set the system proxy`
  String get systemProxyDesc {
    return Intl.message(
      'Set the system proxy',
      name: 'systemProxyDesc',
      desc: '',
      args: [],
    );
  }

  /// `User-Agent`
  String get userAgent {
    return Intl.message('User-Agent', name: 'userAgent', desc: '', args: []);
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

  /// `Remove extra delays such as handshakes`
  String get unifiedDelayDesc {
    return Intl.message(
      'Remove extra delays such as handshakes',
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

  /// `Allow concurrent TCP connections`
  String get tcpConcurrentDesc {
    return Intl.message(
      'Allow concurrent TCP connections',
      name: 'tcpConcurrentDesc',
      desc: '',
      args: [],
    );
  }

  /// `Geo low-memory mode`
  String get geodataLoader {
    return Intl.message(
      'Geo low-memory mode',
      name: 'geodataLoader',
      desc: '',
      args: [],
    );
  }

  /// `Use the low-memory Geo loader`
  String get geodataLoaderDesc {
    return Intl.message(
      'Use the low-memory Geo loader',
      name: 'geodataLoaderDesc',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get requests {
    return Intl.message('Requests', name: 'requests', desc: '', args: []);
  }

  /// `View recent request records`
  String get requestsDesc {
    return Intl.message(
      'View recent request records',
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

  /// `Init`
  String get init {
    return Intl.message('Init', name: 'init', desc: '', args: []);
  }

  /// `Never expires`
  String get infiniteTime {
    return Intl.message(
      'Never expires',
      name: 'infiniteTime',
      desc: '',
      args: [],
    );
  }

  /// `Connections`
  String get connections {
    return Intl.message('Connections', name: 'connections', desc: '', args: []);
  }

  /// `View current connection data`
  String get connectionsDesc {
    return Intl.message(
      'View current connection data',
      name: 'connectionsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Intranet IP`
  String get intranetIP {
    return Intl.message('Intranet IP', name: 'intranetIP', desc: '', args: []);
  }

  /// `View`
  String get view {
    return Intl.message('View', name: 'view', desc: '', args: []);
  }

  /// `Cut`
  String get cut {
    return Intl.message('Cut', name: 'cut', desc: '', args: []);
  }

  /// `Copy`
  String get copy {
    return Intl.message('Copy', name: 'copy', desc: '', args: []);
  }

  /// `Paste`
  String get paste {
    return Intl.message('Paste', name: 'paste', desc: '', args: []);
  }

  /// `Test URL`
  String get testUrl {
    return Intl.message('Test URL', name: 'testUrl', desc: '', args: []);
  }

  /// `Sync`
  String get sync {
    return Intl.message('Sync', name: 'sync', desc: '', args: []);
  }

  /// `Hide from recent tasks`
  String get exclude {
    return Intl.message(
      'Hide from recent tasks',
      name: 'exclude',
      desc: '',
      args: [],
    );
  }

  /// `Hide the app from recent tasks while it is in the background`
  String get excludeDesc {
    return Intl.message(
      'Hide the app from recent tasks while it is in the background',
      name: 'excludeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Standard`
  String get expand {
    return Intl.message('Standard', name: 'expand', desc: '', args: []);
  }

  /// `Compact`
  String get shrink {
    return Intl.message('Compact', name: 'shrink', desc: '', args: []);
  }

  /// `Minimal`
  String get min {
    return Intl.message('Minimal', name: 'min', desc: '', args: []);
  }

  /// `Tab`
  String get tab {
    return Intl.message('Tab', name: 'tab', desc: '', args: []);
  }

  /// `List`
  String get list {
    return Intl.message('List', name: 'list', desc: '', args: []);
  }

  /// `Delay`
  String get delay {
    return Intl.message('Delay', name: 'delay', desc: '', args: []);
  }

  /// `Style`
  String get style {
    return Intl.message('Style', name: 'style', desc: '', args: []);
  }

  /// `Size`
  String get size {
    return Intl.message('Size', name: 'size', desc: '', args: []);
  }

  /// `Sort`
  String get sort {
    return Intl.message('Sort', name: 'sort', desc: '', args: []);
  }

  /// `Columns`
  String get columns {
    return Intl.message('Columns', name: 'columns', desc: '', args: []);
  }

  /// `Proxy group`
  String get proxyGroup {
    return Intl.message('Proxy group', name: 'proxyGroup', desc: '', args: []);
  }

  /// `Go`
  String get go {
    return Intl.message('Go', name: 'go', desc: '', args: []);
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

  /// `Auto close connections`
  String get autoCloseConnections {
    return Intl.message(
      'Auto close connections',
      name: 'autoCloseConnections',
      desc: '',
      args: [],
    );
  }

  /// `Close connections automatically after switching nodes`
  String get autoCloseConnectionsDesc {
    return Intl.message(
      'Close connections automatically after switching nodes',
      name: 'autoCloseConnectionsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Only count proxy traffic`
  String get onlyStatisticsProxy {
    return Intl.message(
      'Only count proxy traffic',
      name: 'onlyStatisticsProxy',
      desc: '',
      args: [],
    );
  }

  /// `When enabled, only proxy traffic is counted`
  String get onlyStatisticsProxyDesc {
    return Intl.message(
      'When enabled, only proxy traffic is counted',
      name: 'onlyStatisticsProxyDesc',
      desc: '',
      args: [],
    );
  }

  /// `Pure black mode`
  String get pureBlackMode {
    return Intl.message(
      'Pure black mode',
      name: 'pureBlackMode',
      desc: '',
      args: [],
    );
  }

  /// `TCP keep-alive interval`
  String get keepAliveIntervalDesc {
    return Intl.message(
      'TCP keep-alive interval',
      name: 'keepAliveIntervalDesc',
      desc: '',
      args: [],
    );
  }

  /// ` entries`
  String get entries {
    return Intl.message(' entries', name: 'entries', desc: '', args: []);
  }

  /// `Local`
  String get local {
    return Intl.message('Local', name: 'local', desc: '', args: []);
  }

  /// `Remote`
  String get remote {
    return Intl.message('Remote', name: 'remote', desc: '', args: []);
  }

  /// `Back up data to WebDAV`
  String get remoteBackupDesc {
    return Intl.message(
      'Back up data to WebDAV',
      name: 'remoteBackupDesc',
      desc: '',
      args: [],
    );
  }

  /// `Back up data locally`
  String get localBackupDesc {
    return Intl.message(
      'Back up data locally',
      name: 'localBackupDesc',
      desc: '',
      args: [],
    );
  }

  /// `Mode`
  String get mode {
    return Intl.message('Mode', name: 'mode', desc: '', args: []);
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `Source`
  String get source {
    return Intl.message('Source', name: 'source', desc: '', args: []);
  }

  /// `Action`
  String get action {
    return Intl.message('Action', name: 'action', desc: '', args: []);
  }

  /// `Smart selection`
  String get intelligentSelected {
    return Intl.message(
      'Smart selection',
      name: 'intelligentSelected',
      desc: '',
      args: [],
    );
  }

  /// `Import from clipboard`
  String get clipboardImport {
    return Intl.message(
      'Import from clipboard',
      name: 'clipboardImport',
      desc: '',
      args: [],
    );
  }

  /// `Export to clipboard`
  String get clipboardExport {
    return Intl.message(
      'Export to clipboard',
      name: 'clipboardExport',
      desc: '',
      args: [],
    );
  }

  /// `Layout`
  String get layout {
    return Intl.message('Layout', name: 'layout', desc: '', args: []);
  }

  /// `Tight`
  String get tight {
    return Intl.message('Tight', name: 'tight', desc: '', args: []);
  }

  /// `Standard`
  String get standard {
    return Intl.message('Standard', name: 'standard', desc: '', args: []);
  }

  /// `Loose`
  String get loose {
    return Intl.message('Loose', name: 'loose', desc: '', args: []);
  }

  /// `Sort profiles`
  String get profilesSort {
    return Intl.message(
      'Sort profiles',
      name: 'profilesSort',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message('Start', name: 'start', desc: '', args: []);
  }

  /// `Stop`
  String get stop {
    return Intl.message('Stop', name: 'stop', desc: '', args: []);
  }

  /// `Update DNS-related settings`
  String get dnsDesc {
    return Intl.message(
      'Update DNS-related settings',
      name: 'dnsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Key`
  String get key {
    return Intl.message('Key', name: 'key', desc: '', args: []);
  }

  /// `Value`
  String get value {
    return Intl.message('Value', name: 'value', desc: '', args: []);
  }

  /// `Append hosts`
  String get hostsDesc {
    return Intl.message('Append hosts', name: 'hostsDesc', desc: '', args: []);
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

  /// `Route all system traffic through VpnService automatically`
  String get vpnEnableDesc {
    return Intl.message(
      'Route all system traffic through VpnService automatically',
      name: 'vpnEnableDesc',
      desc: '',
      args: [],
    );
  }

  /// `Options`
  String get options {
    return Intl.message('Options', name: 'options', desc: '', args: []);
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

  /// `Used for UWP loopback exemption`
  String get loopbackDesc {
    return Intl.message(
      'Used for UWP loopback exemption',
      name: 'loopbackDesc',
      desc: '',
      args: [],
    );
  }

  /// `External resources`
  String get providers {
    return Intl.message(
      'External resources',
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

  /// `Subscription info`
  String get subscriptionInfo {
    return Intl.message(
      'Subscription info',
      name: 'subscriptionInfo',
      desc: '',
      args: [],
    );
  }

  /// `Override DNS`
  String get overrideDns {
    return Intl.message(
      'Override DNS',
      name: 'overrideDns',
      desc: '',
      args: [],
    );
  }

  /// `When enabled, the DNS options in the profile are overridden`
  String get overrideDnsDesc {
    return Intl.message(
      'When enabled, the DNS options in the profile are overridden',
      name: 'overrideDnsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `When disabled, the system DNS is used`
  String get statusDesc {
    return Intl.message(
      'When disabled, the system DNS is used',
      name: 'statusDesc',
      desc: '',
      args: [],
    );
  }

  /// `Prefer HTTP/3 for DoH`
  String get preferH3Desc {
    return Intl.message(
      'Prefer HTTP/3 for DoH',
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

  /// `DNS connections follow rules; requires proxy-server-nameserver`
  String get respectRulesDesc {
    return Intl.message(
      'DNS connections follow rules; requires proxy-server-nameserver',
      name: 'respectRulesDesc',
      desc: '',
      args: [],
    );
  }

  /// `DNS mode`
  String get dnsMode {
    return Intl.message('DNS mode', name: 'dnsMode', desc: '', args: []);
  }

  /// `Fake-IP range`
  String get fakeipRange {
    return Intl.message(
      'Fake-IP range',
      name: 'fakeipRange',
      desc: '',
      args: [],
    );
  }

  /// `Fake-IP filter`
  String get fakeipFilter {
    return Intl.message(
      'Fake-IP filter',
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

  /// `Used to resolve DNS servers`
  String get defaultNameserverDesc {
    return Intl.message(
      'Used to resolve DNS servers',
      name: 'defaultNameserverDesc',
      desc: '',
      args: [],
    );
  }

  /// `Nameserver`
  String get nameserver {
    return Intl.message('Nameserver', name: 'nameserver', desc: '', args: []);
  }

  /// `Used to resolve domains`
  String get nameserverDesc {
    return Intl.message(
      'Used to resolve domains',
      name: 'nameserverDesc',
      desc: '',
      args: [],
    );
  }

  /// `Use hosts`
  String get useHosts {
    return Intl.message('Use hosts', name: 'useHosts', desc: '', args: []);
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

  /// `Specify the nameserver policy for matching domains`
  String get nameserverPolicyDesc {
    return Intl.message(
      'Specify the nameserver policy for matching domains',
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

  /// `Used to resolve proxy node domains`
  String get proxyNameserverDesc {
    return Intl.message(
      'Used to resolve proxy node domains',
      name: 'proxyNameserverDesc',
      desc: '',
      args: [],
    );
  }

  /// `Fallback`
  String get fallback {
    return Intl.message('Fallback', name: 'fallback', desc: '', args: []);
  }

  /// `Usually an overseas DNS`
  String get fallbackDesc {
    return Intl.message(
      'Usually an overseas DNS',
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

  /// `GeoIP code`
  String get geoipCode {
    return Intl.message('GeoIP code', name: 'geoipCode', desc: '', args: []);
  }

  /// `IP/CIDR`
  String get ipcidr {
    return Intl.message('IP/CIDR', name: 'ipcidr', desc: '', args: []);
  }

  /// `Domain`
  String get domain {
    return Intl.message('Domain', name: 'domain', desc: '', args: []);
  }

  /// `Reset`
  String get reset {
    return Intl.message('Reset', name: 'reset', desc: '', args: []);
  }

  /// `Show/Hide`
  String get actionView {
    return Intl.message('Show/Hide', name: 'actionView', desc: '', args: []);
  }

  /// `Start/Stop`
  String get actionStart {
    return Intl.message('Start/Stop', name: 'actionStart', desc: '', args: []);
  }

  /// `Switch mode`
  String get actionMode {
    return Intl.message('Switch mode', name: 'actionMode', desc: '', args: []);
  }

  /// `System proxy`
  String get actionProxy {
    return Intl.message(
      'System proxy',
      name: 'actionProxy',
      desc: '',
      args: [],
    );
  }

  /// `TUN`
  String get actionTun {
    return Intl.message('TUN', name: 'actionTun', desc: '', args: []);
  }

  /// `Disclaimer`
  String get disclaimer {
    return Intl.message('Disclaimer', name: 'disclaimer', desc: '', args: []);
  }

  /// `This software is intended only for non-commercial uses such as learning and research. Using it for any commercial purpose is strictly prohibited; any commercial activity is unrelated to this software.`
  String get disclaimerDesc {
    return Intl.message(
      'This software is intended only for non-commercial uses such as learning and research. Using it for any commercial purpose is strictly prohibited; any commercial activity is unrelated to this software.',
      name: 'disclaimerDesc',
      desc: '',
      args: [],
    );
  }

  /// `Agree`
  String get agree {
    return Intl.message('Agree', name: 'agree', desc: '', args: []);
  }

  /// `Hotkey management`
  String get hotkeyManagement {
    return Intl.message(
      'Hotkey management',
      name: 'hotkeyManagement',
      desc: '',
      args: [],
    );
  }

  /// `Control the app with the keyboard`
  String get hotkeyManagementDesc {
    return Intl.message(
      'Control the app with the keyboard',
      name: 'hotkeyManagementDesc',
      desc: '',
      args: [],
    );
  }

  /// `Please press a key`
  String get pressKeyboard {
    return Intl.message(
      'Please press a key',
      name: 'pressKeyboard',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid hotkey`
  String get inputCorrectHotkey {
    return Intl.message(
      'Please enter a valid hotkey',
      name: 'inputCorrectHotkey',
      desc: '',
      args: [],
    );
  }

  /// `Hotkey conflict`
  String get hotkeyConflict {
    return Intl.message(
      'Hotkey conflict',
      name: 'hotkeyConflict',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message('Remove', name: 'remove', desc: '', args: []);
  }

  /// `No hotkeys yet`
  String get noHotKey {
    return Intl.message('No hotkeys yet', name: 'noHotKey', desc: '', args: []);
  }

  /// `No network`
  String get noNetwork {
    return Intl.message('No network', name: 'noNetwork', desc: '', args: []);
  }

  /// `Allow IPv6 inbound`
  String get ipv6InboundDesc {
    return Intl.message(
      'Allow IPv6 inbound',
      name: 'ipv6InboundDesc',
      desc: '',
      args: [],
    );
  }

  /// `Export logs`
  String get exportLogs {
    return Intl.message('Export logs', name: 'exportLogs', desc: '', args: []);
  }

  /// `Export successful`
  String get exportSuccess {
    return Intl.message(
      'Export successful',
      name: 'exportSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Icon style`
  String get iconStyle {
    return Intl.message('Icon style', name: 'iconStyle', desc: '', args: []);
  }

  /// `Icon only`
  String get onlyIcon {
    return Intl.message('Icon only', name: 'onlyIcon', desc: '', args: []);
  }

  /// `Stack mode`
  String get stackMode {
    return Intl.message('Stack mode', name: 'stackMode', desc: '', args: []);
  }

  /// `Network`
  String get network {
    return Intl.message('Network', name: 'network', desc: '', args: []);
  }

  /// `Adjust network-related settings`
  String get networkDesc {
    return Intl.message(
      'Adjust network-related settings',
      name: 'networkDesc',
      desc: '',
      args: [],
    );
  }

  /// `Bypass domains`
  String get bypassDomain {
    return Intl.message(
      'Bypass domains',
      name: 'bypassDomain',
      desc: '',
      args: [],
    );
  }

  /// `Only takes effect while the system proxy is enabled`
  String get bypassDomainDesc {
    return Intl.message(
      'Only takes effect while the system proxy is enabled',
      name: 'bypassDomainDesc',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to reset?`
  String get resetTip {
    return Intl.message(
      'Are you sure you want to reset?',
      name: 'resetTip',
      desc: '',
      args: [],
    );
  }

  /// `Icon`
  String get icon {
    return Intl.message('Icon', name: 'icon', desc: '', args: []);
  }

  /// `No data`
  String get noData {
    return Intl.message('No data', name: 'noData', desc: '', args: []);
  }

  /// `Font family`
  String get fontFamily {
    return Intl.message('Font family', name: 'fontFamily', desc: '', args: []);
  }

  /// `Toggle`
  String get toggle {
    return Intl.message('Toggle', name: 'toggle', desc: '', args: []);
  }

  /// `System`
  String get system {
    return Intl.message('System', name: 'system', desc: '', args: []);
  }

  /// `Route mode`
  String get routeMode {
    return Intl.message('Route mode', name: 'routeMode', desc: '', args: []);
  }

  /// `Bypass private addresses`
  String get routeModeBypassPrivate {
    return Intl.message(
      'Bypass private addresses',
      name: 'routeModeBypassPrivate',
      desc: '',
      args: [],
    );
  }

  /// `Use config`
  String get routeModeConfig {
    return Intl.message(
      'Use config',
      name: 'routeModeConfig',
      desc: '',
      args: [],
    );
  }

  /// `Route addresses`
  String get routeAddress {
    return Intl.message(
      'Route addresses',
      name: 'routeAddress',
      desc: '',
      args: [],
    );
  }

  /// `Configure the listened route addresses`
  String get routeAddressDesc {
    return Intl.message(
      'Configure the listened route addresses',
      name: 'routeAddressDesc',
      desc: '',
      args: [],
    );
  }

  /// `Outbound interface`
  String get interfaceNameMode {
    return Intl.message(
      'Outbound interface',
      name: 'interfaceNameMode',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get interfaceNameModeClear {
    return Intl.message(
      'Clear',
      name: 'interfaceNameModeClear',
      desc: '',
      args: [],
    );
  }

  /// `Follow config`
  String get interfaceNameModeFollow {
    return Intl.message(
      'Follow config',
      name: 'interfaceNameModeFollow',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get interfaceNameModeCustom {
    return Intl.message(
      'Custom',
      name: 'interfaceNameModeCustom',
      desc: '',
      args: [],
    );
  }

  /// `Interface name`
  String get interfaceName {
    return Intl.message(
      'Interface name',
      name: 'interfaceName',
      desc: '',
      args: [],
    );
  }

  /// `Network interface used for outbound connections`
  String get interfaceNameDesc {
    return Intl.message(
      'Network interface used for outbound connections',
      name: 'interfaceNameDesc',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the administrator password`
  String get pleaseInputAdminPassword {
    return Intl.message(
      'Please enter the administrator password',
      name: 'pleaseInputAdminPassword',
      desc: '',
      args: [],
    );
  }

  /// `Copy environment variables`
  String get copyEnvVar {
    return Intl.message(
      'Copy environment variables',
      name: 'copyEnvVar',
      desc: '',
      args: [],
    );
  }

  /// `Memory info`
  String get memoryInfo {
    return Intl.message('Memory info', name: 'memoryInfo', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `The file has been modified. Save the changes?`
  String get fileIsUpdate {
    return Intl.message(
      'The file has been modified. Save the changes?',
      name: 'fileIsUpdate',
      desc: '',
      args: [],
    );
  }

  /// `The profile has been modified. Turn off auto update?`
  String get profileHasUpdate {
    return Intl.message(
      'The profile has been modified. Turn off auto update?',
      name: 'profileHasUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Cache the changes?`
  String get hasCacheChange {
    return Intl.message(
      'Cache the changes?',
      name: 'hasCacheChange',
      desc: '',
      args: [],
    );
  }

  /// `Copied successfully`
  String get copySuccess {
    return Intl.message(
      'Copied successfully',
      name: 'copySuccess',
      desc: '',
      args: [],
    );
  }

  /// `Copy link`
  String get copyLink {
    return Intl.message('Copy link', name: 'copyLink', desc: '', args: []);
  }

  /// `Export file`
  String get exportFile {
    return Intl.message('Export file', name: 'exportFile', desc: '', args: []);
  }

  /// `The cache is corrupted. Clear it?`
  String get cacheCorrupt {
    return Intl.message(
      'The cache is corrupted. Clear it?',
      name: 'cacheCorrupt',
      desc: '',
      args: [],
    );
  }

  /// `Relies on a third-party API; for reference only`
  String get detectionTip {
    return Intl.message(
      'Relies on a third-party API; for reference only',
      name: 'detectionTip',
      desc: '',
      args: [],
    );
  }

  /// `Listen`
  String get listen {
    return Intl.message('Listen', name: 'listen', desc: '', args: []);
  }

  /// `Undo`
  String get undo {
    return Intl.message('Undo', name: 'undo', desc: '', args: []);
  }

  /// `Redo`
  String get redo {
    return Intl.message('Redo', name: 'redo', desc: '', args: []);
  }

  /// `None`
  String get none {
    return Intl.message('None', name: 'none', desc: '', args: []);
  }

  /// `Basic configuration`
  String get basicConfig {
    return Intl.message(
      'Basic configuration',
      name: 'basicConfig',
      desc: '',
      args: [],
    );
  }

  /// `Modify the basic configuration globally`
  String get basicConfigDesc {
    return Intl.message(
      'Modify the basic configuration globally',
      name: 'basicConfigDesc',
      desc: '',
      args: [],
    );
  }

  /// `Advanced configuration`
  String get advancedConfig {
    return Intl.message(
      'Advanced configuration',
      name: 'advancedConfig',
      desc: '',
      args: [],
    );
  }

  /// `Provides diverse configuration options`
  String get advancedConfigDesc {
    return Intl.message(
      'Provides diverse configuration options',
      name: 'advancedConfigDesc',
      desc: '',
      args: [],
    );
  }

  /// `{count} selected`
  String selectedCountTitle(Object count) {
    return Intl.message(
      '$count selected',
      name: 'selectedCountTitle',
      desc: '',
      args: [count],
    );
  }

  /// `Add rule`
  String get addRule {
    return Intl.message('Add rule', name: 'addRule', desc: '', args: []);
  }

  /// `Rule name`
  String get ruleName {
    return Intl.message('Rule name', name: 'ruleName', desc: '', args: []);
  }

  /// `Content`
  String get content {
    return Intl.message('Content', name: 'content', desc: '', args: []);
  }

  /// `Sub-rule`
  String get subRule {
    return Intl.message('Sub-rule', name: 'subRule', desc: '', args: []);
  }

  /// `Rule target`
  String get ruleTarget {
    return Intl.message('Rule target', name: 'ruleTarget', desc: '', args: []);
  }

  /// `Match target`
  String get matchTargetTitle {
    return Intl.message(
      'Match target',
      name: 'matchTargetTitle',
      desc: '',
      args: [],
    );
  }

  /// `MATCH-TARGET`
  String get matchTarget {
    return Intl.message(
      'MATCH-TARGET',
      name: 'matchTarget',
      desc: '',
      args: [],
    );
  }

  /// `Follow profile`
  String get followProfile {
    return Intl.message(
      'Follow profile',
      name: 'followProfile',
      desc: '',
      args: [],
    );
  }

  /// `Where rules targeting MATCH-TARGET go. Defaults to the target of the final MATCH rule in this profile.`
  String get matchTargetDesc {
    return Intl.message(
      'Where rules targeting MATCH-TARGET go. Defaults to the target of the final MATCH rule in this profile.',
      name: 'matchTargetDesc',
      desc: '',
      args: [],
    );
  }

  /// `Select MATCH-TARGET`
  String get selectMatchTarget {
    return Intl.message(
      'Select MATCH-TARGET',
      name: 'selectMatchTarget',
      desc: '',
      args: [],
    );
  }

  /// `Source IP`
  String get sourceIp {
    return Intl.message('Source IP', name: 'sourceIp', desc: '', args: []);
  }

  /// `Don't resolve IP`
  String get noResolve {
    return Intl.message(
      'Don\'t resolve IP',
      name: 'noResolve',
      desc: '',
      args: [],
    );
  }

  /// `Save the changes?`
  String get saveChanges {
    return Intl.message(
      'Save the changes?',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Enabling causes some performance loss`
  String get findProcessModeDesc {
    return Intl.message(
      'Enabling causes some performance loss',
      name: 'findProcessModeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Only effective in mobile view`
  String get tabAnimationDesc {
    return Intl.message(
      'Only effective in mobile view',
      name: 'tabAnimationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Color schemes`
  String get colorSchemes {
    return Intl.message(
      'Color schemes',
      name: 'colorSchemes',
      desc: '',
      args: [],
    );
  }

  /// `Palette`
  String get palette {
    return Intl.message('Palette', name: 'palette', desc: '', args: []);
  }

  /// `Tonal spot`
  String get tonalSpotScheme {
    return Intl.message(
      'Tonal spot',
      name: 'tonalSpotScheme',
      desc: '',
      args: [],
    );
  }

  /// `Fidelity`
  String get fidelityScheme {
    return Intl.message('Fidelity', name: 'fidelityScheme', desc: '', args: []);
  }

  /// `Monochrome`
  String get monochromeScheme {
    return Intl.message(
      'Monochrome',
      name: 'monochromeScheme',
      desc: '',
      args: [],
    );
  }

  /// `Neutral`
  String get neutralScheme {
    return Intl.message('Neutral', name: 'neutralScheme', desc: '', args: []);
  }

  /// `Vibrant`
  String get vibrantScheme {
    return Intl.message('Vibrant', name: 'vibrantScheme', desc: '', args: []);
  }

  /// `Expressive`
  String get expressiveScheme {
    return Intl.message(
      'Expressive',
      name: 'expressiveScheme',
      desc: '',
      args: [],
    );
  }

  /// `Content`
  String get contentScheme {
    return Intl.message('Content', name: 'contentScheme', desc: '', args: []);
  }

  /// `Rainbow`
  String get rainbowScheme {
    return Intl.message('Rainbow', name: 'rainbowScheme', desc: '', args: []);
  }

  /// `Fruit salad`
  String get fruitSaladScheme {
    return Intl.message(
      'Fruit salad',
      name: 'fruitSaladScheme',
      desc: '',
      args: [],
    );
  }

  /// `Developer mode`
  String get developerMode {
    return Intl.message(
      'Developer mode',
      name: 'developerMode',
      desc: '',
      args: [],
    );
  }

  /// `Developer mode is enabled.`
  String get developerModeEnableTip {
    return Intl.message(
      'Developer mode is enabled.',
      name: 'developerModeEnableTip',
      desc: '',
      args: [],
    );
  }

  /// `Message test`
  String get messageTest {
    return Intl.message(
      'Message test',
      name: 'messageTest',
      desc: '',
      args: [],
    );
  }

  /// `This is a message.`
  String get messageTestTip {
    return Intl.message(
      'This is a message.',
      name: 'messageTestTip',
      desc: '',
      args: [],
    );
  }

  /// `Crash test`
  String get crashTest {
    return Intl.message('Crash test', name: 'crashTest', desc: '', args: []);
  }

  /// `Crash detected`
  String get crashDetected {
    return Intl.message(
      'Crash detected',
      name: 'crashDetected',
      desc: '',
      args: [],
    );
  }

  /// `The app failed to finish launching twice in a row. To break the loop, the profile {name} has been deselected and automatic setup was skipped. You can select it again at any time.`
  String crashDetectedTip(Object name) {
    return Intl.message(
      'The app failed to finish launching twice in a row. To break the loop, the profile $name has been deselected and automatic setup was skipped. You can select it again at any time.',
      name: 'crashDetectedTip',
      desc: '',
      args: [name],
    );
  }

  /// `Launch did not finish`
  String get launchInterrupted {
    return Intl.message(
      'Launch did not finish',
      name: 'launchInterrupted',
      desc: '',
      args: [],
    );
  }

  /// `The app exited unexpectedly while it was starting up last time. Automatic setup was skipped for this launch; you can start it manually to retry.`
  String get launchInterruptedTip {
    return Intl.message(
      'The app exited unexpectedly while it was starting up last time. Automatic setup was skipped for this launch; you can start it manually to retry.',
      name: 'launchInterruptedTip',
      desc: '',
      args: [],
    );
  }

  /// `Clear data`
  String get clearData {
    return Intl.message('Clear data', name: 'clearData', desc: '', args: []);
  }

  /// `Text scaling`
  String get textScale {
    return Intl.message('Text scaling', name: 'textScale', desc: '', args: []);
  }

  /// `Internet`
  String get internet {
    return Intl.message('Internet', name: 'internet', desc: '', args: []);
  }

  /// `System apps`
  String get systemApp {
    return Intl.message('System apps', name: 'systemApp', desc: '', args: []);
  }

  /// `No-network apps`
  String get noNetworkApp {
    return Intl.message(
      'No-network apps',
      name: 'noNetworkApp',
      desc: '',
      args: [],
    );
  }

  /// `Restore strategy`
  String get restoreStrategy {
    return Intl.message(
      'Restore strategy',
      name: 'restoreStrategy',
      desc: '',
      args: [],
    );
  }

  /// `Override`
  String get restoreStrategyOverride {
    return Intl.message(
      'Override',
      name: 'restoreStrategyOverride',
      desc: '',
      args: [],
    );
  }

  /// `Compatible`
  String get restoreStrategyCompatible {
    return Intl.message(
      'Compatible',
      name: 'restoreStrategyCompatible',
      desc: '',
      args: [],
    );
  }

  /// `Logs test`
  String get logsTest {
    return Intl.message('Logs test', name: 'logsTest', desc: '', args: []);
  }

  /// `{label} cannot be empty`
  String emptyTip(Object label) {
    return Intl.message(
      '$label cannot be empty',
      name: 'emptyTip',
      desc: '',
      args: [label],
    );
  }

  /// `{label} must be a URL`
  String urlTip(Object label) {
    return Intl.message(
      '$label must be a URL',
      name: 'urlTip',
      desc: '',
      args: [label],
    );
  }

  /// `{label} must be a number`
  String numberTip(Object label) {
    return Intl.message(
      '$label must be a number',
      name: 'numberTip',
      desc: '',
      args: [label],
    );
  }

  /// `Interval`
  String get interval {
    return Intl.message('Interval', name: 'interval', desc: '', args: []);
  }

  /// `{label} already exists`
  String existsTip(Object label) {
    return Intl.message(
      '$label already exists',
      name: 'existsTip',
      desc: '',
      args: [label],
    );
  }

  /// `{label} must be at most {max} characters`
  String maxLengthTip(Object label, Object max) {
    return Intl.message(
      '$label must be at most $max characters',
      name: 'maxLengthTip',
      desc: '',
      args: [label, max],
    );
  }

  /// `Separate multiple values with commas`
  String get multipleValuesTip {
    return Intl.message(
      'Separate multiple values with commas',
      name: 'multipleValuesTip',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this {label}?`
  String deleteTip(Object label) {
    return Intl.message(
      'Are you sure you want to delete this $label?',
      name: 'deleteTip',
      desc: '',
      args: [label],
    );
  }

  /// `Are you sure you want to delete the selected {label}?`
  String deleteMultipTip(Object label) {
    return Intl.message(
      'Are you sure you want to delete the selected $label?',
      name: 'deleteMultipTip',
      desc: '',
      args: [label],
    );
  }

  /// `No {label} yet`
  String nullTip(Object label) {
    return Intl.message(
      'No $label yet',
      name: 'nullTip',
      desc: '',
      args: [label],
    );
  }

  /// `Script`
  String get script {
    return Intl.message('Script', name: 'script', desc: '', args: []);
  }

  /// `Color`
  String get color {
    return Intl.message('Color', name: 'color', desc: '', args: []);
  }

  /// `Unnamed`
  String get unnamed {
    return Intl.message('Unnamed', name: 'unnamed', desc: '', args: []);
  }

  /// `Please enter a script name`
  String get pleaseEnterScriptName {
    return Intl.message(
      'Please enter a script name',
      name: 'pleaseEnterScriptName',
      desc: '',
      args: [],
    );
  }

  /// `Mixed port`
  String get mixedPort {
    return Intl.message('Mixed port', name: 'mixedPort', desc: '', args: []);
  }

  /// `SOCKS port`
  String get socksPort {
    return Intl.message('SOCKS port', name: 'socksPort', desc: '', args: []);
  }

  /// `Redir port`
  String get redirPort {
    return Intl.message('Redir port', name: 'redirPort', desc: '', args: []);
  }

  /// `TProxy port`
  String get tproxyPort {
    return Intl.message('TProxy port', name: 'tproxyPort', desc: '', args: []);
  }

  /// `{label} must be between 1024 and 49151`
  String portTip(Object label) {
    return Intl.message(
      '$label must be between 1024 and 49151',
      name: 'portTip',
      desc: '',
      args: [label],
    );
  }

  /// `Please enter a different port`
  String get portConflictTip {
    return Intl.message(
      'Please enter a different port',
      name: 'portConflictTip',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get import {
    return Intl.message('Import', name: 'import', desc: '', args: []);
  }

  /// `Import from file`
  String get importFile {
    return Intl.message(
      'Import from file',
      name: 'importFile',
      desc: '',
      args: [],
    );
  }

  /// `Import from URL`
  String get importUrl {
    return Intl.message(
      'Import from URL',
      name: 'importUrl',
      desc: '',
      args: [],
    );
  }

  /// `Auto-set system DNS`
  String get autoSetSystemDns {
    return Intl.message(
      'Auto-set system DNS',
      name: 'autoSetSystemDns',
      desc: '',
      args: [],
    );
  }

  /// `{label} details`
  String details(Object label) {
    return Intl.message(
      '$label details',
      name: 'details',
      desc: '',
      args: [label],
    );
  }

  /// `Creation time`
  String get creationTime {
    return Intl.message(
      'Creation time',
      name: 'creationTime',
      desc: '',
      args: [],
    );
  }

  /// `Process`
  String get process {
    return Intl.message('Process', name: 'process', desc: '', args: []);
  }

  /// `Host`
  String get host {
    return Intl.message('Host', name: 'host', desc: '', args: []);
  }

  /// `Destination`
  String get destination {
    return Intl.message('Destination', name: 'destination', desc: '', args: []);
  }

  /// `Destination GeoIP`
  String get destinationGeoIP {
    return Intl.message(
      'Destination GeoIP',
      name: 'destinationGeoIP',
      desc: '',
      args: [],
    );
  }

  /// `Destination IP ASN`
  String get destinationIPASN {
    return Intl.message(
      'Destination IP ASN',
      name: 'destinationIPASN',
      desc: '',
      args: [],
    );
  }

  /// `Special proxy`
  String get specialProxy {
    return Intl.message(
      'Special proxy',
      name: 'specialProxy',
      desc: '',
      args: [],
    );
  }

  /// `Special rules`
  String get specialRules {
    return Intl.message(
      'Special rules',
      name: 'specialRules',
      desc: '',
      args: [],
    );
  }

  /// `Remote destination`
  String get remoteDestination {
    return Intl.message(
      'Remote destination',
      name: 'remoteDestination',
      desc: '',
      args: [],
    );
  }

  /// `Network type`
  String get networkType {
    return Intl.message(
      'Network type',
      name: 'networkType',
      desc: '',
      args: [],
    );
  }

  /// `Proxy chain`
  String get proxyChains {
    return Intl.message('Proxy chain', name: 'proxyChains', desc: '', args: []);
  }

  /// `Log`
  String get log {
    return Intl.message('Log', name: 'log', desc: '', args: []);
  }

  /// `Connection`
  String get connection {
    return Intl.message('Connection', name: 'connection', desc: '', args: []);
  }

  /// `Request`
  String get request {
    return Intl.message('Request', name: 'request', desc: '', args: []);
  }

  /// `Connected`
  String get connected {
    return Intl.message('Connected', name: 'connected', desc: '', args: []);
  }

  /// `Disconnected`
  String get disconnected {
    return Intl.message(
      'Disconnected',
      name: 'disconnected',
      desc: '',
      args: [],
    );
  }

  /// `Connecting...`
  String get connecting {
    return Intl.message(
      'Connecting...',
      name: 'connecting',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to restart the core?`
  String get restartCoreTip {
    return Intl.message(
      'Are you sure you want to restart the core?',
      name: 'restartCoreTip',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to force restart the core?`
  String get forceRestartCoreTip {
    return Intl.message(
      'Are you sure you want to force restart the core?',
      name: 'forceRestartCoreTip',
      desc: '',
      args: [],
    );
  }

  /// `DNS hijacking`
  String get dnsHijacking {
    return Intl.message(
      'DNS hijacking',
      name: 'dnsHijacking',
      desc: '',
      args: [],
    );
  }

  /// `Core status`
  String get coreStatus {
    return Intl.message('Core status', name: 'coreStatus', desc: '', args: []);
  }

  /// `Data collection notice`
  String get dataCollectionTip {
    return Intl.message(
      'Data collection notice',
      name: 'dataCollectionTip',
      desc: '',
      args: [],
    );
  }

  /// `This app uses Firebase Crashlytics to collect crash information to improve stability.\nThe collected data includes device information and crash details, and contains no personally sensitive data.\nYou can turn this off in settings.`
  String get dataCollectionContent {
    return Intl.message(
      'This app uses Firebase Crashlytics to collect crash information to improve stability.\nThe collected data includes device information and crash details, and contains no personally sensitive data.\nYou can turn this off in settings.',
      name: 'dataCollectionContent',
      desc: '',
      args: [],
    );
  }

  /// `Crash analytics`
  String get crashlytics {
    return Intl.message(
      'Crash analytics',
      name: 'crashlytics',
      desc: '',
      args: [],
    );
  }

  /// `When enabled, crash logs without sensitive information are uploaded automatically when the app crashes`
  String get crashlyticsTip {
    return Intl.message(
      'When enabled, crash logs without sensitive information are uploaded automatically when the app crashes',
      name: 'crashlyticsTip',
      desc: '',
      args: [],
    );
  }

  /// `Append system DNS`
  String get appendSystemDns {
    return Intl.message(
      'Append system DNS',
      name: 'appendSystemDns',
      desc: '',
      args: [],
    );
  }

  /// `Force-append the system DNS to the configuration`
  String get appendSystemDnsTip {
    return Intl.message(
      'Force-append the system DNS to the configuration',
      name: 'appendSystemDnsTip',
      desc: '',
      args: [],
    );
  }

  /// `Edit rule`
  String get editRule {
    return Intl.message('Edit rule', name: 'editRule', desc: '', args: []);
  }

  /// `Override mode`
  String get overrideMode {
    return Intl.message(
      'Override mode',
      name: 'overrideMode',
      desc: '',
      args: [],
    );
  }

  /// `Standard mode: overrides the basic configuration and offers simple rule additions`
  String get standardModeDesc {
    return Intl.message(
      'Standard mode: overrides the basic configuration and offers simple rule additions',
      name: 'standardModeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Script mode: uses external extension scripts to override the configuration in one click`
  String get scriptModeDesc {
    return Intl.message(
      'Script mode: uses external extension scripts to override the configuration in one click',
      name: 'scriptModeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Added rules`
  String get addedRules {
    return Intl.message('Added rules', name: 'addedRules', desc: '', args: []);
  }

  /// `Control global added rules`
  String get controlGlobalAddedRules {
    return Intl.message(
      'Control global added rules',
      name: 'controlGlobalAddedRules',
      desc: '',
      args: [],
    );
  }

  /// `Override script`
  String get overrideScript {
    return Intl.message(
      'Override script',
      name: 'overrideScript',
      desc: '',
      args: [],
    );
  }

  /// `Go to script configuration`
  String get goToConfigureScript {
    return Intl.message(
      'Go to script configuration',
      name: 'goToConfigureScript',
      desc: '',
      args: [],
    );
  }

  /// `Edit global rules`
  String get editGlobalRules {
    return Intl.message(
      'Edit global rules',
      name: 'editGlobalRules',
      desc: '',
      args: [],
    );
  }

  /// `External fetch`
  String get externalFetch {
    return Intl.message(
      'External fetch',
      name: 'externalFetch',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to force crash the core?`
  String get confirmForceCrashCore {
    return Intl.message(
      'Are you sure you want to force crash the core?',
      name: 'confirmForceCrashCore',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to clear all data?`
  String get confirmClearAllData {
    return Intl.message(
      'Are you sure you want to clear all data?',
      name: 'confirmClearAllData',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `{count, plural, =1{1 year ago} other{{count} years ago}}`
  String yearsAgo(num count) {
    return Intl.plural(
      count,
      one: '1 year ago',
      other: '$count years ago',
      name: 'yearsAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 month ago} other{{count} months ago}}`
  String monthsAgo(num count) {
    return Intl.plural(
      count,
      one: '1 month ago',
      other: '$count months ago',
      name: 'monthsAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 day ago} other{{count} days ago}}`
  String daysAgo(num count) {
    return Intl.plural(
      count,
      one: '1 day ago',
      other: '$count days ago',
      name: 'daysAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 hour ago} other{{count} hours ago}}`
  String hoursAgo(num count) {
    return Intl.plural(
      count,
      one: '1 hour ago',
      other: '$count hours ago',
      name: 'hoursAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 minute ago} other{{count} minutes ago}}`
  String minutesAgo(num count) {
    return Intl.plural(
      count,
      one: '1 minute ago',
      other: '$count minutes ago',
      name: 'minutesAgo',
      desc: '',
      args: [count],
    );
  }

  /// `Just now`
  String get justNow {
    return Intl.message('Just now', name: 'justNow', desc: '', args: []);
  }

  /// `Don't remind me again`
  String get noLongerRemind {
    return Intl.message(
      'Don\'t remind me again',
      name: 'noLongerRemind',
      desc: '',
      args: [],
    );
  }

  /// `Access control settings`
  String get accessControlSettings {
    return Intl.message(
      'Access control settings',
      name: 'accessControlSettings',
      desc: '',
      args: [],
    );
  }

  /// `Turn on`
  String get turnOn {
    return Intl.message('Turn on', name: 'turnOn', desc: '', args: []);
  }

  /// `Turn off`
  String get turnOff {
    return Intl.message('Turn off', name: 'turnOff', desc: '', args: []);
  }

  /// `VPN-related configuration change detected`
  String get vpnConfigChangeDetected {
    return Intl.message(
      'VPN-related configuration change detected',
      name: 'vpnConfigChangeDetected',
      desc: '',
      args: [],
    );
  }

  /// `Restart`
  String get restart {
    return Intl.message('Restart', name: 'restart', desc: '', args: []);
  }

  /// `Speed statistics`
  String get speedStatistics {
    return Intl.message(
      'Speed statistics',
      name: 'speedStatistics',
      desc: '',
      args: [],
    );
  }

  /// `This page has changes. Are you sure you want to reset?`
  String get resetPageChangesTip {
    return Intl.message(
      'This page has changes. Are you sure you want to reset?',
      name: 'resetPageChangesTip',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get overwriteTypeCustom {
    return Intl.message(
      'Custom',
      name: 'overwriteTypeCustom',
      desc: '',
      args: [],
    );
  }

  /// `Custom mode: fully customize proxy groups and rules`
  String get overwriteTypeCustomDesc {
    return Intl.message(
      'Custom mode: fully customize proxy groups and rules',
      name: 'overwriteTypeCustomDesc',
      desc: '',
      args: [],
    );
  }

  /// `Unknown network error`
  String get unknownNetworkError {
    return Intl.message(
      'Unknown network error',
      name: 'unknownNetworkError',
      desc: '',
      args: [],
    );
  }

  /// `Restore error`
  String get restoreException {
    return Intl.message(
      'Restore error',
      name: 'restoreException',
      desc: '',
      args: [],
    );
  }

  /// `Network error, please check your connection and try again`
  String get networkException {
    return Intl.message(
      'Network error, please check your connection and try again',
      name: 'networkException',
      desc: '',
      args: [],
    );
  }

  /// `Invalid backup file`
  String get invalidBackupFile {
    return Intl.message(
      'Invalid backup file',
      name: 'invalidBackupFile',
      desc: '',
      args: [],
    );
  }

  /// `Prune cache`
  String get pruneCache {
    return Intl.message('Prune cache', name: 'pruneCache', desc: '', args: []);
  }

  /// `Backup and restore`
  String get backupAndRestore {
    return Intl.message(
      'Backup and restore',
      name: 'backupAndRestore',
      desc: '',
      args: [],
    );
  }

  /// `Sync data via WebDAV or files`
  String get backupAndRestoreDesc {
    return Intl.message(
      'Sync data via WebDAV or files',
      name: 'backupAndRestoreDesc',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get restore {
    return Intl.message('Restore', name: 'restore', desc: '', args: []);
  }

  /// `Restore successful`
  String get restoreSuccess {
    return Intl.message(
      'Restore successful',
      name: 'restoreSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Restore data from WebDAV`
  String get restoreFromWebDAVDesc {
    return Intl.message(
      'Restore data from WebDAV',
      name: 'restoreFromWebDAVDesc',
      desc: '',
      args: [],
    );
  }

  /// `Restore data from a file`
  String get restoreFromFileDesc {
    return Intl.message(
      'Restore data from a file',
      name: 'restoreFromFileDesc',
      desc: '',
      args: [],
    );
  }

  /// `Restore profiles only`
  String get restoreOnlyConfig {
    return Intl.message(
      'Restore profiles only',
      name: 'restoreOnlyConfig',
      desc: '',
      args: [],
    );
  }

  /// `Restore all data`
  String get restoreAllData {
    return Intl.message(
      'Restore all data',
      name: 'restoreAllData',
      desc: '',
      args: [],
    );
  }

  /// `Add profile`
  String get addProfile {
    return Intl.message('Add profile', name: 'addProfile', desc: '', args: []);
  }

  /// `Delay test`
  String get delayTest {
    return Intl.message('Delay test', name: 'delayTest', desc: '', args: []);
  }

  /// `Proxy group is empty`
  String get proxyGroupEmpty {
    return Intl.message(
      'Proxy group is empty',
      name: 'proxyGroupEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Proxy group name cannot be empty`
  String get proxyGroupNameEmpty {
    return Intl.message(
      'Proxy group name cannot be empty',
      name: 'proxyGroupNameEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate proxy group name`
  String get proxyGroupNameDuplicate {
    return Intl.message(
      'Duplicate proxy group name',
      name: 'proxyGroupNameDuplicate',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to exit the current window?`
  String get confirmExitWindow {
    return Intl.message(
      'Are you sure you want to exit the current window?',
      name: 'confirmExitWindow',
      desc: '',
      args: [],
    );
  }

  /// `Data changes detected. Save them?`
  String get dataChangedSave {
    return Intl.message(
      'Data changes detected. Save them?',
      name: 'dataChangedSave',
      desc: '',
      args: [],
    );
  }

  /// `Select proxy providers`
  String get selectProxyProviders {
    return Intl.message(
      'Select proxy providers',
      name: 'selectProxyProviders',
      desc: '',
      args: [],
    );
  }

  /// `Proxy filter`
  String get proxyFilter {
    return Intl.message(
      'Proxy filter',
      name: 'proxyFilter',
      desc: '',
      args: [],
    );
  }

  /// `Optional`
  String get optional {
    return Intl.message('Optional', name: 'optional', desc: '', args: []);
  }

  /// `Max failures`
  String get maxFailedTimes {
    return Intl.message(
      'Max failures',
      name: 'maxFailedTimes',
      desc: '',
      args: [],
    );
  }

  /// `Test interval`
  String get testInterval {
    return Intl.message(
      'Test interval',
      name: 'testInterval',
      desc: '',
      args: [],
    );
  }

  /// `Exclude proxy filter`
  String get excludeProxyFilter {
    return Intl.message(
      'Exclude proxy filter',
      name: 'excludeProxyFilter',
      desc: '',
      args: [],
    );
  }

  /// `Exclude type`
  String get excludeType {
    return Intl.message(
      'Exclude type',
      name: 'excludeType',
      desc: '',
      args: [],
    );
  }

  /// `Expected status`
  String get expectedStatus {
    return Intl.message(
      'Expected status',
      name: 'expectedStatus',
      desc: '',
      args: [],
    );
  }

  /// `Select proxies`
  String get selectProxies {
    return Intl.message(
      'Select proxies',
      name: 'selectProxies',
      desc: '',
      args: [],
    );
  }

  /// `Enter the proxy group name`
  String get inputProxyGroupName {
    return Intl.message(
      'Enter the proxy group name',
      name: 'inputProxyGroupName',
      desc: '',
      args: [],
    );
  }

  /// `Helper service unavailable; TUN mode cannot be enabled. Reinstall FlClash to restore it.`
  String get helperCorruptTip {
    return Intl.message(
      'Helper service unavailable; TUN mode cannot be enabled. Reinstall FlClash to restore it.',
      name: 'helperCorruptTip',
      desc: '',
      args: [],
    );
  }

  /// `Windows refused to run FlClashCore.exe (error {code}). An app control policy such as Smart App Control or AppLocker blocks unsigned programs; allow FlClash in that policy or turn it off, then try again.`
  String coreBlockedByPolicyTip(Object code) {
    return Intl.message(
      'Windows refused to run FlClashCore.exe (error $code). An app control policy such as Smart App Control or AppLocker blocks unsigned programs; allow FlClash in that policy or turn it off, then try again.',
      name: 'coreBlockedByPolicyTip',
      desc: '',
      args: [code],
    );
  }

  /// `Windows Smart App Control blocked FlClashCore.exe because it is not signed. Open Windows Security → App & browser control → Smart App Control settings, choose Off, then start FlClash again. Smart App Control cannot be turned back on without reinstalling Windows.`
  String get coreBlockedBySmartAppControlTip {
    return Intl.message(
      'Windows Smart App Control blocked FlClashCore.exe because it is not signed. Open Windows Security → App & browser control → Smart App Control settings, choose Off, then start FlClash again. Smart App Control cannot be turned back on without reinstalling Windows.',
      name: 'coreBlockedBySmartAppControlTip',
      desc: '',
      args: [],
    );
  }

  /// `Hide from list`
  String get hideFromList {
    return Intl.message(
      'Hide from list',
      name: 'hideFromList',
      desc: '',
      args: [],
    );
  }

  /// `Test when used`
  String get testWhenUsed {
    return Intl.message(
      'Test when used',
      name: 'testWhenUsed',
      desc: '',
      args: [],
    );
  }

  /// `Disable UDP`
  String get disableUDP {
    return Intl.message('Disable UDP', name: 'disableUDP', desc: '', args: []);
  }

  /// `Are you sure you want to delete this proxy group?`
  String get confirmDeleteProxyGroup {
    return Intl.message(
      'Are you sure you want to delete this proxy group?',
      name: 'confirmDeleteProxyGroup',
      desc: '',
      args: [],
    );
  }

  /// `Rule is empty`
  String get ruleEmpty {
    return Intl.message('Rule is empty', name: 'ruleEmpty', desc: '', args: []);
  }

  /// `Enter the rule content`
  String get inputRuleContent {
    return Intl.message(
      'Enter the rule content',
      name: 'inputRuleContent',
      desc: '',
      args: [],
    );
  }

  /// `Rule set`
  String get ruleSet {
    return Intl.message('Rule set', name: 'ruleSet', desc: '', args: []);
  }

  /// `Please select a rule set`
  String get selectRuleSet {
    return Intl.message(
      'Please select a rule set',
      name: 'selectRuleSet',
      desc: '',
      args: [],
    );
  }

  /// `Split strategy`
  String get splitStrategy {
    return Intl.message(
      'Split strategy',
      name: 'splitStrategy',
      desc: '',
      args: [],
    );
  }

  /// `Please select a split strategy`
  String get selectSplitStrategy {
    return Intl.message(
      'Please select a split strategy',
      name: 'selectSplitStrategy',
      desc: '',
      args: [],
    );
  }

  /// `Please select a sub-rule`
  String get selectSubRule {
    return Intl.message(
      'Please select a sub-rule',
      name: 'selectSubRule',
      desc: '',
      args: [],
    );
  }

  /// `Don't resolve hostname`
  String get noResolveHostname {
    return Intl.message(
      'Don\'t resolve hostname',
      name: 'noResolveHostname',
      desc: '',
      args: [],
    );
  }

  /// `Match source IP`
  String get matchSourceIp {
    return Intl.message(
      'Match source IP',
      name: 'matchSourceIp',
      desc: '',
      args: [],
    );
  }

  /// `Basic info`
  String get basicInfo {
    return Intl.message('Basic info', name: 'basicInfo', desc: '', args: []);
  }

  /// `Additional parameters`
  String get additionalParameters {
    return Intl.message(
      'Additional parameters',
      name: 'additionalParameters',
      desc: '',
      args: [],
    );
  }

  /// `Proxy type`
  String get proxyType {
    return Intl.message('Proxy type', name: 'proxyType', desc: '', args: []);
  }

  /// `Basic strategies`
  String get basicStrategy {
    return Intl.message(
      'Basic strategies',
      name: 'basicStrategy',
      desc: '',
      args: [],
    );
  }

  /// `Edit proxy`
  String get editProxy {
    return Intl.message('Edit proxy', name: 'editProxy', desc: '', args: []);
  }

  /// `Include all proxy providers`
  String get includeAllProxyProviders {
    return Intl.message(
      'Include all proxy providers',
      name: 'includeAllProxyProviders',
      desc: '',
      args: [],
    );
  }

  /// `When enabled, the imported proxy providers are overridden`
  String get includeAllProxyProvidersTip {
    return Intl.message(
      'When enabled, the imported proxy providers are overridden',
      name: 'includeAllProxyProvidersTip',
      desc: '',
      args: [],
    );
  }

  /// `Add proxy providers`
  String get addProxyProviders {
    return Intl.message(
      'Add proxy providers',
      name: 'addProxyProviders',
      desc: '',
      args: [],
    );
  }

  /// `Include all proxies`
  String get includeAllProxies {
    return Intl.message(
      'Include all proxies',
      name: 'includeAllProxies',
      desc: '',
      args: [],
    );
  }

  /// `Imports all proxies outside proxy groups; extra proxy groups can be added below`
  String get includeAllProxiesTip {
    return Intl.message(
      'Imports all proxies outside proxy groups; extra proxy groups can be added below',
      name: 'includeAllProxiesTip',
      desc: '',
      args: [],
    );
  }

  /// `Proxies are empty`
  String get proxiesEmpty {
    return Intl.message(
      'Proxies are empty',
      name: 'proxiesEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Add proxies`
  String get addProxies {
    return Intl.message('Add proxies', name: 'addProxies', desc: '', args: []);
  }

  /// `Add proxy group`
  String get addProxyGroup {
    return Intl.message(
      'Add proxy group',
      name: 'addProxyGroup',
      desc: '',
      args: [],
    );
  }

  /// `Edit proxy group`
  String get editProxyGroup {
    return Intl.message(
      'Edit proxy group',
      name: 'editProxyGroup',
      desc: '',
      args: [],
    );
  }

  /// `Confirming will overwrite existing data`
  String get confirmOverwriteTip {
    return Intl.message(
      'Confirming will overwrite existing data',
      name: 'confirmOverwriteTip',
      desc: '',
      args: [],
    );
  }

  /// `Data detected in the configuration`
  String get configDataDetected {
    return Intl.message(
      'Data detected in the configuration',
      name: 'configDataDetected',
      desc: '',
      args: [],
    );
  }

  /// `Quick fill`
  String get quickFill {
    return Intl.message('Quick fill', name: 'quickFill', desc: '', args: []);
  }

  /// `Icon URL`
  String get iconUrl {
    return Intl.message('Icon URL', name: 'iconUrl', desc: '', args: []);
  }

  /// `Icon records`
  String get iconRecords {
    return Intl.message(
      'Icon records',
      name: 'iconRecords',
      desc: '',
      args: [],
    );
  }

  /// `No records`
  String get noRecords {
    return Intl.message('No records', name: 'noRecords', desc: '', args: []);
  }

  /// `Custom`
  String get custom {
    return Intl.message('Custom', name: 'custom', desc: '', args: []);
  }

  /// `Match the full domain`
  String get ruleActionDomainDesc {
    return Intl.message(
      'Match the full domain',
      name: 'ruleActionDomainDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match a domain suffix`
  String get ruleActionDomainSuffixDesc {
    return Intl.message(
      'Match a domain suffix',
      name: 'ruleActionDomainSuffixDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match a domain keyword`
  String get ruleActionDomainKeywordDesc {
    return Intl.message(
      'Match a domain keyword',
      name: 'ruleActionDomainKeywordDesc',
      desc: '',
      args: [],
    );
  }

  /// `Wildcard match; only * and ? are supported`
  String get ruleActionDomainRegexDesc {
    return Intl.message(
      'Wildcard match; only * and ? are supported',
      name: 'ruleActionDomainRegexDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match domains in Geosite`
  String get ruleActionGeositeDesc {
    return Intl.message(
      'Match domains in Geosite',
      name: 'ruleActionGeositeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match an IP address range`
  String get ruleActionIpCidrDesc {
    return Intl.message(
      'Match an IP address range',
      name: 'ruleActionIpCidrDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match an IP address range; IP-CIDR6 is just an alias`
  String get ruleActionIpCidr6Desc {
    return Intl.message(
      'Match an IP address range; IP-CIDR6 is just an alias',
      name: 'ruleActionIpCidr6Desc',
      desc: '',
      args: [],
    );
  }

  /// `Match an IP suffix range`
  String get ruleActionIpSuffixDesc {
    return Intl.message(
      'Match an IP suffix range',
      name: 'ruleActionIpSuffixDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the IP's ASN`
  String get ruleActionIpAsnDesc {
    return Intl.message(
      'Match the IP\'s ASN',
      name: 'ruleActionIpAsnDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the IP's country code`
  String get ruleActionGeoipDesc {
    return Intl.message(
      'Match the IP\'s country code',
      name: 'ruleActionGeoipDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the source IP's country code`
  String get ruleActionSrcGeoipDesc {
    return Intl.message(
      'Match the source IP\'s country code',
      name: 'ruleActionSrcGeoipDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the source IP's ASN`
  String get ruleActionSrcIpAsnDesc {
    return Intl.message(
      'Match the source IP\'s ASN',
      name: 'ruleActionSrcIpAsnDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match a source IP address range`
  String get ruleActionSrcIpCidrDesc {
    return Intl.message(
      'Match a source IP address range',
      name: 'ruleActionSrcIpCidrDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match a source IP suffix range`
  String get ruleActionSrcIpSuffixDesc {
    return Intl.message(
      'Match a source IP suffix range',
      name: 'ruleActionSrcIpSuffixDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the destination port range`
  String get ruleActionDstPortDesc {
    return Intl.message(
      'Match the destination port range',
      name: 'ruleActionDstPortDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the source port range`
  String get ruleActionSrcPortDesc {
    return Intl.message(
      'Match the source port range',
      name: 'ruleActionSrcPortDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the inbound port`
  String get ruleActionInPortDesc {
    return Intl.message(
      'Match the inbound port',
      name: 'ruleActionInPortDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the inbound type`
  String get ruleActionInTypeDesc {
    return Intl.message(
      'Match the inbound type',
      name: 'ruleActionInTypeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the inbound username; separate multiple usernames with /`
  String get ruleActionInUserDesc {
    return Intl.message(
      'Match the inbound username; separate multiple usernames with /',
      name: 'ruleActionInUserDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the inbound name`
  String get ruleActionInNameDesc {
    return Intl.message(
      'Match the inbound name',
      name: 'ruleActionInNameDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match by the full process path`
  String get ruleActionProcessPathDesc {
    return Intl.message(
      'Match by the full process path',
      name: 'ruleActionProcessPathDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match by process path regex`
  String get ruleActionProcessPathRegexDesc {
    return Intl.message(
      'Match by process path regex',
      name: 'ruleActionProcessPathRegexDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match by process name; matches the package name on Android`
  String get ruleActionProcessNameDesc {
    return Intl.message(
      'Match by process name; matches the package name on Android',
      name: 'ruleActionProcessNameDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match by process name regex; matches the package name on Android`
  String get ruleActionProcessNameRegexDesc {
    return Intl.message(
      'Match by process name regex; matches the package name on Android',
      name: 'ruleActionProcessNameRegexDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the Linux user ID`
  String get ruleActionUidDesc {
    return Intl.message(
      'Match the Linux user ID',
      name: 'ruleActionUidDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match TCP or UDP`
  String get ruleActionNetworkDesc {
    return Intl.message(
      'Match TCP or UDP',
      name: 'ruleActionNetworkDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the DSCP mark (tproxy UDP inbound only)`
  String get ruleActionDscpDesc {
    return Intl.message(
      'Match the DSCP mark (tproxy UDP inbound only)',
      name: 'ruleActionDscpDesc',
      desc: '',
      args: [],
    );
  }

  /// `Reference a rule set; requires rule-providers`
  String get ruleActionRuleSetDesc {
    return Intl.message(
      'Reference a rule set; requires rule-providers',
      name: 'ruleActionRuleSetDesc',
      desc: '',
      args: [],
    );
  }

  /// `Logical rule AND`
  String get ruleActionAndDesc {
    return Intl.message(
      'Logical rule AND',
      name: 'ruleActionAndDesc',
      desc: '',
      args: [],
    );
  }

  /// `Logical rule OR`
  String get ruleActionOrDesc {
    return Intl.message(
      'Logical rule OR',
      name: 'ruleActionOrDesc',
      desc: '',
      args: [],
    );
  }

  /// `Logical rule NOT`
  String get ruleActionNotDesc {
    return Intl.message(
      'Logical rule NOT',
      name: 'ruleActionNotDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match into a sub-rule; mind the parentheses`
  String get ruleActionSubRuleDesc {
    return Intl.message(
      'Match into a sub-rule; mind the parentheses',
      name: 'ruleActionSubRuleDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match all requests, no conditions needed`
  String get ruleActionMatchDesc {
    return Intl.message(
      'Match all requests, no conditions needed',
      name: 'ruleActionMatchDesc',
      desc: '',
      args: [],
    );
  }

  /// `Sub-rule is empty`
  String get subRuleEmpty {
    return Intl.message(
      'Sub-rule is empty',
      name: 'subRuleEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Proxy providers cannot be empty`
  String get proxyProvidersNotEmpty {
    return Intl.message(
      'Proxy providers cannot be empty',
      name: 'proxyProvidersNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Content cannot be empty`
  String get contentNotEmpty {
    return Intl.message(
      'Content cannot be empty',
      name: 'contentNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Sub-rule cannot be empty`
  String get subRuleNotEmpty {
    return Intl.message(
      'Sub-rule cannot be empty',
      name: 'subRuleNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Split strategy cannot be empty`
  String get splitStrategyNotEmpty {
    return Intl.message(
      'Split strategy cannot be empty',
      name: 'splitStrategyNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Proxy providers are empty`
  String get proxyProvidersEmpty {
    return Intl.message(
      'Proxy providers are empty',
      name: 'proxyProvidersEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Timeout`
  String get timeout {
    return Intl.message('Timeout', name: 'timeout', desc: '', args: []);
  }

  /// `{subRule} is an invalid SUB_RULE`
  String invalidSubRule(Object subRule) {
    return Intl.message(
      '$subRule is an invalid SUB_RULE',
      name: 'invalidSubRule',
      desc: '',
      args: [subRule],
    );
  }

  /// `{target} is an invalid policy`
  String invalidPolicy(Object target) {
    return Intl.message(
      '$target is an invalid policy',
      name: 'invalidPolicy',
      desc: '',
      args: [target],
    );
  }

  /// `{providerName} is an invalid proxy provider`
  String invalidProxyProvider(Object providerName) {
    return Intl.message(
      '$providerName is an invalid proxy provider',
      name: 'invalidProxyProvider',
      desc: '',
      args: [providerName],
    );
  }

  /// `{proxyName} is an invalid proxy`
  String invalidProxy(Object proxyName) {
    return Intl.message(
      '$proxyName is an invalid proxy',
      name: 'invalidProxy',
      desc: '',
      args: [proxyName],
    );
  }

  /// `The current proxy group is abnormal`
  String get proxyGroupDetectedAbnormal {
    return Intl.message(
      'The current proxy group is abnormal',
      name: 'proxyGroupDetectedAbnormal',
      desc: '',
      args: [],
    );
  }

  /// `The selected proxy providers are abnormal`
  String get proxyProviderDetectedAbnormal {
    return Intl.message(
      'The selected proxy providers are abnormal',
      name: 'proxyProviderDetectedAbnormal',
      desc: '',
      args: [],
    );
  }

  /// `The selected proxies are abnormal`
  String get proxyDetectedAbnormal {
    return Intl.message(
      'The selected proxies are abnormal',
      name: 'proxyDetectedAbnormal',
      desc: '',
      args: [],
    );
  }

  /// `Create profile`
  String get createProfile {
    return Intl.message(
      'Create profile',
      name: 'createProfile',
      desc: '',
      args: [],
    );
  }

  /// `Location permission required`
  String get locationPermissionRequired {
    return Intl.message(
      'Location permission required',
      name: 'locationPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `1. Open System Settings > Privacy & Security\n2. Choose Location Services\n3. Find and check {appName} in the list\n\nWhen you are done, return to the app to continue. Thank you for your cooperation.`
  String locationPermissionGuide(Object appName) {
    return Intl.message(
      '1. Open System Settings > Privacy & Security\n2. Choose Location Services\n3. Find and check $appName in the list\n\nWhen you are done, return to the app to continue. Thank you for your cooperation.',
      name: 'locationPermissionGuide',
      desc: '',
      args: [appName],
    );
  }

  /// `Prerequisites`
  String get prerequisites {
    return Intl.message(
      'Prerequisites',
      name: 'prerequisites',
      desc: '',
      args: [],
    );
  }

  /// `Ignore battery optimization`
  String get ignoreBatteryOptimization {
    return Intl.message(
      'Ignore battery optimization',
      name: 'ignoreBatteryOptimization',
      desc: '',
      args: [],
    );
  }

  /// `To keep the app running in the background, disable battery optimization for it. Tap to open settings.`
  String get batteryOptimizationDesc {
    return Intl.message(
      'To keep the app running in the background, disable battery optimization for it. Tap to open settings.',
      name: 'batteryOptimizationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Due to system limitations, the battery optimization status cannot be read correctly while running`
  String get batteryOptimizationStatusTip {
    return Intl.message(
      'Due to system limitations, the battery optimization status cannot be read correctly while running',
      name: 'batteryOptimizationStatusTip',
      desc: '',
      args: [],
    );
  }

  /// `Location permission`
  String get locationPermission {
    return Intl.message(
      'Location permission',
      name: 'locationPermission',
      desc: '',
      args: [],
    );
  }

  /// `The system requires location permission to read the Wi-Fi name. On Android choose "Allow all the time", otherwise the Wi-Fi name cannot be read while the app is in the background.`
  String get locationPermissionDesc {
    return Intl.message(
      'The system requires location permission to read the Wi-Fi name. On Android choose "Allow all the time", otherwise the Wi-Fi name cannot be read while the app is in the background.',
      name: 'locationPermissionDesc',
      desc: '',
      args: [],
    );
  }

  /// `Exclude SSIDs`
  String get excludeSsids {
    return Intl.message(
      'Exclude SSIDs',
      name: 'excludeSsids',
      desc: '',
      args: [],
    );
  }

  /// `When connected to Wi-Fi with an excluded SSID, the app's running state switches automatically`
  String get excludeSsidsDesc {
    return Intl.message(
      'When connected to Wi-Fi with an excluded SSID, the app\'s running state switches automatically',
      name: 'excludeSsidsDesc',
      desc: '',
      args: [],
    );
  }

  /// `SSIDs are empty`
  String get ssidsEmpty {
    return Intl.message(
      'SSIDs are empty',
      name: 'ssidsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `On demand`
  String get onDemand {
    return Intl.message('On demand', name: 'onDemand', desc: '', args: []);
  }

  /// `Configure the app's running state for specific scenarios`
  String get onDemandDesc {
    return Intl.message(
      'Configure the app\'s running state for specific scenarios',
      name: 'onDemandDesc',
      desc: '',
      args: [],
    );
  }

  /// `Location permission was denied, so the current Wi-Fi name cannot be read. Please enable location permission manually in system settings.`
  String get locationPermissionDeniedMessage {
    return Intl.message(
      'Location permission was denied, so the current Wi-Fi name cannot be read. Please enable location permission manually in system settings.',
      name: 'locationPermissionDeniedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Add SSID`
  String get addSsid {
    return Intl.message('Add SSID', name: 'addSsid', desc: '', args: []);
  }

  /// `Edit SSID`
  String get editSsid {
    return Intl.message('Edit SSID', name: 'editSsid', desc: '', args: []);
  }

  /// `Authorized`
  String get authorized {
    return Intl.message('Authorized', name: 'authorized', desc: '', args: []);
  }

  /// `Tap to authorize`
  String get tapToAuthorize {
    return Intl.message(
      'Tap to authorize',
      name: 'tapToAuthorize',
      desc: '',
      args: [],
    );
  }

  /// `Suspended...`
  String get suspended {
    return Intl.message('Suspended...', name: 'suspended', desc: '', args: []);
  }

  /// `Geo options`
  String get geoOptions {
    return Intl.message('Geo options', name: 'geoOptions', desc: '', args: []);
  }

  /// `Auto update`
  String get geoAutoUpdate {
    return Intl.message(
      'Auto update',
      name: 'geoAutoUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Auto-update interval`
  String get geoAutoUpdateInterval {
    return Intl.message(
      'Auto-update interval',
      name: 'geoAutoUpdateInterval',
      desc: '',
      args: [],
    );
  }

  /// `The auto-update interval must be greater than 0`
  String get geoAutoUpdateIntervalTip {
    return Intl.message(
      'The auto-update interval must be greater than 0',
      name: 'geoAutoUpdateIntervalTip',
      desc: '',
      args: [],
    );
  }

  /// `hours`
  String get hours {
    return Intl.message('hours', name: 'hours', desc: '', args: []);
  }

  /// `{count, plural, =1{1 hour} other{{count} hours}}`
  String hoursCount(num count) {
    return Intl.plural(
      count,
      one: '1 hour',
      other: '$count hours',
      name: 'hoursCount',
      desc: '',
      args: [count],
    );
  }

  /// `Geo resources`
  String get geoResources {
    return Intl.message(
      'Geo resources',
      name: 'geoResources',
      desc: '',
      args: [],
    );
  }

  /// `{name} is already up to date`
  String geoSkipped(Object name) {
    return Intl.message(
      '$name is already up to date',
      name: 'geoSkipped',
      desc: '',
      args: [name],
    );
  }

  /// `{name} updated`
  String geoUpdated(Object name) {
    return Intl.message(
      '$name updated',
      name: 'geoUpdated',
      desc: '',
      args: [name],
    );
  }

  /// `{count, plural, =1{1 second} other{{count} seconds}}`
  String secondsCount(num count) {
    return Intl.plural(
      count,
      one: '1 second',
      other: '$count seconds',
      name: 'secondsCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 entry} other{{count} entries}}`
  String entriesCount(num count) {
    return Intl.plural(
      count,
      one: '1 entry',
      other: '$count entries',
      name: 'entriesCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 proxy} other{{count} proxies}}`
  String proxiesCount(num count) {
    return Intl.plural(
      count,
      one: '1 proxy',
      other: '$count proxies',
      name: 'proxiesCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 rule} other{{count} rules}}`
  String rulesCount(num count) {
    return Intl.plural(
      count,
      one: '1 rule',
      other: '$count rules',
      name: 'rulesCount',
      desc: '',
      args: [count],
    );
  }

  /// `Breaking changes`
  String get changelogBreaking {
    return Intl.message(
      'Breaking changes',
      name: 'changelogBreaking',
      desc: '',
      args: [],
    );
  }

  /// `New features`
  String get changelogFeatures {
    return Intl.message(
      'New features',
      name: 'changelogFeatures',
      desc: '',
      args: [],
    );
  }

  /// `Bug fixes`
  String get changelogFixes {
    return Intl.message(
      'Bug fixes',
      name: 'changelogFixes',
      desc: '',
      args: [],
    );
  }

  /// `Performance`
  String get changelogPerformance {
    return Intl.message(
      'Performance',
      name: 'changelogPerformance',
      desc: '',
      args: [],
    );
  }

  /// `Reverts`
  String get changelogReverts {
    return Intl.message(
      'Reverts',
      name: 'changelogReverts',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Minimize`
  String get minimize {
    return Intl.message('Minimize', name: 'minimize', desc: '', args: []);
  }

  /// `Maximize`
  String get maximize {
    return Intl.message('Maximize', name: 'maximize', desc: '', args: []);
  }

  /// `Restore down`
  String get unmaximize {
    return Intl.message('Restore down', name: 'unmaximize', desc: '', args: []);
  }

  /// `Pin window`
  String get pinWindow {
    return Intl.message('Pin window', name: 'pinWindow', desc: '', args: []);
  }

  /// `Unpin window`
  String get unpinWindow {
    return Intl.message(
      'Unpin window',
      name: 'unpinWindow',
      desc: '',
      args: [],
    );
  }

  /// `Toggle labels`
  String get toggleLabel {
    return Intl.message(
      'Toggle labels',
      name: 'toggleLabel',
      desc: '',
      args: [],
    );
  }

  /// `Flashlight`
  String get torch {
    return Intl.message('Flashlight', name: 'torch', desc: '', args: []);
  }

  /// `Choose from album`
  String get pickFromAlbum {
    return Intl.message(
      'Choose from album',
      name: 'pickFromAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Block connection`
  String get blockConnection {
    return Intl.message(
      'Block connection',
      name: 'blockConnection',
      desc: '',
      args: [],
    );
  }

  /// `Close connections`
  String get closeConnections {
    return Intl.message(
      'Close connections',
      name: 'closeConnections',
      desc: '',
      args: [],
    );
  }

  /// `Scroll to selected`
  String get scrollToSelected {
    return Intl.message(
      'Scroll to selected',
      name: 'scrollToSelected',
      desc: '',
      args: [],
    );
  }

  /// `Expand`
  String get showMore {
    return Intl.message('Expand', name: 'showMore', desc: '', args: []);
  }

  /// `Collapse`
  String get showLess {
    return Intl.message('Collapse', name: 'showLess', desc: '', args: []);
  }

  /// `Previous match`
  String get previousMatch {
    return Intl.message(
      'Previous match',
      name: 'previousMatch',
      desc: '',
      args: [],
    );
  }

  /// `Next match`
  String get nextMatch {
    return Intl.message('Next match', name: 'nextMatch', desc: '', args: []);
  }

  /// `Clear search`
  String get clearSearch {
    return Intl.message(
      'Clear search',
      name: 'clearSearch',
      desc: '',
      args: [],
    );
  }

  /// `Add widget`
  String get addWidget {
    return Intl.message('Add widget', name: 'addWidget', desc: '', args: []);
  }

  /// `Show password`
  String get showPassword {
    return Intl.message(
      'Show password',
      name: 'showPassword',
      desc: '',
      args: [],
    );
  }

  /// `Hide password`
  String get hidePassword {
    return Intl.message(
      'Hide password',
      name: 'hidePassword',
      desc: '',
      args: [],
    );
  }

  /// `Authorize`
  String get authorize {
    return Intl.message('Authorize', name: 'authorize', desc: '', args: []);
  }

  /// `App list permission required`
  String get installedAppsPermissionRequired {
    return Intl.message(
      'App list permission required',
      name: 'installedAppsPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `This system hides the installed app list until the permission is granted. Authorize it to configure the per-app proxy.`
  String get installedAppsPermissionDesc {
    return Intl.message(
      'This system hides the installed app list until the permission is granted. Authorize it to configure the per-app proxy.',
      name: 'installedAppsPermissionDesc',
      desc: '',
      args: [],
    );
  }

  /// `The app list permission was denied, so installed apps cannot be listed. Please grant it manually in system settings.`
  String get installedAppsPermissionDeniedMessage {
    return Intl.message(
      'The app list permission was denied, so installed apps cannot be listed. Please grant it manually in system settings.',
      name: 'installedAppsPermissionDeniedMessage',
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
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ru'),
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
