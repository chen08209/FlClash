import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_es.dart';
import 'l10n_fr.dart';
import 'l10n_ja.dart';
import 'l10n_ko.dart';
import 'l10n_ru.dart';
import 'l10n_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @rule.
  ///
  /// In en, this message translates to:
  /// **'Rule'**
  String get rule;

  /// No description provided for @rules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get rules;

  /// No description provided for @global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get global;

  /// No description provided for @direct.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get direct;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @proxies.
  ///
  /// In en, this message translates to:
  /// **'Proxies'**
  String get proxies;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get profiles;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @resources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resources;

  /// No description provided for @trafficUsage.
  ///
  /// In en, this message translates to:
  /// **'Traffic usage'**
  String get trafficUsage;

  /// No description provided for @networkSpeed.
  ///
  /// In en, this message translates to:
  /// **'Network speed'**
  String get networkSpeed;

  /// No description provided for @outboundMode.
  ///
  /// In en, this message translates to:
  /// **'Outbound mode'**
  String get outboundMode;

  /// No description provided for @serviceStatus.
  ///
  /// In en, this message translates to:
  /// **'Service status'**
  String get serviceStatus;

  /// No description provided for @serviceRestricted.
  ///
  /// In en, this message translates to:
  /// **'Access restricted'**
  String get serviceRestricted;

  /// No description provided for @serviceAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get serviceAvailable;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get serviceUnavailable;

  /// No description provided for @serviceFailed.
  ///
  /// In en, this message translates to:
  /// **'Check failed'**
  String get serviceFailed;

  /// No description provided for @serviceDisallowedIsp.
  ///
  /// In en, this message translates to:
  /// **'Disallowed ISP'**
  String get serviceDisallowedIsp;

  /// No description provided for @serviceBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get serviceBlocked;

  /// No description provided for @serviceUnsupportedRegion.
  ///
  /// In en, this message translates to:
  /// **'Region not supported'**
  String get serviceUnsupportedRegion;

  /// No description provided for @serviceOriginalsOnly.
  ///
  /// In en, this message translates to:
  /// **'Originals only'**
  String get serviceOriginalsOnly;

  /// No description provided for @serviceComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get serviceComingSoon;

  /// No description provided for @servicePending.
  ///
  /// In en, this message translates to:
  /// **'Not checked'**
  String get servicePending;

  /// No description provided for @serviceManage.
  ///
  /// In en, this message translates to:
  /// **'Manage services'**
  String get serviceManage;

  /// No description provided for @serviceCheckAll.
  ///
  /// In en, this message translates to:
  /// **'Check all'**
  String get serviceCheckAll;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @usedTraffic.
  ///
  /// In en, this message translates to:
  /// **'Used traffic'**
  String get usedTraffic;

  /// No description provided for @totalTraffic.
  ///
  /// In en, this message translates to:
  /// **'Total traffic'**
  String get totalTraffic;

  /// No description provided for @expireTime.
  ///
  /// In en, this message translates to:
  /// **'Expiration time'**
  String get expireTime;

  /// No description provided for @nullProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Add a profile to get started'**
  String get nullProfileDesc;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @defaultText.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultText;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get en;

  /// No description provided for @es.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get es;

  /// No description provided for @fr.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get fr;

  /// No description provided for @ja.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get ja;

  /// No description provided for @ko.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get ko;

  /// No description provided for @ru.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get ru;

  /// No description provided for @zhCN.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get zhCN;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @extend.
  ///
  /// In en, this message translates to:
  /// **'Extend'**
  String get extend;

  /// No description provided for @runtimeConfig.
  ///
  /// In en, this message translates to:
  /// **'Runtime config'**
  String get runtimeConfig;

  /// No description provided for @allowLan.
  ///
  /// In en, this message translates to:
  /// **'Allow LAN'**
  String get allowLan;

  /// No description provided for @tun.
  ///
  /// In en, this message translates to:
  /// **'TUN'**
  String get tun;

  /// No description provided for @tunDesc.
  ///
  /// In en, this message translates to:
  /// **'TUN works only in administrator mode.'**
  String get tunDesc;

  /// No description provided for @minimizeOnExit.
  ///
  /// In en, this message translates to:
  /// **'Minimize on exit'**
  String get minimizeOnExit;

  /// No description provided for @autoLaunch.
  ///
  /// In en, this message translates to:
  /// **'Auto launch'**
  String get autoLaunch;

  /// No description provided for @silentLaunch.
  ///
  /// In en, this message translates to:
  /// **'Silent launch'**
  String get silentLaunch;

  /// No description provided for @autoRun.
  ///
  /// In en, this message translates to:
  /// **'Auto run'**
  String get autoRun;

  /// No description provided for @autoRunDesc.
  ///
  /// In en, this message translates to:
  /// **'Auto run starts the proxy when the app opens.'**
  String get autoRunDesc;

  /// No description provided for @logcat.
  ///
  /// In en, this message translates to:
  /// **'Logcat'**
  String get logcat;

  /// No description provided for @logcatDesc.
  ///
  /// In en, this message translates to:
  /// **'Turning off Logcat hides the logs entry.'**
  String get logcatDesc;

  /// No description provided for @autoCheckUpdate.
  ///
  /// In en, this message translates to:
  /// **'Auto check for updates'**
  String get autoCheckUpdate;

  /// No description provided for @checkCertificate.
  ///
  /// In en, this message translates to:
  /// **'Verify TLS certificates'**
  String get checkCertificate;

  /// No description provided for @checkCertificateDesc.
  ///
  /// In en, this message translates to:
  /// **'With TLS verification off, subscriptions and backups are open to man-in-the-middle attacks.'**
  String get checkCertificateDesc;

  /// No description provided for @accessControl.
  ///
  /// In en, this message translates to:
  /// **'Access control'**
  String get accessControl;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @qrcode.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get qrcode;

  /// No description provided for @qrcodeDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan a QR code to obtain a profile'**
  String get qrcodeDesc;

  /// No description provided for @url.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get url;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @profileNameNullValidationDesc.
  ///
  /// In en, this message translates to:
  /// **'Please enter the profile name'**
  String get profileNameNullValidationDesc;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @profileUrlNullValidationDesc.
  ///
  /// In en, this message translates to:
  /// **'Please enter the profile URL'**
  String get profileUrlNullValidationDesc;

  /// No description provided for @profileUrlInvalidValidationDesc.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid profile URL'**
  String get profileUrlInvalidValidationDesc;

  /// No description provided for @autoUpdate.
  ///
  /// In en, this message translates to:
  /// **'Auto update'**
  String get autoUpdate;

  /// No description provided for @autoUpdateInterval.
  ///
  /// In en, this message translates to:
  /// **'Auto-update interval'**
  String get autoUpdateInterval;

  /// No description provided for @profileAutoUpdateIntervalNullValidationDesc.
  ///
  /// In en, this message translates to:
  /// **'Please enter the auto-update interval'**
  String get profileAutoUpdateIntervalNullValidationDesc;

  /// No description provided for @profileAutoUpdateIntervalInvalidValidationDesc.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid interval'**
  String get profileAutoUpdateIntervalInvalidValidationDesc;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeMode;

  /// No description provided for @themeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme color'**
  String get themeColor;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @importFromLink.
  ///
  /// In en, this message translates to:
  /// **'Import from link'**
  String get importFromLink;

  /// No description provided for @sendFromPhone.
  ///
  /// In en, this message translates to:
  /// **'Send from phone'**
  String get sendFromPhone;

  /// No description provided for @sendFromPhoneTip.
  ///
  /// In en, this message translates to:
  /// **'Scan the code with your phone\'s camera and paste the link on the page that opens. Both devices need to be on the same network.'**
  String get sendFromPhoneTip;

  /// No description provided for @sendFromPhoneNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'This device is not connected to a local network'**
  String get sendFromPhoneNoNetwork;

  /// No description provided for @sendFromPhonePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Receiving a link from your phone needs the Nearby devices permission, which lets FlClash reach the local network. Turn it on in the app\'s settings.'**
  String get sendFromPhonePermissionDenied;

  /// No description provided for @sendFromPhonePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a link to FlClash'**
  String get sendFromPhonePageTitle;

  /// No description provided for @sendFromPhonePageHint.
  ///
  /// In en, this message translates to:
  /// **'Subscription link or proxy share link'**
  String get sendFromPhonePageHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sendFromPhonePageSent.
  ///
  /// In en, this message translates to:
  /// **'Sent. Confirm the import on the other device.'**
  String get sendFromPhonePageSent;

  /// No description provided for @sendFromPhoneConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Import the link from your phone?'**
  String get sendFromPhoneConfirmTitle;

  /// No description provided for @shareQrcodeTip.
  ///
  /// In en, this message translates to:
  /// **'Scan with FlClash on another device to import this profile.'**
  String get shareQrcodeTip;

  /// No description provided for @qrcodeTooLongTip.
  ///
  /// In en, this message translates to:
  /// **'This link is too long for a QR code. Use Copy link instead.'**
  String get qrcodeTooLongTip;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @createProfileFromUrlTip.
  ///
  /// In en, this message translates to:
  /// **'Do you want to create a profile from {url}?'**
  String createProfileFromUrlTip(Object url);

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @pleaseUploadValidQrcode.
  ///
  /// In en, this message translates to:
  /// **'Please upload a valid QR code'**
  String get pleaseUploadValidQrcode;

  /// No description provided for @blacklistMode.
  ///
  /// In en, this message translates to:
  /// **'Blacklist mode'**
  String get blacklistMode;

  /// No description provided for @whitelistMode.
  ///
  /// In en, this message translates to:
  /// **'Whitelist mode'**
  String get whitelistMode;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @cancelSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get cancelSelectAll;

  /// No description provided for @appAccessControl.
  ///
  /// In en, this message translates to:
  /// **'App access control'**
  String get appAccessControl;

  /// No description provided for @accessControlAllowDesc.
  ///
  /// In en, this message translates to:
  /// **'Only selected apps go through the VPN'**
  String get accessControlAllowDesc;

  /// No description provided for @accessControlNotAllowDesc.
  ///
  /// In en, this message translates to:
  /// **'Selected apps are excluded from the VPN'**
  String get accessControlNotAllowDesc;

  /// No description provided for @accessControlDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'App access control is disabled'**
  String get accessControlDisabledDesc;

  /// No description provided for @accessControlSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} selected}}'**
  String accessControlSelectedCount(num count);

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @logLevel.
  ///
  /// In en, this message translates to:
  /// **'Log level'**
  String get logLevel;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @systemProxy.
  ///
  /// In en, this message translates to:
  /// **'System proxy'**
  String get systemProxy;

  /// No description provided for @safeMode.
  ///
  /// In en, this message translates to:
  /// **'Safe mode'**
  String get safeMode;

  /// No description provided for @safeModeAppTitle.
  ///
  /// In en, this message translates to:
  /// **'{appName} (Safe mode)'**
  String safeModeAppTitle(Object appName);

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @core.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get core;

  /// No description provided for @tabAnimation.
  ///
  /// In en, this message translates to:
  /// **'Tab animation'**
  String get tabAnimation;

  /// No description provided for @desc.
  ///
  /// In en, this message translates to:
  /// **'A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.'**
  String get desc;

  /// No description provided for @startVpn.
  ///
  /// In en, this message translates to:
  /// **'Starting VPN…'**
  String get startVpn;

  /// No description provided for @stopVpn.
  ///
  /// In en, this message translates to:
  /// **'Stopping VPN…'**
  String get stopVpn;

  /// No description provided for @localNetworkDeniedTip.
  ///
  /// In en, this message translates to:
  /// **'Local network permission denied: using the gvisor stack, LAN is unreachable.'**
  String get localNetworkDeniedTip;

  /// No description provided for @compatible.
  ///
  /// In en, this message translates to:
  /// **'Compatibility mode'**
  String get compatible;

  /// No description provided for @notSelectedTip.
  ///
  /// In en, this message translates to:
  /// **'The current proxy group cannot be selected'**
  String get notSelectedTip;

  /// No description provided for @changeProxyFailedTip.
  ///
  /// In en, this message translates to:
  /// **'Failed to switch proxy; the previous selection has been restored'**
  String get changeProxyFailedTip;

  /// No description provided for @databaseWriteFailedTip.
  ///
  /// In en, this message translates to:
  /// **'Failed to save the change; it has been rolled back'**
  String get databaseWriteFailedTip;

  /// No description provided for @tip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tip;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup successful'**
  String get backupSuccess;

  /// No description provided for @noInfo.
  ///
  /// In en, this message translates to:
  /// **'No info'**
  String get noInfo;

  /// No description provided for @pleaseBindWebDAV.
  ///
  /// In en, this message translates to:
  /// **'Please bind WebDAV'**
  String get pleaseBindWebDAV;

  /// No description provided for @bind.
  ///
  /// In en, this message translates to:
  /// **'Bind'**
  String get bind;

  /// No description provided for @connectivity.
  ///
  /// In en, this message translates to:
  /// **'Connectivity: '**
  String get connectivity;

  /// No description provided for @webDAVConfiguration.
  ///
  /// In en, this message translates to:
  /// **'WebDAV configuration'**
  String get webDAVConfiguration;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addressTip.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid WebDAV address'**
  String get addressTip;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @authentication.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authentication;

  /// No description provided for @authenticationSystemProxyDesc.
  ///
  /// In en, this message translates to:
  /// **'The system proxy is not applied while authentication is on.'**
  String get authenticationSystemProxyDesc;

  /// No description provided for @checkUpdate.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkUpdate;

  /// No description provided for @discoverNewVersion.
  ///
  /// In en, this message translates to:
  /// **'New version found'**
  String get discoverNewVersion;

  /// No description provided for @checkUpdateError.
  ///
  /// In en, this message translates to:
  /// **'The app is already up to date'**
  String get checkUpdateError;

  /// No description provided for @goDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get goDownload;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get country;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @allowBypass.
  ///
  /// In en, this message translates to:
  /// **'Allow apps to bypass VPN'**
  String get allowBypass;

  /// No description provided for @externalController.
  ///
  /// In en, this message translates to:
  /// **'External controller'**
  String get externalController;

  /// No description provided for @externalControllerDesc.
  ///
  /// In en, this message translates to:
  /// **'The external controller lets you control the core on port 9090.'**
  String get externalControllerDesc;

  /// No description provided for @externalControllerSecret.
  ///
  /// In en, this message translates to:
  /// **'External controller secret'**
  String get externalControllerSecret;

  /// No description provided for @ipv6Desc.
  ///
  /// In en, this message translates to:
  /// **'IPv6 traffic is received only while IPv6 is on.'**
  String get ipv6Desc;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @startupAndBackground.
  ///
  /// In en, this message translates to:
  /// **'Startup and background'**
  String get startupAndBackground;

  /// No description provided for @requestsAndUpdates.
  ///
  /// In en, this message translates to:
  /// **'Requests and updates'**
  String get requestsAndUpdates;

  /// No description provided for @logsAndDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Logs and diagnostics'**
  String get logsAndDiagnostics;

  /// No description provided for @userAgent.
  ///
  /// In en, this message translates to:
  /// **'User-Agent'**
  String get userAgent;

  /// No description provided for @unifiedDelay.
  ///
  /// In en, this message translates to:
  /// **'Unified delay'**
  String get unifiedDelay;

  /// No description provided for @tcpConcurrent.
  ///
  /// In en, this message translates to:
  /// **'TCP concurrent'**
  String get tcpConcurrent;

  /// No description provided for @geodataLoader.
  ///
  /// In en, this message translates to:
  /// **'Geo low-memory mode'**
  String get geodataLoader;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @recentRequests.
  ///
  /// In en, this message translates to:
  /// **'Recent requests'**
  String get recentRequests;

  /// No description provided for @alwaysFindProcess.
  ///
  /// In en, this message translates to:
  /// **'Always find process'**
  String get alwaysFindProcess;

  /// No description provided for @init.
  ///
  /// In en, this message translates to:
  /// **'Init'**
  String get init;

  /// No description provided for @infiniteTime.
  ///
  /// In en, this message translates to:
  /// **'Never expires'**
  String get infiniteTime;

  /// No description provided for @connections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get connections;

  /// No description provided for @liveConnections.
  ///
  /// In en, this message translates to:
  /// **'Live connections'**
  String get liveConnections;

  /// No description provided for @inbound.
  ///
  /// In en, this message translates to:
  /// **'Inbound'**
  String get inbound;

  /// No description provided for @intranetIP.
  ///
  /// In en, this message translates to:
  /// **'Intranet IP'**
  String get intranetIP;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @cut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cut;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @clipboardWriteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t copy to the clipboard. The selection may be too large'**
  String get clipboardWriteFailed;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @testUrl.
  ///
  /// In en, this message translates to:
  /// **'Test URL'**
  String get testUrl;

  /// No description provided for @delayTestTimeout.
  ///
  /// In en, this message translates to:
  /// **'Delay test timeout'**
  String get delayTestTimeout;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @exclude.
  ///
  /// In en, this message translates to:
  /// **'Hide from recent tasks'**
  String get exclude;

  /// No description provided for @compact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get compact;

  /// No description provided for @tab.
  ///
  /// In en, this message translates to:
  /// **'Tab'**
  String get tab;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @delay.
  ///
  /// In en, this message translates to:
  /// **'Delay'**
  String get delay;

  /// No description provided for @style.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get style;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @columns.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get columns;

  /// No description provided for @proxyGroup.
  ///
  /// In en, this message translates to:
  /// **'Proxy group'**
  String get proxyGroup;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @externalLink.
  ///
  /// In en, this message translates to:
  /// **'External link'**
  String get externalLink;

  /// No description provided for @otherContributors.
  ///
  /// In en, this message translates to:
  /// **'Other contributors'**
  String get otherContributors;

  /// No description provided for @appIconDesign.
  ///
  /// In en, this message translates to:
  /// **'App icon design'**
  String get appIconDesign;

  /// No description provided for @autoCloseConnections.
  ///
  /// In en, this message translates to:
  /// **'Auto close connections'**
  String get autoCloseConnections;

  /// No description provided for @onlyStatisticsProxy.
  ///
  /// In en, this message translates to:
  /// **'Only count proxy traffic'**
  String get onlyStatisticsProxy;

  /// No description provided for @showNotificationStopAction.
  ///
  /// In en, this message translates to:
  /// **'Stop button in notification'**
  String get showNotificationStopAction;

  /// No description provided for @pureBlackMode.
  ///
  /// In en, this message translates to:
  /// **'Pure black mode'**
  String get pureBlackMode;

  /// No description provided for @sidebar.
  ///
  /// In en, this message translates to:
  /// **'Sidebar'**
  String get sidebar;

  /// No description provided for @backgroundBlur.
  ///
  /// In en, this message translates to:
  /// **'Background blur'**
  String get backgroundBlur;

  /// No description provided for @liquidGlass.
  ///
  /// In en, this message translates to:
  /// **'Liquid Glass'**
  String get liquidGlass;

  /// No description provided for @keepAliveIntervalDesc.
  ///
  /// In en, this message translates to:
  /// **'TCP keep-alive interval'**
  String get keepAliveIntervalDesc;

  /// No description provided for @entries.
  ///
  /// In en, this message translates to:
  /// **' entries'**
  String get entries;

  /// No description provided for @local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get local;

  /// No description provided for @remote.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get remote;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @intelligentSelected.
  ///
  /// In en, this message translates to:
  /// **'Smart selection'**
  String get intelligentSelected;

  /// No description provided for @clipboardImport.
  ///
  /// In en, this message translates to:
  /// **'Import from clipboard'**
  String get clipboardImport;

  /// No description provided for @clipboardNoPackageNames.
  ///
  /// In en, this message translates to:
  /// **'No package names found in the clipboard'**
  String get clipboardNoPackageNames;

  /// No description provided for @clipboardExport.
  ///
  /// In en, this message translates to:
  /// **'Export to clipboard'**
  String get clipboardExport;

  /// No description provided for @layout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get layout;

  /// No description provided for @tight.
  ///
  /// In en, this message translates to:
  /// **'Tight'**
  String get tight;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @ultra.
  ///
  /// In en, this message translates to:
  /// **'Ultra'**
  String get ultra;

  /// No description provided for @loose.
  ///
  /// In en, this message translates to:
  /// **'Loose'**
  String get loose;

  /// No description provided for @profilesSort.
  ///
  /// In en, this message translates to:
  /// **'Sort profiles'**
  String get profilesSort;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @runTime.
  ///
  /// In en, this message translates to:
  /// **'Run time'**
  String get runTime;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @key.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get key;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @loopback.
  ///
  /// In en, this message translates to:
  /// **'UWP loopback exemption'**
  String get loopback;

  /// No description provided for @providers.
  ///
  /// In en, this message translates to:
  /// **'External resources'**
  String get providers;

  /// No description provided for @proxyProviders.
  ///
  /// In en, this message translates to:
  /// **'Proxy providers'**
  String get proxyProviders;

  /// No description provided for @ruleProviders.
  ///
  /// In en, this message translates to:
  /// **'Rule providers'**
  String get ruleProviders;

  /// No description provided for @providerUrlTip.
  ///
  /// In en, this message translates to:
  /// **'Only remote providers are supported'**
  String get providerUrlTip;

  /// No description provided for @ruleSetEmptyTip.
  ///
  /// In en, this message translates to:
  /// **'The rule set has no usable entries'**
  String get ruleSetEmptyTip;

  /// No description provided for @ruleSetMixedTip.
  ///
  /// In en, this message translates to:
  /// **'The rule set mixes domains and IP ranges, so its type cannot be told'**
  String get ruleSetMixedTip;

  /// No description provided for @ruleSetInvalidTip.
  ///
  /// In en, this message translates to:
  /// **'This mrs file cannot be read'**
  String get ruleSetInvalidTip;

  /// No description provided for @subscriptionInfo.
  ///
  /// In en, this message translates to:
  /// **'Subscription info'**
  String get subscriptionInfo;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @ntpInterval.
  ///
  /// In en, this message translates to:
  /// **'Sync interval (minutes)'**
  String get ntpInterval;

  /// No description provided for @dialerProxy.
  ///
  /// In en, this message translates to:
  /// **'Dialer proxy'**
  String get dialerProxy;

  /// No description provided for @writeToSystem.
  ///
  /// In en, this message translates to:
  /// **'Write to system'**
  String get writeToSystem;

  /// No description provided for @writeToSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'Write to system also sets the system clock; Android ignores it.'**
  String get writeToSystemDesc;

  /// No description provided for @sniffer.
  ///
  /// In en, this message translates to:
  /// **'Sniffer'**
  String get sniffer;

  /// No description provided for @overrideDestination.
  ///
  /// In en, this message translates to:
  /// **'Override destination'**
  String get overrideDestination;

  /// No description provided for @forceDnsMapping.
  ///
  /// In en, this message translates to:
  /// **'Force DNS mapping'**
  String get forceDnsMapping;

  /// No description provided for @forceDnsMappingDesc.
  ///
  /// In en, this message translates to:
  /// **'Force DNS mapping also sniffs connections whose domain came from a DNS mapping.'**
  String get forceDnsMappingDesc;

  /// No description provided for @parsePureIp.
  ///
  /// In en, this message translates to:
  /// **'Parse pure IP'**
  String get parsePureIp;

  /// No description provided for @forceDomain.
  ///
  /// In en, this message translates to:
  /// **'Force domains'**
  String get forceDomain;

  /// No description provided for @forceDomainDesc.
  ///
  /// In en, this message translates to:
  /// **'Force domains are sniffed too; other connections that already have a domain are left alone.'**
  String get forceDomainDesc;

  /// No description provided for @skipDomain.
  ///
  /// In en, this message translates to:
  /// **'Skip domains'**
  String get skipDomain;

  /// No description provided for @skipSrcAddress.
  ///
  /// In en, this message translates to:
  /// **'Skip source addresses'**
  String get skipSrcAddress;

  /// No description provided for @skipDstAddress.
  ///
  /// In en, this message translates to:
  /// **'Skip destination addresses'**
  String get skipDstAddress;

  /// No description provided for @sniffProtocols.
  ///
  /// In en, this message translates to:
  /// **'Protocols'**
  String get sniffProtocols;

  /// No description provided for @ports.
  ///
  /// In en, this message translates to:
  /// **'Ports'**
  String get ports;

  /// No description provided for @overrideEntries.
  ///
  /// In en, this message translates to:
  /// **'Override entries'**
  String get overrideEntries;

  /// No description provided for @addOverrideEntry.
  ///
  /// In en, this message translates to:
  /// **'Add override entry'**
  String get addOverrideEntry;

  /// No description provided for @dnsOverrideDesc.
  ///
  /// In en, this message translates to:
  /// **'Entries added here replace the DNS of every URL and file profile; anything not added keeps the profile\'s own setting. Custom profiles set their DNS in their content.'**
  String get dnsOverrideDesc;

  /// No description provided for @settingEntries.
  ///
  /// In en, this message translates to:
  /// **'settings'**
  String get settingEntries;

  /// No description provided for @addSettingEntry.
  ///
  /// In en, this message translates to:
  /// **'Add setting'**
  String get addSettingEntry;

  /// No description provided for @profileSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Applies to this profile only; anything not added uses its default.'**
  String get profileSettingsDesc;

  /// No description provided for @healthCheck.
  ///
  /// In en, this message translates to:
  /// **'Health check'**
  String get healthCheck;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard the changes?'**
  String get discardChanges;

  /// No description provided for @quickEdit.
  ///
  /// In en, this message translates to:
  /// **'Quick edit'**
  String get quickEdit;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @statusDesc.
  ///
  /// In en, this message translates to:
  /// **'With DNS off, the system DNS is used.'**
  String get statusDesc;

  /// No description provided for @respectRules.
  ///
  /// In en, this message translates to:
  /// **'Respect rules'**
  String get respectRules;

  /// No description provided for @respectRulesDesc.
  ///
  /// In en, this message translates to:
  /// **'Respect rules routes DNS connections by the rules and needs a Proxy Server Nameserver.'**
  String get respectRulesDesc;

  /// No description provided for @dnsMode.
  ///
  /// In en, this message translates to:
  /// **'DNS mode'**
  String get dnsMode;

  /// No description provided for @fakeipRange.
  ///
  /// In en, this message translates to:
  /// **'Fake-IP range'**
  String get fakeipRange;

  /// No description provided for @fakeipFilter.
  ///
  /// In en, this message translates to:
  /// **'Fake-IP filter'**
  String get fakeipFilter;

  /// No description provided for @useHosts.
  ///
  /// In en, this message translates to:
  /// **'Use hosts'**
  String get useHosts;

  /// No description provided for @useSystemHosts.
  ///
  /// In en, this message translates to:
  /// **'Use system hosts'**
  String get useSystemHosts;

  /// No description provided for @fallbackFilter.
  ///
  /// In en, this message translates to:
  /// **'Fallback filter'**
  String get fallbackFilter;

  /// No description provided for @domain.
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get domain;

  /// No description provided for @listenRoutingMark.
  ///
  /// In en, this message translates to:
  /// **'Listen routing mark'**
  String get listenRoutingMark;

  /// No description provided for @listenRoutingMarkDesc.
  ///
  /// In en, this message translates to:
  /// **'Listen routing mark works only on Linux.'**
  String get listenRoutingMarkDesc;

  /// No description provided for @ipv6Timeout.
  ///
  /// In en, this message translates to:
  /// **'IPv6 timeout (ms)'**
  String get ipv6Timeout;

  /// No description provided for @cacheAlgorithm.
  ///
  /// In en, this message translates to:
  /// **'Cache algorithm'**
  String get cacheAlgorithm;

  /// No description provided for @cacheMaxSize.
  ///
  /// In en, this message translates to:
  /// **'Cache size'**
  String get cacheMaxSize;

  /// No description provided for @fakeipRange6.
  ///
  /// In en, this message translates to:
  /// **'Fake-IP range (IPv6)'**
  String get fakeipRange6;

  /// No description provided for @fakeipFilterMode.
  ///
  /// In en, this message translates to:
  /// **'Fake-IP filter mode'**
  String get fakeipFilterMode;

  /// No description provided for @fakeipTtl.
  ///
  /// In en, this message translates to:
  /// **'Fake-IP TTL'**
  String get fakeipTtl;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @actionView.
  ///
  /// In en, this message translates to:
  /// **'Show/Hide'**
  String get actionView;

  /// No description provided for @actionStart.
  ///
  /// In en, this message translates to:
  /// **'Start/Stop'**
  String get actionStart;

  /// No description provided for @actionMode.
  ///
  /// In en, this message translates to:
  /// **'Switch mode'**
  String get actionMode;

  /// No description provided for @actionProxy.
  ///
  /// In en, this message translates to:
  /// **'System proxy'**
  String get actionProxy;

  /// No description provided for @actionTun.
  ///
  /// In en, this message translates to:
  /// **'TUN'**
  String get actionTun;

  /// No description provided for @actionRuleMode.
  ///
  /// In en, this message translates to:
  /// **'Rule mode'**
  String get actionRuleMode;

  /// No description provided for @actionGlobalMode.
  ///
  /// In en, this message translates to:
  /// **'Global mode'**
  String get actionGlobalMode;

  /// No description provided for @actionDirectMode.
  ///
  /// In en, this message translates to:
  /// **'Direct mode'**
  String get actionDirectMode;

  /// No description provided for @actionDelayTest.
  ///
  /// In en, this message translates to:
  /// **'Test all delays'**
  String get actionDelayTest;

  /// No description provided for @actionUpdateProfiles.
  ///
  /// In en, this message translates to:
  /// **'Update profiles'**
  String get actionUpdateProfiles;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer;

  /// No description provided for @disclaimerDesc.
  ///
  /// In en, this message translates to:
  /// **'Before using FlClash (\"the Software\"), please read this statement carefully and make sure you understand it. Tapping \"Agree\" means you have read and understood what follows. If you do not want to continue, tap \"Exit\".'**
  String get disclaimerDesc;

  /// No description provided for @disclaimerSoftwareTitle.
  ///
  /// In en, this message translates to:
  /// **'Nature of the software'**
  String get disclaimerSoftwareTitle;

  /// No description provided for @disclaimerSoftwareContent.
  ///
  /// In en, this message translates to:
  /// **'The Software is an open-source network proxy client built on the Clash.Meta (mihomo) core. It only provides local tooling such as configuration management, rule-based routing, and traffic forwarding.'**
  String get disclaimerSoftwareContent;

  /// No description provided for @disclaimerNoServiceStatement.
  ///
  /// In en, this message translates to:
  /// **'The Software itself does not provide any proxy server, node, subscription, or network access service, and has no partnership, agency, or guarantee relationship with any provider of such services.'**
  String get disclaimerNoServiceStatement;

  /// No description provided for @disclaimerUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'About use'**
  String get disclaimerUsageTitle;

  /// No description provided for @disclaimerUsageContent.
  ///
  /// In en, this message translates to:
  /// **'Any commercial activity anyone carries out with the Software, including paid distribution, bundled sales, or use as part of a commercial service, is unrelated to the Software\'s developers, who do not endorse, support, or guarantee it.\n\nYou are responsible for complying with the laws where you live, and you bear the consequences of any unlawful use of the Software.'**
  String get disclaimerUsageContent;

  /// No description provided for @disclaimerResponsibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Your responsibility'**
  String get disclaimerResponsibilityTitle;

  /// No description provided for @disclaimerResponsibilityContent.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for making sure that using the Software is lawful where you live, and you alone bear the legal responsibility for everything you do with it and its consequences.\n\nThe subscriptions, nodes, and configurations you import are your own choice. Whether their source is lawful, their content is safe, and their service is reliable is a matter between you and their providers.'**
  String get disclaimerResponsibilityContent;

  /// No description provided for @disclaimerThirdPartyTitle.
  ///
  /// In en, this message translates to:
  /// **'Third-party content'**
  String get disclaimerThirdPartyTitle;

  /// No description provided for @disclaimerThirdPartyContent.
  ///
  /// In en, this message translates to:
  /// **'Subscription links, configuration files, rule sets, scripts, external resources, and external links are all provided by third parties. The developers cannot and do not review or guarantee their legality, accuracy, security, or availability.\n\nAny data leak, financial loss, account ban, or other loss caused by third-party content is to be settled between you and the third party; the developers bear no responsibility for it.'**
  String get disclaimerThirdPartyContent;

  /// No description provided for @disclaimerWarrantyTitle.
  ///
  /// In en, this message translates to:
  /// **'No warranty'**
  String get disclaimerWarrantyTitle;

  /// No description provided for @disclaimerWarrantyContent.
  ///
  /// In en, this message translates to:
  /// **'The Software is provided \"as is\" and \"as available\", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, non-infringement, uninterrupted availability, freedom from errors, or freedom from security vulnerabilities.\n\nThe developers do not guarantee that the Software will meet your needs or that it will run without interruption or error.'**
  String get disclaimerWarrantyContent;

  /// No description provided for @disclaimerLiabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Limitation of liability'**
  String get disclaimerLiabilityTitle;

  /// No description provided for @disclaimerLiabilityContent.
  ///
  /// In en, this message translates to:
  /// **'To the maximum extent permitted by applicable law, neither the developers nor any contributor shall be liable for any direct, indirect, incidental, special, punitive, or consequential damages arising from the use of or inability to use the Software, including but not limited to data loss, device damage, network failures, business interruption, lost profits, or any resulting legal dispute, even if advised of the possibility of such damages.'**
  String get disclaimerLiabilityContent;

  /// No description provided for @disclaimerPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Data collection and privacy'**
  String get disclaimerPrivacyTitle;

  /// No description provided for @disclaimerPrivacyContent.
  ///
  /// In en, this message translates to:
  /// **'The Software does not collect or upload your subscription URLs, node details, configuration content, visited websites, connection records, traffic content, or logs. This data stays on your device and the developers have no access to it.\n\nThe Software only reaches the network when you use a feature that needs it, such as fetching the subscription URL you provided when updating a profile, or contacting GitHub when checking for updates.\n\nThe Software includes no analytics or crash reporting service on any platform.'**
  String get disclaimerPrivacyContent;

  /// No description provided for @disclaimerLicenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Open-source license'**
  String get disclaimerLicenseTitle;

  /// No description provided for @disclaimerLicenseContent.
  ///
  /// In en, this message translates to:
  /// **'The Software is open source under the GPL-3.0 license. Under that license you may run, study, modify, and distribute it; when you distribute the Software or a modified version, you must provide its source code under GPL-3.0 as well and keep the original copyright notices.\n\nThird-party components in the Software, including the Clash.Meta core, follow their own licenses. The original authors are not responsible for any problem arising from versions modified or distributed by others.'**
  String get disclaimerLicenseContent;

  /// No description provided for @disclaimerChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes to this statement'**
  String get disclaimerChangesTitle;

  /// No description provided for @disclaimerChangesContent.
  ///
  /// In en, this message translates to:
  /// **'This statement may be revised in later releases; each release carries the version that applies to it.'**
  String get disclaimerChangesContent;

  /// No description provided for @disclaimerAcceptTitle.
  ///
  /// In en, this message translates to:
  /// **'Relation to the open-source license'**
  String get disclaimerAcceptTitle;

  /// No description provided for @disclaimerAcceptContent.
  ///
  /// In en, this message translates to:
  /// **'This statement explains the nature, risks, and responsibilities of using the Software. It is not an additional term beyond GPL-3.0 and does not limit any right that license grants you, including to run, copy, modify, and distribute the Software. Where the two differ, GPL-3.0 prevails.'**
  String get disclaimerAcceptContent;

  /// No description provided for @disclaimerRestateTitle.
  ///
  /// In en, this message translates to:
  /// **'Restate the statement'**
  String get disclaimerRestateTitle;

  /// No description provided for @disclaimerRestateTip.
  ///
  /// In en, this message translates to:
  /// **'To confirm you understand, enter the following statement in full in the field below:'**
  String get disclaimerRestateTip;

  /// No description provided for @disclaimerRestateHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the statement above'**
  String get disclaimerRestateHint;

  /// No description provided for @disclaimerRestateMismatch.
  ///
  /// In en, this message translates to:
  /// **'Does not match the statement'**
  String get disclaimerRestateMismatch;

  /// No description provided for @disclaimerAcknowledgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm the statement'**
  String get disclaimerAcknowledgeTitle;

  /// No description provided for @disclaimerAcknowledgeTip.
  ///
  /// In en, this message translates to:
  /// **'To confirm you understand, read the following statement and check the box below:'**
  String get disclaimerAcknowledgeTip;

  /// No description provided for @disclaimerAcknowledgeLabel.
  ///
  /// In en, this message translates to:
  /// **'I have read and understand this statement'**
  String get disclaimerAcknowledgeLabel;

  /// No description provided for @agree.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get agree;

  /// No description provided for @hotkeyManagement.
  ///
  /// In en, this message translates to:
  /// **'Hotkey management'**
  String get hotkeyManagement;

  /// No description provided for @hotkeyDesc.
  ///
  /// In en, this message translates to:
  /// **'Global hotkeys work even while the window is hidden. Tap an action to record its key combination.'**
  String get hotkeyDesc;

  /// No description provided for @hotkeyNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get hotkeyNotSet;

  /// No description provided for @pressKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Press a key combination'**
  String get pressKeyboard;

  /// No description provided for @hotkeyNeedsModifier.
  ///
  /// In en, this message translates to:
  /// **'Include at least one of {modifiers}'**
  String hotkeyNeedsModifier(Object modifiers);

  /// No description provided for @hotkeyConflictWith.
  ///
  /// In en, this message translates to:
  /// **'Already used by “{action}”. Saving moves it here.'**
  String hotkeyConflictWith(Object action);

  /// No description provided for @hotkeyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not registered, it may be taken by another app'**
  String get hotkeyUnavailable;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @noNetwork.
  ///
  /// In en, this message translates to:
  /// **'No network'**
  String get noNetwork;

  /// No description provided for @exportLogs.
  ///
  /// In en, this message translates to:
  /// **'Export logs'**
  String get exportLogs;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export successful'**
  String get exportSuccess;

  /// No description provided for @iconStyle.
  ///
  /// In en, this message translates to:
  /// **'Icon style'**
  String get iconStyle;

  /// No description provided for @iconStyleFilled.
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get iconStyleFilled;

  /// No description provided for @iconStylePlain.
  ///
  /// In en, this message translates to:
  /// **'Plain'**
  String get iconStylePlain;

  /// No description provided for @iconStyleHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get iconStyleHidden;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @groupBy.
  ///
  /// In en, this message translates to:
  /// **'Group by'**
  String get groupBy;

  /// No description provided for @hideTimeoutProxies.
  ///
  /// In en, this message translates to:
  /// **'Hide timed-out proxies'**
  String get hideTimeoutProxies;

  /// No description provided for @stackMode.
  ///
  /// In en, this message translates to:
  /// **'Stack mode'**
  String get stackMode;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @bypassDomain.
  ///
  /// In en, this message translates to:
  /// **'Bypass domains'**
  String get bypassDomain;

  /// No description provided for @pacMode.
  ///
  /// In en, this message translates to:
  /// **'PAC mode'**
  String get pacMode;

  /// No description provided for @pacScript.
  ///
  /// In en, this message translates to:
  /// **'PAC script'**
  String get pacScript;

  /// No description provided for @bypassDomainDesc.
  ///
  /// In en, this message translates to:
  /// **'Bypass domains apply only while the system proxy is on.'**
  String get bypassDomainDesc;

  /// No description provided for @bypassLocalWindowsOnly.
  ///
  /// In en, this message translates to:
  /// **'Windows only: host names without a dot'**
  String get bypassLocalWindowsOnly;

  /// No description provided for @resetTip.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset?'**
  String get resetTip;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @fontFamily.
  ///
  /// In en, this message translates to:
  /// **'Font family'**
  String get fontFamily;

  /// No description provided for @installedFonts.
  ///
  /// In en, this message translates to:
  /// **'Installed fonts'**
  String get installedFonts;

  /// No description provided for @toggle.
  ///
  /// In en, this message translates to:
  /// **'Toggle'**
  String get toggle;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @routeAddress.
  ///
  /// In en, this message translates to:
  /// **'Route addresses'**
  String get routeAddress;

  /// No description provided for @interfaceNameMode.
  ///
  /// In en, this message translates to:
  /// **'Outbound interface'**
  String get interfaceNameMode;

  /// No description provided for @interfaceNameModeClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get interfaceNameModeClear;

  /// No description provided for @interfaceNameModeFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow config'**
  String get interfaceNameModeFollow;

  /// No description provided for @interfaceNameModeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get interfaceNameModeCustom;

  /// No description provided for @interfaceName.
  ///
  /// In en, this message translates to:
  /// **'Interface name'**
  String get interfaceName;

  /// No description provided for @copyEnvVar.
  ///
  /// In en, this message translates to:
  /// **'Copy environment variables'**
  String get copyEnvVar;

  /// No description provided for @memoryInfo.
  ///
  /// In en, this message translates to:
  /// **'Memory info'**
  String get memoryInfo;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @releaseMemory.
  ///
  /// In en, this message translates to:
  /// **'Release memory'**
  String get releaseMemory;

  /// No description provided for @memoryCoreHeapInuse.
  ///
  /// In en, this message translates to:
  /// **'Heap in use'**
  String get memoryCoreHeapInuse;

  /// No description provided for @memoryCoreHeapIdle.
  ///
  /// In en, this message translates to:
  /// **'Heap idle'**
  String get memoryCoreHeapIdle;

  /// No description provided for @memoryCoreStack.
  ///
  /// In en, this message translates to:
  /// **'Goroutine stacks'**
  String get memoryCoreStack;

  /// No description provided for @memoryCoreRuntime.
  ///
  /// In en, this message translates to:
  /// **'Runtime overhead'**
  String get memoryCoreRuntime;

  /// No description provided for @memoryCoreNotRunning.
  ///
  /// In en, this message translates to:
  /// **'Core is not running'**
  String get memoryCoreNotRunning;

  /// No description provided for @memoryAppResident.
  ///
  /// In en, this message translates to:
  /// **'Resident memory'**
  String get memoryAppResident;

  /// No description provided for @memoryAppShared.
  ///
  /// In en, this message translates to:
  /// **'App & shared'**
  String get memoryAppShared;

  /// No description provided for @memoryEstimateDesc.
  ///
  /// In en, this message translates to:
  /// **'Estimated from process resident memory; it may differ from what the system reports.'**
  String get memoryEstimateDesc;

  /// No description provided for @memoryEstimateSharedDesc.
  ///
  /// In en, this message translates to:
  /// **'The Core runs inside the app process. Its share is estimated from runtime stats, and the rest counts as app and shared memory.'**
  String get memoryEstimateSharedDesc;

  /// No description provided for @memoryReleased.
  ///
  /// In en, this message translates to:
  /// **'Memory released'**
  String get memoryReleased;

  /// No description provided for @memoryReleasedSize.
  ///
  /// In en, this message translates to:
  /// **'Released {size}'**
  String memoryReleasedSize(Object size);

  /// No description provided for @releaseMemoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to release memory'**
  String get releaseMemoryFailed;

  /// No description provided for @dialog.
  ///
  /// In en, this message translates to:
  /// **'Dialog'**
  String get dialog;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @fileIsUpdate.
  ///
  /// In en, this message translates to:
  /// **'The file has been modified. Save the changes?'**
  String get fileIsUpdate;

  /// No description provided for @profileHasUpdate.
  ///
  /// In en, this message translates to:
  /// **'The profile has been modified. Turn off auto update?'**
  String get profileHasUpdate;

  /// No description provided for @hasCacheChange.
  ///
  /// In en, this message translates to:
  /// **'Cache the changes?'**
  String get hasCacheChange;

  /// No description provided for @copySuccess.
  ///
  /// In en, this message translates to:
  /// **'Copied successfully'**
  String get copySuccess;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @exportFile.
  ///
  /// In en, this message translates to:
  /// **'Export file'**
  String get exportFile;

  /// No description provided for @cacheCorrupt.
  ///
  /// In en, this message translates to:
  /// **'The cache is corrupted. Clear it?'**
  String get cacheCorrupt;

  /// No description provided for @detectionTip.
  ///
  /// In en, this message translates to:
  /// **'Relies on a third-party API; for reference only'**
  String get detectionTip;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @lineWrap.
  ///
  /// In en, this message translates to:
  /// **'Word wrap'**
  String get lineWrap;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @advancedConfig.
  ///
  /// In en, this message translates to:
  /// **'Advanced configuration'**
  String get advancedConfig;

  /// No description provided for @addRule.
  ///
  /// In en, this message translates to:
  /// **'Add rule'**
  String get addRule;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @ruleTarget.
  ///
  /// In en, this message translates to:
  /// **'Rule target'**
  String get ruleTarget;

  /// No description provided for @exitDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get exitDefault;

  /// No description provided for @customExit.
  ///
  /// In en, this message translates to:
  /// **'Custom exit'**
  String get customExit;

  /// No description provided for @inputExitName.
  ///
  /// In en, this message translates to:
  /// **'Enter the exit name'**
  String get inputExitName;

  /// No description provided for @scriptFailed.
  ///
  /// In en, this message translates to:
  /// **'The script failed'**
  String get scriptFailed;

  /// No description provided for @sourceIp.
  ///
  /// In en, this message translates to:
  /// **'Source IP'**
  String get sourceIp;

  /// No description provided for @noResolve.
  ///
  /// In en, this message translates to:
  /// **'Don\'t resolve IP'**
  String get noResolve;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save the changes?'**
  String get saveChanges;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply now'**
  String get applyNow;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// No description provided for @cannotSave.
  ///
  /// In en, this message translates to:
  /// **'Can\'t save'**
  String get cannotSave;

  /// No description provided for @navigationBarStyle.
  ///
  /// In en, this message translates to:
  /// **'Bottom bar'**
  String get navigationBarStyle;

  /// No description provided for @floating.
  ///
  /// In en, this message translates to:
  /// **'Floating'**
  String get floating;

  /// No description provided for @docked.
  ///
  /// In en, this message translates to:
  /// **'Docked'**
  String get docked;

  /// No description provided for @slide.
  ///
  /// In en, this message translates to:
  /// **'Slide'**
  String get slide;

  /// No description provided for @fade.
  ///
  /// In en, this message translates to:
  /// **'Fade'**
  String get fade;

  /// No description provided for @pureBlack.
  ///
  /// In en, this message translates to:
  /// **'Pure black'**
  String get pureBlack;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom color'**
  String get customColor;

  /// No description provided for @colorStyle.
  ///
  /// In en, this message translates to:
  /// **'Color style'**
  String get colorStyle;

  /// No description provided for @grid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get grid;

  /// No description provided for @spectrum.
  ///
  /// In en, this message translates to:
  /// **'Spectrum'**
  String get spectrum;

  /// No description provided for @sliders.
  ///
  /// In en, this message translates to:
  /// **'Sliders'**
  String get sliders;

  /// No description provided for @hue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get hue;

  /// No description provided for @saturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get saturation;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @hex.
  ///
  /// In en, this message translates to:
  /// **'Hex'**
  String get hex;

  /// No description provided for @monochromeScheme.
  ///
  /// In en, this message translates to:
  /// **'Monochrome'**
  String get monochromeScheme;

  /// No description provided for @vividStyle.
  ///
  /// In en, this message translates to:
  /// **'Vivid'**
  String get vividStyle;

  /// No description provided for @tintedStyle.
  ///
  /// In en, this message translates to:
  /// **'Tinted'**
  String get tintedStyle;

  /// No description provided for @softStyle.
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get softStyle;

  /// No description provided for @developerMode.
  ///
  /// In en, this message translates to:
  /// **'Developer mode'**
  String get developerMode;

  /// No description provided for @developerModeEnableTip.
  ///
  /// In en, this message translates to:
  /// **'Developer mode is enabled.'**
  String get developerModeEnableTip;

  /// No description provided for @messageTest.
  ///
  /// In en, this message translates to:
  /// **'Message test'**
  String get messageTest;

  /// No description provided for @messageTestTip.
  ///
  /// In en, this message translates to:
  /// **'This is a message.'**
  String get messageTestTip;

  /// No description provided for @crashTest.
  ///
  /// In en, this message translates to:
  /// **'Crash test'**
  String get crashTest;

  /// No description provided for @crashDetected.
  ///
  /// In en, this message translates to:
  /// **'Crash detected'**
  String get crashDetected;

  /// No description provided for @crashDetectedTip.
  ///
  /// In en, this message translates to:
  /// **'The app failed to finish launching twice in a row. To break the loop, the profile {name} has been deselected and automatic setup was skipped. You can select it again at any time.'**
  String crashDetectedTip(Object name);

  /// No description provided for @launchInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Launch did not finish'**
  String get launchInterrupted;

  /// No description provided for @launchInterruptedTip.
  ///
  /// In en, this message translates to:
  /// **'The app exited unexpectedly while it was starting up last time. Automatic setup was skipped for this launch; you can start it manually to retry.'**
  String get launchInterruptedTip;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear data'**
  String get clearData;

  /// No description provided for @textScale.
  ///
  /// In en, this message translates to:
  /// **'Text scaling'**
  String get textScale;

  /// No description provided for @textScalePreview.
  ///
  /// In en, this message translates to:
  /// **'Text in the app will look like this'**
  String get textScalePreview;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get followSystem;

  /// No description provided for @internet.
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get internet;

  /// No description provided for @systemApp.
  ///
  /// In en, this message translates to:
  /// **'System apps'**
  String get systemApp;

  /// No description provided for @noNetworkApp.
  ///
  /// In en, this message translates to:
  /// **'No-network apps'**
  String get noNetworkApp;

  /// No description provided for @restoreStrategy.
  ///
  /// In en, this message translates to:
  /// **'Restore strategy'**
  String get restoreStrategy;

  /// No description provided for @restoreStrategyOverride.
  ///
  /// In en, this message translates to:
  /// **'Override'**
  String get restoreStrategyOverride;

  /// No description provided for @restoreStrategyCompatible.
  ///
  /// In en, this message translates to:
  /// **'Compatible'**
  String get restoreStrategyCompatible;

  /// No description provided for @logsTest.
  ///
  /// In en, this message translates to:
  /// **'Logs test'**
  String get logsTest;

  /// No description provided for @emptyTip.
  ///
  /// In en, this message translates to:
  /// **'{label} cannot be empty'**
  String emptyTip(Object label);

  /// No description provided for @urlTip.
  ///
  /// In en, this message translates to:
  /// **'{label} must be a URL'**
  String urlTip(Object label);

  /// No description provided for @invalidLinkTip.
  ///
  /// In en, this message translates to:
  /// **'Not a subscription link or a proxy share link'**
  String get invalidLinkTip;

  /// No description provided for @numberTip.
  ///
  /// In en, this message translates to:
  /// **'{label} must be a number'**
  String numberTip(Object label);

  /// No description provided for @numberRangeTip.
  ///
  /// In en, this message translates to:
  /// **'{label} must be between {min} and {max}'**
  String numberRangeTip(Object label, Object min, Object max);

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// No description provided for @existsTip.
  ///
  /// In en, this message translates to:
  /// **'{label} already exists'**
  String existsTip(Object label);

  /// No description provided for @maxLengthTip.
  ///
  /// In en, this message translates to:
  /// **'{label} must be at most {max} characters'**
  String maxLengthTip(Object label, Object max);

  /// No description provided for @singleImport.
  ///
  /// In en, this message translates to:
  /// **'Single import'**
  String get singleImport;

  /// No description provided for @batchImport.
  ///
  /// In en, this message translates to:
  /// **'Batch import'**
  String get batchImport;

  /// No description provided for @batchUrlInputTip.
  ///
  /// In en, this message translates to:
  /// **'One URL per line'**
  String get batchUrlInputTip;

  /// No description provided for @batchLinkInputTip.
  ///
  /// In en, this message translates to:
  /// **'One link per line'**
  String get batchLinkInputTip;

  /// No description provided for @batchPreviewTip.
  ///
  /// In en, this message translates to:
  /// **'{count} to add, {skipped} skipped as existing'**
  String batchPreviewTip(Object count, Object skipped);

  /// No description provided for @lineIssueTip.
  ///
  /// In en, this message translates to:
  /// **'Line {line}: {message}'**
  String lineIssueTip(Object line, Object message);

  /// No description provided for @singleValueTip.
  ///
  /// In en, this message translates to:
  /// **'{label} must be a single item'**
  String singleValueTip(Object label);

  /// No description provided for @deleteTip.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this {label}?'**
  String deleteTip(Object label);

  /// No description provided for @deleteMultipTip.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the selected {label}?'**
  String deleteMultipTip(Object label);

  /// No description provided for @nullTip.
  ///
  /// In en, this message translates to:
  /// **'No {label} yet'**
  String nullTip(Object label);

  /// No description provided for @script.
  ///
  /// In en, this message translates to:
  /// **'Script'**
  String get script;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @unnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get unnamed;

  /// No description provided for @pleaseEnterScriptName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a script name'**
  String get pleaseEnterScriptName;

  /// No description provided for @mixedPort.
  ///
  /// In en, this message translates to:
  /// **'Mixed port'**
  String get mixedPort;

  /// No description provided for @socksPort.
  ///
  /// In en, this message translates to:
  /// **'SOCKS port'**
  String get socksPort;

  /// No description provided for @redirPort.
  ///
  /// In en, this message translates to:
  /// **'Redir port'**
  String get redirPort;

  /// No description provided for @tproxyPort.
  ///
  /// In en, this message translates to:
  /// **'TProxy port'**
  String get tproxyPort;

  /// No description provided for @portTip.
  ///
  /// In en, this message translates to:
  /// **'{label} must be between 1024 and 49151'**
  String portTip(Object label);

  /// No description provided for @portConflictTip.
  ///
  /// In en, this message translates to:
  /// **'Please enter a different port'**
  String get portConflictTip;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @importFile.
  ///
  /// In en, this message translates to:
  /// **'Import from file'**
  String get importFile;

  /// No description provided for @importUrl.
  ///
  /// In en, this message translates to:
  /// **'Import from URL'**
  String get importUrl;

  /// No description provided for @startFromScratch.
  ///
  /// In en, this message translates to:
  /// **'Start from scratch'**
  String get startFromScratch;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'{label} details'**
  String details(Object label);

  /// No description provided for @creationTime.
  ///
  /// In en, this message translates to:
  /// **'Creation time'**
  String get creationTime;

  /// No description provided for @process.
  ///
  /// In en, this message translates to:
  /// **'Process'**
  String get process;

  /// No description provided for @host.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @destinationGeoIP.
  ///
  /// In en, this message translates to:
  /// **'Destination GeoIP'**
  String get destinationGeoIP;

  /// No description provided for @destinationIPASN.
  ///
  /// In en, this message translates to:
  /// **'Destination IP ASN'**
  String get destinationIPASN;

  /// No description provided for @specialProxy.
  ///
  /// In en, this message translates to:
  /// **'Special proxy'**
  String get specialProxy;

  /// No description provided for @specialRules.
  ///
  /// In en, this message translates to:
  /// **'Special rules'**
  String get specialRules;

  /// No description provided for @remoteDestination.
  ///
  /// In en, this message translates to:
  /// **'Remote destination'**
  String get remoteDestination;

  /// No description provided for @networkType.
  ///
  /// In en, this message translates to:
  /// **'Network type'**
  String get networkType;

  /// No description provided for @proxyChains.
  ///
  /// In en, this message translates to:
  /// **'Proxy chain'**
  String get proxyChains;

  /// No description provided for @log.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get log;

  /// No description provided for @connection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connection;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// No description provided for @restartCoreTip.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restart the core?'**
  String get restartCoreTip;

  /// No description provided for @forceRestartCoreTip.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to force restart the core?'**
  String get forceRestartCoreTip;

  /// No description provided for @dnsHijacking.
  ///
  /// In en, this message translates to:
  /// **'DNS hijacking'**
  String get dnsHijacking;

  /// No description provided for @coreStatus.
  ///
  /// In en, this message translates to:
  /// **'Core status'**
  String get coreStatus;

  /// No description provided for @appendSystemDns.
  ///
  /// In en, this message translates to:
  /// **'Append system DNS'**
  String get appendSystemDns;

  /// No description provided for @editRule.
  ///
  /// In en, this message translates to:
  /// **'Edit rule'**
  String get editRule;

  /// No description provided for @addedRules.
  ///
  /// In en, this message translates to:
  /// **'Added rules'**
  String get addedRules;

  /// No description provided for @addedRulesAfterScript.
  ///
  /// In en, this message translates to:
  /// **'Inserted after the script runs, ahead of the profile\'s rules'**
  String get addedRulesAfterScript;

  /// No description provided for @controlGlobalAddedRules.
  ///
  /// In en, this message translates to:
  /// **'Control global added rules'**
  String get controlGlobalAddedRules;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @rulePresetBlockQuic.
  ///
  /// In en, this message translates to:
  /// **'Block QUIC'**
  String get rulePresetBlockQuic;

  /// No description provided for @rulePresetBlockStun.
  ///
  /// In en, this message translates to:
  /// **'Block STUN'**
  String get rulePresetBlockStun;

  /// No description provided for @rulePresetBlockDot.
  ///
  /// In en, this message translates to:
  /// **'Block DNS over TLS'**
  String get rulePresetBlockDot;

  /// No description provided for @rulePresetBlockLoopback.
  ///
  /// In en, this message translates to:
  /// **'Block proxy loopback'**
  String get rulePresetBlockLoopback;

  /// No description provided for @rulePresetSystemServicesDirect.
  ///
  /// In en, this message translates to:
  /// **'Apple and Microsoft direct'**
  String get rulePresetSystemServicesDirect;

  /// No description provided for @rulePresetBittorrentDirect.
  ///
  /// In en, this message translates to:
  /// **'BitTorrent direct'**
  String get rulePresetBittorrentDirect;

  /// No description provided for @rulePresetLanDirect.
  ///
  /// In en, this message translates to:
  /// **'LAN direct'**
  String get rulePresetLanDirect;

  /// No description provided for @extendScript.
  ///
  /// In en, this message translates to:
  /// **'Extend script'**
  String get extendScript;

  /// No description provided for @goToConfigureScript.
  ///
  /// In en, this message translates to:
  /// **'Go to script configuration'**
  String get goToConfigureScript;

  /// No description provided for @goToConfigureAddedRules.
  ///
  /// In en, this message translates to:
  /// **'Go to added rules configuration'**
  String get goToConfigureAddedRules;

  /// No description provided for @editGlobalRules.
  ///
  /// In en, this message translates to:
  /// **'Edit global rules'**
  String get editGlobalRules;

  /// No description provided for @confirmForceCrashCore.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to force crash the core?'**
  String get confirmForceCrashCore;

  /// No description provided for @confirmClearAllData.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all data?'**
  String get confirmClearAllData;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @yearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year ago} other{{count} years ago}}'**
  String yearsAgo(num count);

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month ago} other{{count} months ago}}'**
  String monthsAgo(num count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String daysAgo(num count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String hoursAgo(num count);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String minutesAgo(num count);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @yearsAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count}y ago}}'**
  String yearsAgoShort(num count);

  /// No description provided for @monthsAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count}mo ago}}'**
  String monthsAgoShort(num count);

  /// No description provided for @daysAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count}d ago}}'**
  String daysAgoShort(num count);

  /// No description provided for @hoursAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count}h ago}}'**
  String hoursAgoShort(num count);

  /// No description provided for @minutesAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count}m ago}}'**
  String minutesAgoShort(num count);

  /// No description provided for @noLongerRemind.
  ///
  /// In en, this message translates to:
  /// **'Don\'t remind me again'**
  String get noLongerRemind;

  /// No description provided for @turnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOn;

  /// No description provided for @turnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get turnOff;

  /// No description provided for @vpnConfigChangeDetected.
  ///
  /// In en, this message translates to:
  /// **'VPN settings changed. Tap to restart'**
  String get vpnConfigChangeDetected;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @speedStatistics.
  ///
  /// In en, this message translates to:
  /// **'Speed statistics'**
  String get speedStatistics;

  /// No description provided for @resetPageChangesTip.
  ///
  /// In en, this message translates to:
  /// **'This page has changes. Are you sure you want to reset?'**
  String get resetPageChangesTip;

  /// No description provided for @customProfile.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customProfile;

  /// No description provided for @customResources.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customResources;

  /// No description provided for @unknownNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Unknown network error'**
  String get unknownNetworkError;

  /// No description provided for @backupFromNewerVersion.
  ///
  /// In en, this message translates to:
  /// **'This backup comes from a newer version of the app. Update the app before restoring it'**
  String get backupFromNewerVersion;

  /// No description provided for @networkTimeoutError.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Check your network or proxy, then try again'**
  String get networkTimeoutError;

  /// No description provided for @networkHostLookupError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t resolve the server address. Check that the URL is correct and DNS is working'**
  String get networkHostLookupError;

  /// No description provided for @monochromeIcon.
  ///
  /// In en, this message translates to:
  /// **'Monochrome icon'**
  String get monochromeIcon;

  /// No description provided for @networkConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect to the server. Check your network connection or proxy settings'**
  String get networkConnectionError;

  /// No description provided for @networkTlsError.
  ///
  /// In en, this message translates to:
  /// **'Secure connection failed. The server\'s certificate may be invalid, or the connection is being intercepted'**
  String get networkTlsError;

  /// No description provided for @networkCancelledError.
  ///
  /// In en, this message translates to:
  /// **'The request was cancelled'**
  String get networkCancelledError;

  /// No description provided for @networkAccessDeniedError.
  ///
  /// In en, this message translates to:
  /// **'The server denied access (HTTP {code}). The link may have expired, or the credentials are wrong'**
  String networkAccessDeniedError(Object code);

  /// No description provided for @networkNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'Nothing was found at this address (HTTP {code}). Check that the URL is correct'**
  String networkNotFoundError(Object code);

  /// No description provided for @networkRateLimitedError.
  ///
  /// In en, this message translates to:
  /// **'Too many requests (HTTP 429). Wait a moment and try again'**
  String get networkRateLimitedError;

  /// No description provided for @networkServerError.
  ///
  /// In en, this message translates to:
  /// **'The server ran into a problem (HTTP {code}). Try again later'**
  String networkServerError(Object code);

  /// No description provided for @networkBadResponseError.
  ///
  /// In en, this message translates to:
  /// **'The server rejected the request (HTTP {code})'**
  String networkBadResponseError(Object code);

  /// No description provided for @networkRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Network request failed: {detail}'**
  String networkRequestFailed(Object detail);

  /// No description provided for @invalidBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid backup file'**
  String get invalidBackupFile;

  /// No description provided for @pruneCache.
  ///
  /// In en, this message translates to:
  /// **'Prune cache'**
  String get pruneCache;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore'**
  String get backupAndRestore;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restore successful'**
  String get restoreSuccess;

  /// No description provided for @restoreOnlyConfig.
  ///
  /// In en, this message translates to:
  /// **'Restore profiles only'**
  String get restoreOnlyConfig;

  /// No description provided for @restoreAllData.
  ///
  /// In en, this message translates to:
  /// **'Restore all data'**
  String get restoreAllData;

  /// No description provided for @addProfile.
  ///
  /// In en, this message translates to:
  /// **'Add profile'**
  String get addProfile;

  /// No description provided for @delayTest.
  ///
  /// In en, this message translates to:
  /// **'Delay test'**
  String get delayTest;

  /// No description provided for @proxyGroupEmpty.
  ///
  /// In en, this message translates to:
  /// **'Proxy group is empty'**
  String get proxyGroupEmpty;

  /// No description provided for @confirmExitWindow.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the current window?'**
  String get confirmExitWindow;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @maxFailedTimes.
  ///
  /// In en, this message translates to:
  /// **'Max failures'**
  String get maxFailedTimes;

  /// No description provided for @testInterval.
  ///
  /// In en, this message translates to:
  /// **'Test interval'**
  String get testInterval;

  /// No description provided for @excludeFilter.
  ///
  /// In en, this message translates to:
  /// **'Exclude filter'**
  String get excludeFilter;

  /// No description provided for @expectedStatus.
  ///
  /// In en, this message translates to:
  /// **'Expected status'**
  String get expectedStatus;

  /// No description provided for @strategy.
  ///
  /// In en, this message translates to:
  /// **'Strategy'**
  String get strategy;

  /// No description provided for @tolerance.
  ///
  /// In en, this message translates to:
  /// **'Tolerance'**
  String get tolerance;

  /// No description provided for @inputProxyGroupName.
  ///
  /// In en, this message translates to:
  /// **'Enter the proxy group name'**
  String get inputProxyGroupName;

  /// No description provided for @helperCorruptTip.
  ///
  /// In en, this message translates to:
  /// **'Helper service unavailable; TUN mode cannot be enabled. Reinstall FlClash to restore it.'**
  String get helperCorruptTip;

  /// No description provided for @tunAuthorizationFailed.
  ///
  /// In en, this message translates to:
  /// **'TUN could not be authorized, so it was turned off.'**
  String get tunAuthorizationFailed;

  /// No description provided for @sudoPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your password for sudo'**
  String get sudoPasswordTitle;

  /// No description provided for @coreBlockedByPolicyTip.
  ///
  /// In en, this message translates to:
  /// **'Windows refused to run FlClashCore.exe (error {code}). An app control policy such as Smart App Control or AppLocker blocks unsigned programs; allow FlClash in that policy or turn it off, then try again.'**
  String coreBlockedByPolicyTip(Object code);

  /// No description provided for @coreBlockedBySmartAppControlTip.
  ///
  /// In en, this message translates to:
  /// **'Windows Smart App Control blocked FlClashCore.exe because it is not signed. Open Windows Security → App & browser control → Smart App Control settings, choose Off, then start FlClash again. Smart App Control cannot be turned back on without reinstalling Windows.'**
  String get coreBlockedBySmartAppControlTip;

  /// No description provided for @hideFromList.
  ///
  /// In en, this message translates to:
  /// **'Hide from list'**
  String get hideFromList;

  /// No description provided for @testWhenUsed.
  ///
  /// In en, this message translates to:
  /// **'Test when used'**
  String get testWhenUsed;

  /// No description provided for @disableUDP.
  ///
  /// In en, this message translates to:
  /// **'Disable UDP'**
  String get disableUDP;

  /// No description provided for @confirmDeleteProxyGroup.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this proxy group?'**
  String get confirmDeleteProxyGroup;

  /// No description provided for @ruleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Rule is empty'**
  String get ruleEmpty;

  /// No description provided for @inputRuleContent.
  ///
  /// In en, this message translates to:
  /// **'Enter the rule content'**
  String get inputRuleContent;

  /// No description provided for @ruleSet.
  ///
  /// In en, this message translates to:
  /// **'Rule set'**
  String get ruleSet;

  /// No description provided for @selectRuleSet.
  ///
  /// In en, this message translates to:
  /// **'Please select a rule set'**
  String get selectRuleSet;

  /// No description provided for @splitStrategy.
  ///
  /// In en, this message translates to:
  /// **'Split strategy'**
  String get splitStrategy;

  /// No description provided for @selectSplitStrategy.
  ///
  /// In en, this message translates to:
  /// **'Please select a split strategy'**
  String get selectSplitStrategy;

  /// No description provided for @noResolveHostname.
  ///
  /// In en, this message translates to:
  /// **'Don\'t resolve hostname'**
  String get noResolveHostname;

  /// No description provided for @matchSourceIp.
  ///
  /// In en, this message translates to:
  /// **'Match source IP'**
  String get matchSourceIp;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic info'**
  String get basicInfo;

  /// No description provided for @additionalParameters.
  ///
  /// In en, this message translates to:
  /// **'Additional parameters'**
  String get additionalParameters;

  /// No description provided for @proxyType.
  ///
  /// In en, this message translates to:
  /// **'Proxy type'**
  String get proxyType;

  /// No description provided for @basicStrategy.
  ///
  /// In en, this message translates to:
  /// **'Basic strategies'**
  String get basicStrategy;

  /// No description provided for @editProxy.
  ///
  /// In en, this message translates to:
  /// **'Edit proxy'**
  String get editProxy;

  /// No description provided for @addNodes.
  ///
  /// In en, this message translates to:
  /// **'Add nodes'**
  String get addNodes;

  /// No description provided for @addProxyGroup.
  ///
  /// In en, this message translates to:
  /// **'Add proxy group'**
  String get addProxyGroup;

  /// No description provided for @editProxyGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit proxy group'**
  String get editProxyGroup;

  /// No description provided for @iconUrl.
  ///
  /// In en, this message translates to:
  /// **'Icon URL'**
  String get iconUrl;

  /// No description provided for @iconRecords.
  ///
  /// In en, this message translates to:
  /// **'Icon records'**
  String get iconRecords;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @ruleActionDomainDesc.
  ///
  /// In en, this message translates to:
  /// **'Match the full domain'**
  String get ruleActionDomainDesc;

  /// No description provided for @ruleActionDomainSuffixDesc.
  ///
  /// In en, this message translates to:
  /// **'Match a domain suffix'**
  String get ruleActionDomainSuffixDesc;

  /// No description provided for @ruleActionDomainKeywordDesc.
  ///
  /// In en, this message translates to:
  /// **'Match a domain keyword'**
  String get ruleActionDomainKeywordDesc;

  /// No description provided for @ruleActionDomainRegexDesc.
  ///
  /// In en, this message translates to:
  /// **'Match a domain regex'**
  String get ruleActionDomainRegexDesc;

  /// No description provided for @ruleActionDomainWildcardDesc.
  ///
  /// In en, this message translates to:
  /// **'Wildcard match; only * and ? are supported'**
  String get ruleActionDomainWildcardDesc;

  /// No description provided for @ruleActionGeositeDesc.
  ///
  /// In en, this message translates to:
  /// **'Match domains in Geosite'**
  String get ruleActionGeositeDesc;

  /// No description provided for @ruleActionIpCidrDesc.
  ///
  /// In en, this message translates to:
  /// **'Match an IP address range'**
  String get ruleActionIpCidrDesc;

  /// No description provided for @ruleActionIpCidr6Desc.
  ///
  /// In en, this message translates to:
  /// **'Match an IP address range; IP-CIDR6 is just an alias'**
  String get ruleActionIpCidr6Desc;

  /// No description provided for @ruleActionIpSuffixDesc.
  ///
  /// In en, this message translates to:
  /// **'Match an IP suffix range'**
  String get ruleActionIpSuffixDesc;

  /// No description provided for @ruleActionIpAsnDesc.
  ///
  /// In en, this message translates to:
  /// **'Match the IP\'s ASN'**
  String get ruleActionIpAsnDesc;

  /// No description provided for @ruleActionGeoipDesc.
  ///
  /// In en, this message translates to:
  /// **'Match the IP\'s country code'**
  String get ruleActionGeoipDesc;

  /// No description provided for @ruleActionSrcGeoipDesc.
  ///
  /// In en, this message translates to:
  /// **'Match the source IP\'s country code'**
  String get ruleActionSrcGeoipDesc;

  /// No description provided for @ruleActionSrcIpAsnDesc.
  ///
  /// In en, this message translates to:
  /// **'Match the source IP\'s ASN'**
  String get ruleActionSrcIpAsnDesc;

  /// No description provided for @ruleActionSrcIpCidrDesc.
  ///
  /// In en, this message translates to:
  /// **'Match a source IP address range'**
  String get ruleActionSrcIpCidrDesc;

  /// No description provided for @ruleActionSrcIpSuffixDesc.
  ///
  /// In en, this message translates to:
  /// **'Match a source IP suffix range'**
  String get ruleActionSrcIpSuffixDesc;

  /// No description provided for @ruleActionDstPortDesc.
  ///
  /// In en, this message translates to:
  /// **'Match the destination port range'**
  String get ruleActionDstPortDesc;

  /// No description provided for @ruleActionSrcPortDesc.
  ///
  /// In en, this message translates to:
  /// **'Match the source port range'**
  String get ruleActionSrcPortDesc;

  /// No description provided for @ruleActionInPortDesc.
  ///
  /// In en, this message translates to:
  /// **'Match the inbound port'**
  String get ruleActionInPortDesc;

  /// No description provided for @ruleActionInTypeDesc.
  ///
  /// In en, this message translates to:
  /// **'Match the inbound type'**
  String get ruleActionInTypeDesc;

  /// No description provided for @ruleActionInUserDesc.
  ///
  /// In en, this message translates to:
  /// **'Match the inbound username; separate multiple usernames with /'**
  String get ruleActionInUserDesc;

  /// No description provided for @ruleActionInNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Match the inbound name'**
  String get ruleActionInNameDesc;

  /// No description provided for @ruleActionRematchNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Match the rematch name; separate multiple names with /'**
  String get ruleActionRematchNameDesc;

  /// No description provided for @ruleActionProcessPathDesc.
  ///
  /// In en, this message translates to:
  /// **'Match by the full process path'**
  String get ruleActionProcessPathDesc;

  /// No description provided for @ruleActionProcessPathRegexDesc.
  ///
  /// In en, this message translates to:
  /// **'Match by process path regex'**
  String get ruleActionProcessPathRegexDesc;

  /// No description provided for @ruleActionProcessPathWildcardDesc.
  ///
  /// In en, this message translates to:
  /// **'Match by process path wildcard; only * and ? are supported'**
  String get ruleActionProcessPathWildcardDesc;

  /// No description provided for @ruleActionProcessNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Match by process name; matches the package name on Android'**
  String get ruleActionProcessNameDesc;

  /// No description provided for @ruleActionProcessNameRegexDesc.
  ///
  /// In en, this message translates to:
  /// **'Match by process name regex; matches the package name on Android'**
  String get ruleActionProcessNameRegexDesc;

  /// No description provided for @ruleActionProcessNameWildcardDesc.
  ///
  /// In en, this message translates to:
  /// **'Match by process name wildcard; only * and ? are supported'**
  String get ruleActionProcessNameWildcardDesc;

  /// No description provided for @ruleActionUidDesc.
  ///
  /// In en, this message translates to:
  /// **'Match the Linux user ID'**
  String get ruleActionUidDesc;

  /// No description provided for @ruleActionNetworkDesc.
  ///
  /// In en, this message translates to:
  /// **'Match TCP or UDP'**
  String get ruleActionNetworkDesc;

  /// No description provided for @ruleActionDscpDesc.
  ///
  /// In en, this message translates to:
  /// **'Match the DSCP mark (tproxy UDP inbound only)'**
  String get ruleActionDscpDesc;

  /// No description provided for @ruleActionRuleSetDesc.
  ///
  /// In en, this message translates to:
  /// **'Reference a rule set; requires rule-providers'**
  String get ruleActionRuleSetDesc;

  /// No description provided for @ruleActionAndDesc.
  ///
  /// In en, this message translates to:
  /// **'Logical rule AND'**
  String get ruleActionAndDesc;

  /// No description provided for @ruleActionOrDesc.
  ///
  /// In en, this message translates to:
  /// **'Logical rule OR'**
  String get ruleActionOrDesc;

  /// No description provided for @ruleActionNotDesc.
  ///
  /// In en, this message translates to:
  /// **'Logical rule NOT'**
  String get ruleActionNotDesc;

  /// No description provided for @ruleActionSubRuleDesc.
  ///
  /// In en, this message translates to:
  /// **'Match into a sub-rule; mind the parentheses'**
  String get ruleActionSubRuleDesc;

  /// No description provided for @ruleActionMatchDesc.
  ///
  /// In en, this message translates to:
  /// **'Match all requests, no conditions needed'**
  String get ruleActionMatchDesc;

  /// No description provided for @contentNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Content cannot be empty'**
  String get contentNotEmpty;

  /// No description provided for @splitStrategyNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Split strategy cannot be empty'**
  String get splitStrategyNotEmpty;

  /// No description provided for @timeout.
  ///
  /// In en, this message translates to:
  /// **'Timeout'**
  String get timeout;

  /// No description provided for @delayFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get delayFailed;

  /// No description provided for @invalidSubRule.
  ///
  /// In en, this message translates to:
  /// **'{subRule} is an invalid SUB_RULE'**
  String invalidSubRule(Object subRule);

  /// No description provided for @invalidPolicy.
  ///
  /// In en, this message translates to:
  /// **'{target} is an invalid policy'**
  String invalidPolicy(Object target);

  /// No description provided for @invalidProxyProvider.
  ///
  /// In en, this message translates to:
  /// **'{providerName} is an invalid proxy provider'**
  String invalidProxyProvider(Object providerName);

  /// No description provided for @invalidRuleSet.
  ///
  /// In en, this message translates to:
  /// **'{ruleSet} is an invalid rule set'**
  String invalidRuleSet(Object ruleSet);

  /// No description provided for @invalidNetworkContent.
  ///
  /// In en, this message translates to:
  /// **'Only tcp or udp is supported'**
  String get invalidNetworkContent;

  /// No description provided for @invalidRangeContent.
  ///
  /// In en, this message translates to:
  /// **'Enter numbers or ranges such as 80 or 8000-9000, separated by /'**
  String get invalidRangeContent;

  /// No description provided for @invalidDscpContent.
  ///
  /// In en, this message translates to:
  /// **'A DSCP mark cannot exceed 63'**
  String get invalidDscpContent;

  /// No description provided for @invalidCidrContent.
  ///
  /// In en, this message translates to:
  /// **'Enter an IP range in CIDR form such as 192.168.0.0/16'**
  String get invalidCidrContent;

  /// No description provided for @invalidPortRangeContent.
  ///
  /// In en, this message translates to:
  /// **'Enter a port or a range such as 443 or 8000-9000'**
  String get invalidPortRangeContent;

  /// No description provided for @invalidHostContent.
  ///
  /// In en, this message translates to:
  /// **'Enter a domain or an IP address'**
  String get invalidHostContent;

  /// No description provided for @invalidListenContent.
  ///
  /// In en, this message translates to:
  /// **'Enter an address and port such as 0.0.0.0:1053'**
  String get invalidListenContent;

  /// No description provided for @invalidProxy.
  ///
  /// In en, this message translates to:
  /// **'{proxyName} is an invalid proxy'**
  String invalidProxy(Object proxyName);

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission required'**
  String get locationPermissionRequired;

  /// No description provided for @locationPermissionGuide.
  ///
  /// In en, this message translates to:
  /// **'1. Open System Settings > Privacy & Security\n2. Choose Location Services\n3. Find and check {appName} in the list\n\nWhen you are done, return to the app to continue. Thank you for your cooperation.'**
  String locationPermissionGuide(Object appName);

  /// No description provided for @prerequisites.
  ///
  /// In en, this message translates to:
  /// **'Prerequisites'**
  String get prerequisites;

  /// No description provided for @ignoreBatteryOptimization.
  ///
  /// In en, this message translates to:
  /// **'Ignore battery optimization'**
  String get ignoreBatteryOptimization;

  /// No description provided for @locationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location permission'**
  String get locationPermission;

  /// No description provided for @locationPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'The system requires location permission to read the Wi-Fi name. On Android choose \"Allow all the time\", otherwise the Wi-Fi name cannot be read while the app is in the background.'**
  String get locationPermissionDesc;

  /// No description provided for @excludeSsids.
  ///
  /// In en, this message translates to:
  /// **'Exclude SSIDs'**
  String get excludeSsids;

  /// No description provided for @excludeSsidsDesc.
  ///
  /// In en, this message translates to:
  /// **'When connected to Wi-Fi with an excluded SSID, the app\'s running state switches automatically.'**
  String get excludeSsidsDesc;

  /// No description provided for @ssidsEmpty.
  ///
  /// In en, this message translates to:
  /// **'SSIDs are empty'**
  String get ssidsEmpty;

  /// No description provided for @onDemand.
  ///
  /// In en, this message translates to:
  /// **'On demand'**
  String get onDemand;

  /// No description provided for @locationPermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied, so the current Wi-Fi name cannot be read. Please enable location permission manually in system settings.'**
  String get locationPermissionDeniedMessage;

  /// No description provided for @addSsid.
  ///
  /// In en, this message translates to:
  /// **'Add SSID'**
  String get addSsid;

  /// No description provided for @editSsid.
  ///
  /// In en, this message translates to:
  /// **'Edit SSID'**
  String get editSsid;

  /// No description provided for @authorized.
  ///
  /// In en, this message translates to:
  /// **'Authorized'**
  String get authorized;

  /// No description provided for @tapToAuthorize.
  ///
  /// In en, this message translates to:
  /// **'Tap to authorize'**
  String get tapToAuthorize;

  /// No description provided for @suspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended…'**
  String get suspended;

  /// No description provided for @resourceUpdateInterval.
  ///
  /// In en, this message translates to:
  /// **'Auto-update interval'**
  String get resourceUpdateInterval;

  /// No description provided for @resourceUpdateIntervalTip.
  ///
  /// In en, this message translates to:
  /// **'The auto-update interval must be greater than 0'**
  String get resourceUpdateIntervalTip;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @geoResources.
  ///
  /// In en, this message translates to:
  /// **'Geo'**
  String get geoResources;

  /// No description provided for @geoSkipped.
  ///
  /// In en, this message translates to:
  /// **'{name} is already up to date'**
  String geoSkipped(Object name);

  /// No description provided for @geoUpdated.
  ///
  /// In en, this message translates to:
  /// **'{name} updated'**
  String geoUpdated(Object name);

  /// No description provided for @secondsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second} other{{count} seconds}}'**
  String secondsCount(num count);

  /// No description provided for @proxiesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 proxy} other{{label} proxies}}'**
  String proxiesCount(num count, Object label);

  /// No description provided for @rulesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rule} other{{label} rules}}'**
  String rulesCount(num count, Object label);

  /// No description provided for @proxyGroupsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 proxy group} other{{label} proxy groups}}'**
  String proxyGroupsCount(num count, Object label);

  /// No description provided for @changelogBreaking.
  ///
  /// In en, this message translates to:
  /// **'Breaking changes'**
  String get changelogBreaking;

  /// No description provided for @changelogFeatures.
  ///
  /// In en, this message translates to:
  /// **'New features'**
  String get changelogFeatures;

  /// No description provided for @changelogFixes.
  ///
  /// In en, this message translates to:
  /// **'Bug fixes'**
  String get changelogFixes;

  /// No description provided for @changelogPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get changelogPerformance;

  /// No description provided for @changelogReverts.
  ///
  /// In en, this message translates to:
  /// **'Reverts'**
  String get changelogReverts;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @minimize.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get minimize;

  /// No description provided for @maximize.
  ///
  /// In en, this message translates to:
  /// **'Maximize'**
  String get maximize;

  /// No description provided for @unmaximize.
  ///
  /// In en, this message translates to:
  /// **'Restore down'**
  String get unmaximize;

  /// No description provided for @pinWindow.
  ///
  /// In en, this message translates to:
  /// **'Pin window'**
  String get pinWindow;

  /// No description provided for @unpinWindow.
  ///
  /// In en, this message translates to:
  /// **'Unpin window'**
  String get unpinWindow;

  /// No description provided for @exitFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Exit full screen'**
  String get exitFullScreen;

  /// No description provided for @torch.
  ///
  /// In en, this message translates to:
  /// **'Flashlight'**
  String get torch;

  /// No description provided for @pickFromAlbum.
  ///
  /// In en, this message translates to:
  /// **'Choose from album'**
  String get pickFromAlbum;

  /// No description provided for @closeConnections.
  ///
  /// In en, this message translates to:
  /// **'Close connections'**
  String get closeConnections;

  /// No description provided for @scrollToSelected.
  ///
  /// In en, this message translates to:
  /// **'Scroll to selected'**
  String get scrollToSelected;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get showLess;

  /// No description provided for @previousMatch.
  ///
  /// In en, this message translates to:
  /// **'Previous match'**
  String get previousMatch;

  /// No description provided for @nextMatch.
  ///
  /// In en, this message translates to:
  /// **'Next match'**
  String get nextMatch;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No matching results'**
  String get noSearchResults;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @authorize.
  ///
  /// In en, this message translates to:
  /// **'Authorize'**
  String get authorize;

  /// No description provided for @installedAppsPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'App list permission required'**
  String get installedAppsPermissionRequired;

  /// No description provided for @installedAppsPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'This system hides the installed app list until the permission is granted. Authorize it to configure the per-app proxy.'**
  String get installedAppsPermissionDesc;

  /// No description provided for @installedAppsPermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'The app list permission was denied, so installed apps cannot be listed. Please grant it manually in system settings.'**
  String get installedAppsPermissionDeniedMessage;

  /// No description provided for @outboundIp.
  ///
  /// In en, this message translates to:
  /// **'Outbound IP'**
  String get outboundIp;

  /// No description provided for @ipAddress.
  ///
  /// In en, this message translates to:
  /// **'IP address'**
  String get ipAddress;

  /// No description provided for @ipQualityLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get ipQualityLevel;

  /// No description provided for @ipQualityGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ipQualityGood;

  /// No description provided for @ipQualityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get ipQualityNormal;

  /// No description provided for @ipQualityRisky.
  ///
  /// In en, this message translates to:
  /// **'Risky'**
  String get ipQualityRisky;

  /// No description provided for @ipType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get ipType;

  /// No description provided for @ipTypeResidential.
  ///
  /// In en, this message translates to:
  /// **'Residential'**
  String get ipTypeResidential;

  /// No description provided for @ipTypeMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile network'**
  String get ipTypeMobile;

  /// No description provided for @ipTypeBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get ipTypeBusiness;

  /// No description provided for @ipTypeHosting.
  ///
  /// In en, this message translates to:
  /// **'Data center'**
  String get ipTypeHosting;

  /// No description provided for @ipFlags.
  ///
  /// In en, this message translates to:
  /// **'Flags'**
  String get ipFlags;

  /// No description provided for @ipFlagProxy.
  ///
  /// In en, this message translates to:
  /// **'Proxy'**
  String get ipFlagProxy;

  /// No description provided for @ipFlagVpn.
  ///
  /// In en, this message translates to:
  /// **'VPN'**
  String get ipFlagVpn;

  /// No description provided for @ipFlagTor.
  ///
  /// In en, this message translates to:
  /// **'Tor'**
  String get ipFlagTor;

  /// No description provided for @ipFlagAbuser.
  ///
  /// In en, this message translates to:
  /// **'Abuse history'**
  String get ipFlagAbuser;

  /// No description provided for @ipOrganization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get ipOrganization;

  /// No description provided for @ipAsn.
  ///
  /// In en, this message translates to:
  /// **'ASN'**
  String get ipAsn;

  /// No description provided for @ipQualitySource.
  ///
  /// In en, this message translates to:
  /// **'Answered by'**
  String get ipQualitySource;

  /// No description provided for @ipQualitySources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get ipQualitySources;

  /// No description provided for @ipQualityFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t determine the IP type'**
  String get ipQualityFailed;

  /// No description provided for @ipQualityRetry.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get ipQualityRetry;

  /// No description provided for @ipSourceNoType.
  ///
  /// In en, this message translates to:
  /// **'No type'**
  String get ipSourceNoType;

  /// No description provided for @ipSourceRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Rate limited'**
  String get ipSourceRateLimited;

  /// No description provided for @ipSourceIpMismatch.
  ///
  /// In en, this message translates to:
  /// **'Different outbound IP'**
  String get ipSourceIpMismatch;

  /// No description provided for @hideIp.
  ///
  /// In en, this message translates to:
  /// **'Hide IP'**
  String get hideIp;

  /// No description provided for @editorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Editor unavailable'**
  String get editorUnavailable;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @replaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace all'**
  String get replaceAll;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission required'**
  String get cameraPermissionRequired;

  /// No description provided for @cameraPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access in system settings to scan QR codes, or choose a QR code image from the album.'**
  String get cameraPermissionDesc;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable'**
  String get cameraUnavailable;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @invalidProfileQrcode.
  ///
  /// In en, this message translates to:
  /// **'This QR code doesn\'t contain a profile link'**
  String get invalidProfileQrcode;

  /// No description provided for @dnsQueries.
  ///
  /// In en, this message translates to:
  /// **'DNS queries'**
  String get dnsQueries;

  /// No description provided for @recordType.
  ///
  /// In en, this message translates to:
  /// **'Record type'**
  String get recordType;

  /// No description provided for @answers.
  ///
  /// In en, this message translates to:
  /// **'Answers'**
  String get answers;

  /// No description provided for @responseCode.
  ///
  /// In en, this message translates to:
  /// **'Response code'**
  String get responseCode;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @initiator.
  ///
  /// In en, this message translates to:
  /// **'Initiator'**
  String get initiator;

  /// No description provided for @cache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get cache;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @nonTextProviderFile.
  ///
  /// In en, this message translates to:
  /// **'This external resource is not a text file'**
  String get nonTextProviderFile;

  /// No description provided for @addCustomProxy.
  ///
  /// In en, this message translates to:
  /// **'Add proxy'**
  String get addCustomProxy;

  /// No description provided for @definitionNotMap.
  ///
  /// In en, this message translates to:
  /// **'The configuration must be a YAML mapping with a name and a type'**
  String get definitionNotMap;

  /// No description provided for @ruleTextInvalid.
  ///
  /// In en, this message translates to:
  /// **'The rule must start with a supported type, such as DOMAIN,example.com,DIRECT'**
  String get ruleTextInvalid;

  /// No description provided for @ruleListInvalid.
  ///
  /// In en, this message translates to:
  /// **'The rules must be a YAML list with one rule per item, such as - DOMAIN,example.com,DIRECT'**
  String get ruleListInvalid;

  /// No description provided for @shareLinksInvalid.
  ///
  /// In en, this message translates to:
  /// **'No proxy could be read from the links'**
  String get shareLinksInvalid;

  /// No description provided for @shareLinkUnreadable.
  ///
  /// In en, this message translates to:
  /// **'No proxy could be read from {link}'**
  String shareLinkUnreadable(Object link);

  /// No description provided for @proxiesProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'{name} and others ({count} proxies)'**
  String proxiesProfileLabel(Object name, Object count);

  /// No description provided for @singleShareLinkOnly.
  ///
  /// In en, this message translates to:
  /// **'Enter one link here; edit several from the quick edit of the list'**
  String get singleShareLinkOnly;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @emptyFallback.
  ///
  /// In en, this message translates to:
  /// **'Empty fallback'**
  String get emptyFallback;

  /// No description provided for @defaultSelected.
  ///
  /// In en, this message translates to:
  /// **'Default selection'**
  String get defaultSelected;

  /// No description provided for @hashByInUser.
  ///
  /// In en, this message translates to:
  /// **'Hash by inbound user'**
  String get hashByInUser;

  /// No description provided for @appProxiesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No local proxies'**
  String get appProxiesEmpty;

  /// No description provided for @nodes.
  ///
  /// In en, this message translates to:
  /// **'Nodes'**
  String get nodes;

  /// No description provided for @localProxies.
  ///
  /// In en, this message translates to:
  /// **'Local proxies'**
  String get localProxies;

  /// No description provided for @customIssueEmptyName.
  ///
  /// In en, this message translates to:
  /// **'The name is empty'**
  String get customIssueEmptyName;

  /// No description provided for @customIssueReservedName.
  ///
  /// In en, this message translates to:
  /// **'{name} is a built-in policy name and cannot be used here'**
  String customIssueReservedName(Object name);

  /// No description provided for @customIssueDuplicateName.
  ///
  /// In en, this message translates to:
  /// **'The name {name} is already used by another proxy or proxy group'**
  String customIssueDuplicateName(Object name);

  /// No description provided for @customIssueCoreRejected.
  ///
  /// In en, this message translates to:
  /// **'The core cannot parse this proxy: {message}'**
  String customIssueCoreRejected(Object message);

  /// No description provided for @customIssueMissingProxies.
  ///
  /// In en, this message translates to:
  /// **'These proxies or policies do not exist: {names}'**
  String customIssueMissingProxies(Object names);

  /// No description provided for @customIssueMissingProviders.
  ///
  /// In en, this message translates to:
  /// **'These proxy providers do not exist: {names}'**
  String customIssueMissingProviders(Object names);

  /// No description provided for @customIssueNoProxySource.
  ///
  /// In en, this message translates to:
  /// **'No proxies or proxy providers are selected, so the core rejects this group'**
  String get customIssueNoProxySource;

  /// No description provided for @customIssueGroupLoop.
  ///
  /// In en, this message translates to:
  /// **'Proxy groups reference each other in a loop: {path}'**
  String customIssueGroupLoop(Object path);

  /// No description provided for @customIssueInvalidEmptyFallback.
  ///
  /// In en, this message translates to:
  /// **'The empty fallback must be a proxy, but {name} does not exist or is a proxy group'**
  String customIssueInvalidEmptyFallback(Object name);

  /// No description provided for @customIssueInvalidFilter.
  ///
  /// In en, this message translates to:
  /// **'{name} is not a valid regex: {message}'**
  String customIssueInvalidFilter(Object name, Object message);

  /// No description provided for @customIssueMissingDialer.
  ///
  /// In en, this message translates to:
  /// **'The dialer proxy {name} does not exist'**
  String customIssueMissingDialer(Object name);

  /// No description provided for @customIssueDialerLoop.
  ///
  /// In en, this message translates to:
  /// **'{proxy} dials through {target}, which leads back to {proxy}, so the dial loops'**
  String customIssueDialerLoop(Object proxy, Object target);

  /// No description provided for @dialerProxyLoopStopped.
  ///
  /// In en, this message translates to:
  /// **'Dialing through {name} leads back to the proxy that uses it, so the connection was stopped'**
  String dialerProxyLoopStopped(Object name);

  /// No description provided for @customIssuesSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} items have problems, and applying this profile may fail'**
  String customIssuesSummary(Object count);

  /// No description provided for @providerInUse.
  ///
  /// In en, this message translates to:
  /// **'{label} is still used by {profiles}, which will not work properly once it is deleted. Are you sure you want to delete it?'**
  String providerInUse(Object label, Object profiles);

  /// No description provided for @proxyGroupInUse.
  ///
  /// In en, this message translates to:
  /// **'{label} is still named by rules, proxy groups, dialer proxies, DNS or NTP in this profile, which stop working once it is deleted. Are you sure you want to delete it?'**
  String proxyGroupInUse(Object label);

  /// No description provided for @proxiesRemovedTip.
  ///
  /// In en, this message translates to:
  /// **'These proxies will be deleted: {removed}. A line whose name changed counts as a new proxy, and custom profiles naming the deleted ones will flag them as missing. Apply anyway?'**
  String proxiesRemovedTip(Object removed);

  /// No description provided for @proxiesReplacedTip.
  ///
  /// In en, this message translates to:
  /// **'These proxies will be deleted: {removed}. These will be added: {added}. A line whose name changed counts as a new proxy, and custom profiles naming the deleted ones will flag them as missing. Apply anyway?'**
  String proxiesReplacedTip(Object removed, Object added);

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get fontSize;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @extraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra large'**
  String get extraLarge;

  /// No description provided for @switchProfile.
  ///
  /// In en, this message translates to:
  /// **'Switch profile'**
  String get switchProfile;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @label.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get label;

  /// No description provided for @regex.
  ///
  /// In en, this message translates to:
  /// **'Regex'**
  String get regex;

  /// No description provided for @matchCase.
  ///
  /// In en, this message translates to:
  /// **'Match case'**
  String get matchCase;

  /// No description provided for @iconSets.
  ///
  /// In en, this message translates to:
  /// **'Icon sets'**
  String get iconSets;

  /// No description provided for @invalidIconSet.
  ///
  /// In en, this message translates to:
  /// **'Not a valid icon set'**
  String get invalidIconSet;

  /// No description provided for @recommendedIcons.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get recommendedIcons;

  /// No description provided for @localImage.
  ///
  /// In en, this message translates to:
  /// **'Local image'**
  String get localImage;

  /// No description provided for @iconSetsEmptyTip.
  ///
  /// In en, this message translates to:
  /// **'No icon sets yet. Add them in Custom profile resources → Icon sets'**
  String get iconSetsEmptyTip;

  /// No description provided for @outbound.
  ///
  /// In en, this message translates to:
  /// **'Outbound'**
  String get outbound;

  /// No description provided for @strictRoute.
  ///
  /// In en, this message translates to:
  /// **'Strict route'**
  String get strictRoute;

  /// No description provided for @congestionController.
  ///
  /// In en, this message translates to:
  /// **'TCP congestion control'**
  String get congestionController;

  /// No description provided for @congestionControllerDesc.
  ///
  /// In en, this message translates to:
  /// **'TCP congestion control works only with the mips stack.'**
  String get congestionControllerDesc;

  /// No description provided for @routeExcludeAddress.
  ///
  /// In en, this message translates to:
  /// **'Route exclude addresses'**
  String get routeExcludeAddress;

  /// No description provided for @keepAliveIdle.
  ///
  /// In en, this message translates to:
  /// **'TCP keep-alive idle'**
  String get keepAliveIdle;

  /// No description provided for @disableKeepAlive.
  ///
  /// In en, this message translates to:
  /// **'Disable TCP keep-alive'**
  String get disableKeepAlive;

  /// No description provided for @routingMark.
  ///
  /// In en, this message translates to:
  /// **'Routing mark'**
  String get routingMark;

  /// No description provided for @strictRouteDesc.
  ///
  /// In en, this message translates to:
  /// **'Strict route keeps traffic such as DNS from bypassing TUN, and with IPv6 off it blocks this device\'s IPv6 connections.'**
  String get strictRouteDesc;

  /// No description provided for @initFailed.
  ///
  /// In en, this message translates to:
  /// **'Startup failed'**
  String get initFailed;

  /// No description provided for @initFailedTip.
  ///
  /// In en, this message translates to:
  /// **'FlClash ran into an error while starting and can\'t continue. Copy the details to report the problem. If it keeps happening, clearing the data usually lets the app start again.'**
  String get initFailedTip;

  /// No description provided for @errorDetails.
  ///
  /// In en, this message translates to:
  /// **'Error details'**
  String get errorDetails;

  /// No description provided for @stackTrace.
  ///
  /// In en, this message translates to:
  /// **'Stack trace'**
  String get stackTrace;

  /// No description provided for @clearDataAndExitTip.
  ///
  /// In en, this message translates to:
  /// **'This deletes all profiles, settings, and local data, then closes the app. Open it again to start fresh.'**
  String get clearDataAndExitTip;

  /// No description provided for @clearDataFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t clear the data: {detail}'**
  String clearDataFailed(Object detail);

  /// No description provided for @bypassPrivateRoute.
  ///
  /// In en, this message translates to:
  /// **'Bypass private addresses'**
  String get bypassPrivateRoute;

  /// No description provided for @disableIcmpForwarding.
  ///
  /// In en, this message translates to:
  /// **'Disable ICMP forwarding'**
  String get disableIcmpForwarding;

  /// No description provided for @disableIcmpForwardingDesc.
  ///
  /// In en, this message translates to:
  /// **'With ICMP forwarding disabled, TUN answers ping itself, so ping no longer shows the real latency.'**
  String get disableIcmpForwardingDesc;

  /// No description provided for @excludeInterface.
  ///
  /// In en, this message translates to:
  /// **'Excluded interfaces'**
  String get excludeInterface;

  /// No description provided for @includeInterface.
  ///
  /// In en, this message translates to:
  /// **'Included interfaces'**
  String get includeInterface;

  /// No description provided for @includeInterfaceDesc.
  ///
  /// In en, this message translates to:
  /// **'Only traffic arriving on included interfaces goes through TUN, and excluded interfaces no longer apply.'**
  String get includeInterfaceDesc;

  /// No description provided for @includeUid.
  ///
  /// In en, this message translates to:
  /// **'Included user IDs'**
  String get includeUid;

  /// No description provided for @excludeUid.
  ///
  /// In en, this message translates to:
  /// **'Excluded user IDs'**
  String get excludeUid;

  /// No description provided for @excludeSrcPort.
  ///
  /// In en, this message translates to:
  /// **'Excluded source ports'**
  String get excludeSrcPort;

  /// No description provided for @excludeDstPort.
  ///
  /// In en, this message translates to:
  /// **'Excluded destination ports'**
  String get excludeDstPort;

  /// No description provided for @udpTimeout.
  ///
  /// In en, this message translates to:
  /// **'UDP timeout'**
  String get udpTimeout;

  /// No description provided for @udpTimeoutDesc.
  ///
  /// In en, this message translates to:
  /// **'The UDP timeout is in seconds and works only with the gvisor, system and mixed stacks.'**
  String get udpTimeoutDesc;

  /// No description provided for @dnsHijackDesc.
  ///
  /// In en, this message translates to:
  /// **'Without this entry, TUN hijacks every DNS query to port 53 (any:53).'**
  String get dnsHijackDesc;

  /// No description provided for @tunOverrideDesc.
  ///
  /// In en, this message translates to:
  /// **'Entries added here replace the TUN settings of every profile; anything not added keeps the profile\'s own setting. Entries a custom profile adds itself take precedence.'**
  String get tunOverrideDesc;

  /// No description provided for @generalOverrideDesc.
  ///
  /// In en, this message translates to:
  /// **'Entries added here replace the setting of every profile; anything not added keeps the profile\'s own setting, or the core default when the profile has none.'**
  String get generalOverrideDesc;

  /// No description provided for @profileTunSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Applies to this profile only and takes precedence over the TUN override entries in the network settings.'**
  String get profileTunSettingsDesc;

  /// No description provided for @settingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 setting} other{{count} settings}}'**
  String settingsCount(num count);

  /// No description provided for @sectionsInEffect.
  ///
  /// In en, this message translates to:
  /// **'{count} in effect'**
  String sectionsInEffect(Object count);

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemsCount(num count);

  /// No description provided for @additionalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Name prefix'**
  String get additionalPrefix;

  /// No description provided for @additionalSuffix.
  ///
  /// In en, this message translates to:
  /// **'Name suffix'**
  String get additionalSuffix;

  /// No description provided for @skipCertVerify.
  ///
  /// In en, this message translates to:
  /// **'Skip certificate verification'**
  String get skipCertVerify;

  /// No description provided for @ipVersion.
  ///
  /// In en, this message translates to:
  /// **'IP version'**
  String get ipVersion;

  /// No description provided for @addFilters.
  ///
  /// In en, this message translates to:
  /// **'Add filters'**
  String get addFilters;

  /// No description provided for @failedItem.
  ///
  /// In en, this message translates to:
  /// **'{label}: {message}'**
  String failedItem(Object label, Object message);

  /// No description provided for @failedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items failed. Tap to view'**
  String failedCount(Object count);

  /// No description provided for @importConfigInvalid.
  ///
  /// In en, this message translates to:
  /// **'This file is not a config that can be imported'**
  String get importConfigInvalid;

  /// No description provided for @importConfigReplaceTip.
  ///
  /// In en, this message translates to:
  /// **'Importing replaces the proxy groups, rules and settings this profile has now'**
  String get importConfigReplaceTip;

  /// No description provided for @networkName.
  ///
  /// In en, this message translates to:
  /// **'Network name'**
  String get networkName;

  /// No description provided for @networkSecret.
  ///
  /// In en, this message translates to:
  /// **'Network secret'**
  String get networkSecret;

  /// No description provided for @peers.
  ///
  /// In en, this message translates to:
  /// **'Peers'**
  String get peers;

  /// No description provided for @virtualIpv4.
  ///
  /// In en, this message translates to:
  /// **'Virtual IPv4'**
  String get virtualIpv4;

  /// No description provided for @hostname.
  ///
  /// In en, this message translates to:
  /// **'Hostname'**
  String get hostname;

  /// No description provided for @exitNodes.
  ///
  /// In en, this message translates to:
  /// **'Exit nodes'**
  String get exitNodes;

  /// No description provided for @cipher.
  ///
  /// In en, this message translates to:
  /// **'Cipher'**
  String get cipher;

  /// No description provided for @protocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get protocol;

  /// No description provided for @protocolParam.
  ///
  /// In en, this message translates to:
  /// **'Protocol parameter'**
  String get protocolParam;

  /// No description provided for @obfs.
  ///
  /// In en, this message translates to:
  /// **'Obfuscation'**
  String get obfs;

  /// No description provided for @obfsParam.
  ///
  /// In en, this message translates to:
  /// **'Obfuscation parameter'**
  String get obfsParam;

  /// No description provided for @obfsPassword.
  ///
  /// In en, this message translates to:
  /// **'Obfuscation password'**
  String get obfsPassword;

  /// No description provided for @obfsMode.
  ///
  /// In en, this message translates to:
  /// **'Obfuscation mode'**
  String get obfsMode;

  /// No description provided for @obfsHost.
  ///
  /// In en, this message translates to:
  /// **'Obfuscation host'**
  String get obfsHost;

  /// No description provided for @plugin.
  ///
  /// In en, this message translates to:
  /// **'Plugin'**
  String get plugin;

  /// No description provided for @pluginMode.
  ///
  /// In en, this message translates to:
  /// **'Plugin mode'**
  String get pluginMode;

  /// No description provided for @pluginHost.
  ///
  /// In en, this message translates to:
  /// **'Plugin host'**
  String get pluginHost;

  /// No description provided for @pluginPath.
  ///
  /// In en, this message translates to:
  /// **'Plugin path'**
  String get pluginPath;

  /// No description provided for @pluginUsername.
  ///
  /// In en, this message translates to:
  /// **'Plugin username'**
  String get pluginUsername;

  /// No description provided for @pluginPassword.
  ///
  /// In en, this message translates to:
  /// **'Plugin password'**
  String get pluginPassword;

  /// No description provided for @pluginCipher.
  ///
  /// In en, this message translates to:
  /// **'Plugin cipher'**
  String get pluginCipher;

  /// No description provided for @privateKey.
  ///
  /// In en, this message translates to:
  /// **'Private key'**
  String get privateKey;

  /// No description provided for @publicKey.
  ///
  /// In en, this message translates to:
  /// **'Public key'**
  String get publicKey;

  /// No description provided for @privateKeyPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Private key passphrase'**
  String get privateKeyPassphrase;

  /// No description provided for @preSharedKey.
  ///
  /// In en, this message translates to:
  /// **'Pre-shared key'**
  String get preSharedKey;

  /// No description provided for @secretKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get secretKey;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @uploadBandwidth.
  ///
  /// In en, this message translates to:
  /// **'Upload bandwidth'**
  String get uploadBandwidth;

  /// No description provided for @downloadBandwidth.
  ///
  /// In en, this message translates to:
  /// **'Download bandwidth'**
  String get downloadBandwidth;

  /// No description provided for @protocolVersion.
  ///
  /// In en, this message translates to:
  /// **'Protocol version'**
  String get protocolVersion;

  /// No description provided for @portHopping.
  ///
  /// In en, this message translates to:
  /// **'Port hopping'**
  String get portHopping;

  /// No description provided for @hopInterval.
  ///
  /// In en, this message translates to:
  /// **'Hop interval'**
  String get hopInterval;

  /// No description provided for @congestionControl.
  ///
  /// In en, this message translates to:
  /// **'Congestion control'**
  String get congestionControl;

  /// No description provided for @udpRelayMode.
  ///
  /// In en, this message translates to:
  /// **'UDP relay mode'**
  String get udpRelayMode;

  /// No description provided for @allowedIps.
  ///
  /// In en, this message translates to:
  /// **'Allowed IPs'**
  String get allowedIps;

  /// No description provided for @remoteDnsResolve.
  ///
  /// In en, this message translates to:
  /// **'Remote DNS resolution'**
  String get remoteDnsResolve;

  /// No description provided for @clientFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Client fingerprint'**
  String get clientFingerprint;

  /// No description provided for @requestHeaders.
  ///
  /// In en, this message translates to:
  /// **'Request headers'**
  String get requestHeaders;

  /// No description provided for @transportHeaders.
  ///
  /// In en, this message translates to:
  /// **'{transport} Headers'**
  String transportHeaders(Object transport);

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @ageSecretKey.
  ///
  /// In en, this message translates to:
  /// **'Age secret key'**
  String get ageSecretKey;

  /// No description provided for @ageEncryptedProfile.
  ///
  /// In en, this message translates to:
  /// **'Encrypted profile'**
  String get ageEncryptedProfile;

  /// No description provided for @ageSecretKeyRequiredTip.
  ///
  /// In en, this message translates to:
  /// **'This profile is encrypted with age and needs an age secret key to decrypt'**
  String get ageSecretKeyRequiredTip;

  /// No description provided for @currentOutboundDesc.
  ///
  /// In en, this message translates to:
  /// **'Holds the start button and can\'t be removed'**
  String get currentOutboundDesc;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @root.
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get root;

  /// No description provided for @notRunning.
  ///
  /// In en, this message translates to:
  /// **'Not running'**
  String get notRunning;

  /// No description provided for @trafficPeak.
  ///
  /// In en, this message translates to:
  /// **'Peak {value}'**
  String trafficPeak(Object value);

  /// No description provided for @trafficTotal.
  ///
  /// In en, this message translates to:
  /// **'Total {value}'**
  String trafficTotal(Object value);

  /// No description provided for @ipQualityShort.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get ipQualityShort;

  /// No description provided for @ipTypeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown type'**
  String get ipTypeUnknown;

  /// No description provided for @tapIconToRetry.
  ///
  /// In en, this message translates to:
  /// **'Tap the icon to retry'**
  String get tapIconToRetry;

  /// No description provided for @networkTakeover.
  ///
  /// In en, this message translates to:
  /// **'Traffic takeover'**
  String get networkTakeover;

  /// No description provided for @portValue.
  ///
  /// In en, this message translates to:
  /// **'Port {port}'**
  String portValue(Object port);

  /// No description provided for @serviceAbnormalCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 issue} other{{count} issues}}'**
  String serviceAbnormalCount(num count);

  /// No description provided for @serviceAllAvailable.
  ///
  /// In en, this message translates to:
  /// **'All available'**
  String get serviceAllAvailable;

  /// No description provided for @serviceShownOnDashboard.
  ///
  /// In en, this message translates to:
  /// **'Shown on the dashboard'**
  String get serviceShownOnDashboard;

  /// No description provided for @groupTimeoutCount.
  ///
  /// In en, this message translates to:
  /// **'{count} timed out'**
  String groupTimeoutCount(Object count);

  /// No description provided for @groupCountUnit.
  ///
  /// In en, this message translates to:
  /// **'groups'**
  String get groupCountUnit;

  /// No description provided for @groupCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 group} other{{count} groups}}'**
  String groupCount(num count);

  /// No description provided for @proxyGroupsAfterStart.
  ///
  /// In en, this message translates to:
  /// **'Groups show up here once the core starts'**
  String get proxyGroupsAfterStart;

  /// No description provided for @usedShort.
  ///
  /// In en, this message translates to:
  /// **'used'**
  String get usedShort;

  /// No description provided for @profileUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String profileUpdatedAt(Object time);

  /// No description provided for @profileExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}, {days, plural, =1{1 day} other{{days} days}} left'**
  String profileExpiresIn(Object date, num days);

  /// No description provided for @profileDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day left} other{{days} days left}}'**
  String profileDaysLeft(num days);

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @outboundExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get outboundExit;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @traffic.
  ///
  /// In en, this message translates to:
  /// **'Traffic'**
  String get traffic;

  /// No description provided for @totalDownload.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get totalDownload;

  /// No description provided for @totalUpload.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get totalUpload;

  /// No description provided for @initiatorShort.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get initiatorShort;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @elapsed.
  ///
  /// In en, this message translates to:
  /// **'Took'**
  String get elapsed;

  /// No description provided for @connectionStats.
  ///
  /// In en, this message translates to:
  /// **'Connection stats'**
  String get connectionStats;

  /// No description provided for @connectionStatsDesc.
  ///
  /// In en, this message translates to:
  /// **'Live connections, recent requests and DNS queries'**
  String get connectionStatsDesc;

  /// No description provided for @memoryInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Memory the app and the core use'**
  String get memoryInfoDesc;

  /// No description provided for @editDashboard.
  ///
  /// In en, this message translates to:
  /// **'Edit dashboard'**
  String get editDashboard;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @dashboardAddableSection.
  ///
  /// In en, this message translates to:
  /// **'Available to add'**
  String get dashboardAddableSection;

  /// No description provided for @customImportDroppedSubRules.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 SUB-RULE rule was dropped, since custom profiles do not support sub-rules} other{{label} SUB-RULE rules were dropped, since custom profiles do not support sub-rules}}'**
  String customImportDroppedSubRules(num count, Object label);

  /// No description provided for @autoInclude.
  ///
  /// In en, this message translates to:
  /// **'Auto-include'**
  String get autoInclude;

  /// No description provided for @allReferencedProxies.
  ///
  /// In en, this message translates to:
  /// **'All referenced proxies'**
  String get allReferencedProxies;

  /// No description provided for @allReferencedProxyProviders.
  ///
  /// In en, this message translates to:
  /// **'All referenced proxy providers'**
  String get allReferencedProxyProviders;

  /// No description provided for @clearDnsCache.
  ///
  /// In en, this message translates to:
  /// **'Clear DNS cache'**
  String get clearDnsCache;

  /// No description provided for @dnsCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'DNS cache cleared'**
  String get dnsCacheCleared;

  /// No description provided for @clearDnsCacheFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear DNS cache'**
  String get clearDnsCacheFailed;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @preferred.
  ///
  /// In en, this message translates to:
  /// **'Preferred'**
  String get preferred;

  /// No description provided for @addToLocalProxies.
  ///
  /// In en, this message translates to:
  /// **'Add to local proxies'**
  String get addToLocalProxies;

  /// No description provided for @addedToLocalProxies.
  ///
  /// In en, this message translates to:
  /// **'Added {name} to local proxies'**
  String addedToLocalProxies(Object name);

  /// No description provided for @alreadyInLocalProxies.
  ///
  /// In en, this message translates to:
  /// **'{name} is already in local proxies'**
  String alreadyInLocalProxies(Object name);

  /// No description provided for @mitm.
  ///
  /// In en, this message translates to:
  /// **'MITM'**
  String get mitm;

  /// No description provided for @httpsDecryption.
  ///
  /// In en, this message translates to:
  /// **'HTTPS decryption'**
  String get httpsDecryption;

  /// No description provided for @httpCapture.
  ///
  /// In en, this message translates to:
  /// **'HTTP capture'**
  String get httpCapture;

  /// No description provided for @httpCaptureDesc.
  ///
  /// In en, this message translates to:
  /// **'Records requests to the hosts listed under Hostname, to view in connection details. Records stay in memory only.'**
  String get httpCaptureDesc;

  /// No description provided for @httpCaptureNoHosts.
  ///
  /// In en, this message translates to:
  /// **'No host is listed, so nothing is recorded. Add hosts under Hostname on the MITM page, or from the details of a connection.'**
  String get httpCaptureNoHosts;

  /// No description provided for @httpCaptureLimit.
  ///
  /// In en, this message translates to:
  /// **'Maximum records'**
  String get httpCaptureLimit;

  /// No description provided for @httpCaptureLimitDesc.
  ///
  /// In en, this message translates to:
  /// **'The oldest records go first once this many are kept or they fill {memory} of memory. Each body keeps its first {body}.'**
  String httpCaptureLimitDesc(Object memory, Object body);

  /// No description provided for @httpRequests.
  ///
  /// In en, this message translates to:
  /// **'HTTP requests'**
  String get httpRequests;

  /// No description provided for @httpRequestsMissing.
  ///
  /// In en, this message translates to:
  /// **'Requests made before capture was on, or since cleared, are not listed.'**
  String get httpRequestsMissing;

  /// No description provided for @httpRequestCleared.
  ///
  /// In en, this message translates to:
  /// **'This request is no longer kept'**
  String get httpRequestCleared;

  /// No description provided for @httpCaptureOff.
  ///
  /// In en, this message translates to:
  /// **'Capture is off'**
  String get httpCaptureOff;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @originalUrl.
  ///
  /// In en, this message translates to:
  /// **'Original URL'**
  String get originalUrl;

  /// No description provided for @timeToFirstByte.
  ///
  /// In en, this message translates to:
  /// **'Time to first byte'**
  String get timeToFirstByte;

  /// No description provided for @requestBody.
  ///
  /// In en, this message translates to:
  /// **'Request body'**
  String get requestBody;

  /// No description provided for @response.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get response;

  /// No description provided for @responseBody.
  ///
  /// In en, this message translates to:
  /// **'Response body'**
  String get responseBody;

  /// No description provided for @responseHeaders.
  ///
  /// In en, this message translates to:
  /// **'Response headers'**
  String get responseHeaders;

  /// No description provided for @matchedRules.
  ///
  /// In en, this message translates to:
  /// **'Matched rules'**
  String get matchedRules;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @copyAsBase64.
  ///
  /// In en, this message translates to:
  /// **'Copy as Base64'**
  String get copyAsBase64;

  /// No description provided for @copyAsCurl.
  ///
  /// In en, this message translates to:
  /// **'Copy as cURL'**
  String get copyAsCurl;

  /// No description provided for @closeConnection.
  ///
  /// In en, this message translates to:
  /// **'Close connection'**
  String get closeConnection;

  /// No description provided for @copyHost.
  ///
  /// In en, this message translates to:
  /// **'Copy host'**
  String get copyHost;

  /// No description provided for @copyDestination.
  ///
  /// In en, this message translates to:
  /// **'Copy destination'**
  String get copyDestination;

  /// No description provided for @copyRequest.
  ///
  /// In en, this message translates to:
  /// **'Copy request'**
  String get copyRequest;

  /// No description provided for @copyResponse.
  ///
  /// In en, this message translates to:
  /// **'Copy response'**
  String get copyResponse;

  /// No description provided for @copyResponseBody.
  ///
  /// In en, this message translates to:
  /// **'Copy response body'**
  String get copyResponseBody;

  /// No description provided for @httpBodyProtobufGuess.
  ///
  /// In en, this message translates to:
  /// **'Read as Protobuf without its schema: field numbers only, and the types are guesses.'**
  String get httpBodyProtobufGuess;

  /// No description provided for @exportHar.
  ///
  /// In en, this message translates to:
  /// **'Export HAR'**
  String get exportHar;

  /// No description provided for @mitmAddRejectRule.
  ///
  /// In en, this message translates to:
  /// **'Add a reject rule'**
  String get mitmAddRejectRule;

  /// No description provided for @mitmAddMapLocalRule.
  ///
  /// In en, this message translates to:
  /// **'Add a map local rule'**
  String get mitmAddMapLocalRule;

  /// No description provided for @httpExportPrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Contains private data'**
  String get httpExportPrivateTitle;

  /// No description provided for @httpExportPrivate.
  ///
  /// In en, this message translates to:
  /// **'A request can carry cookies, tokens, passwords and form contents. Check what you share, and with whom.'**
  String get httpExportPrivate;

  /// No description provided for @mitmRuleCopiedForStash.
  ///
  /// In en, this message translates to:
  /// **'This module is a Stash override, so the rule was copied for you to add by hand.'**
  String get mitmRuleCopiedForStash;

  /// No description provided for @binaryData.
  ///
  /// In en, this message translates to:
  /// **'Binary data'**
  String get binaryData;

  /// No description provided for @httpBodyNotKept.
  ///
  /// In en, this message translates to:
  /// **'Not recorded while memory was short.'**
  String get httpBodyNotKept;

  /// No description provided for @httpBodyTruncated.
  ///
  /// In en, this message translates to:
  /// **'Only the start of this body was recorded.'**
  String get httpBodyTruncated;

  /// No description provided for @httpBodyUndecoded.
  ///
  /// In en, this message translates to:
  /// **'Could not decode {encoding}, so this is the data as it was sent.'**
  String httpBodyUndecoded(Object encoding);

  /// No description provided for @mitmEnableTip.
  ///
  /// In en, this message translates to:
  /// **'FlClash will be able to read everything sent to the decrypted hosts, cookies and passwords included. Turn this on only for hosts you mean to rewrite.'**
  String get mitmEnableTip;

  /// No description provided for @generateCertificate.
  ///
  /// In en, this message translates to:
  /// **'Generate certificate'**
  String get generateCertificate;

  /// No description provided for @regenerateCertificate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate certificate'**
  String get regenerateCertificate;

  /// No description provided for @regenerateCertificateTip.
  ///
  /// In en, this message translates to:
  /// **'The new certificate replaces the current one, which FlClash takes out of this device\'s trusted roots where it can. Every other device that trusts the current one has to install the new one.'**
  String get regenerateCertificateTip;

  /// No description provided for @exportCertificate.
  ///
  /// In en, this message translates to:
  /// **'Export certificate'**
  String get exportCertificate;

  /// No description provided for @installCertificate.
  ///
  /// In en, this message translates to:
  /// **'Install to system'**
  String get installCertificate;

  /// No description provided for @installCertificateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Certificate installed'**
  String get installCertificateSuccess;

  /// No description provided for @validUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String validUntil(Object date);

  /// No description provided for @mitmCertificateExportTip.
  ///
  /// In en, this message translates to:
  /// **'Export it and trust it on the devices you want to decrypt.'**
  String get mitmCertificateExportTip;

  /// No description provided for @mitmTrustReady.
  ///
  /// In en, this message translates to:
  /// **'Trusted'**
  String get mitmTrustReady;

  /// No description provided for @mitmTrustUntrusted.
  ///
  /// In en, this message translates to:
  /// **'Not fully trusted'**
  String get mitmTrustUntrusted;

  /// No description provided for @mitmTrustNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not installed'**
  String get mitmTrustNotInstalled;

  /// No description provided for @mitmTrustChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get mitmTrustChecking;

  /// No description provided for @mitmCertificateAndroidReadyTip.
  ///
  /// In en, this message translates to:
  /// **'Only apps that trust user certificates, mostly browsers, are decrypted.'**
  String get mitmCertificateAndroidReadyTip;

  /// No description provided for @mitmAndroidRootDesc.
  ///
  /// In en, this message translates to:
  /// **'Without root, only apps that trust user certificates, mostly browsers, can be decrypted. With root, every app can.'**
  String get mitmAndroidRootDesc;

  /// No description provided for @mitmCertificateLinuxTip.
  ///
  /// In en, this message translates to:
  /// **'Flatpak browsers need the exported certificate imported by hand.'**
  String get mitmCertificateLinuxTip;

  /// No description provided for @mitmCertutilMissing.
  ///
  /// In en, this message translates to:
  /// **'Chrome and Firefox keep their own certificate stores, which need certutil: {command}'**
  String mitmCertutilMissing(Object command);

  /// No description provided for @mitmMissingStores.
  ///
  /// In en, this message translates to:
  /// **'Not yet in: {stores}'**
  String mitmMissingStores(Object stores);

  /// No description provided for @httpRequestsReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the requests'**
  String get httpRequestsReadFailed;

  /// No description provided for @requestBodyReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the request body'**
  String get requestBodyReadFailed;

  /// No description provided for @responseBodyReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the response body'**
  String get responseBodyReadFailed;

  /// No description provided for @mitmGrpcOverLimit.
  ///
  /// In en, this message translates to:
  /// **'Inflates past {size} MB; shown compressed'**
  String mitmGrpcOverLimit(Object size);

  /// No description provided for @mitmUntrustedStores.
  ///
  /// In en, this message translates to:
  /// **'Installed but not trusted in: {stores}'**
  String mitmUntrustedStores(Object stores);

  /// No description provided for @mitmSystemStoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Adding the certificate to the system\'s trusted roots failed'**
  String get mitmSystemStoreFailed;

  /// No description provided for @mitmRootUntilReboot.
  ///
  /// In en, this message translates to:
  /// **'No Magisk, KernelSU or APatch was found to keep the certificate. Install it again after the device restarts.'**
  String get mitmRootUntilReboot;

  /// No description provided for @mitmRootPendingReboot.
  ///
  /// In en, this message translates to:
  /// **'The certificate takes effect after the device restarts.'**
  String get mitmRootPendingReboot;

  /// No description provided for @mitmInstallSystemCaTip.
  ///
  /// In en, this message translates to:
  /// **'Root was found, so the certificate goes into the system\'s trusted certificates as a FlClash MITM CA module for Magisk, KernelSU or APatch. Every app on this device will then trust it, and anyone holding its private key could decrypt this device\'s HTTPS traffic. To undo it, regenerate the certificate or remove the module in the root manager and restart. If root is denied, it is installed as a user certificate instead.'**
  String get mitmInstallSystemCaTip;

  /// No description provided for @mitmInstallUserCaTip.
  ///
  /// In en, this message translates to:
  /// **'No root was found, so the certificate can only be installed as a user certificate. Only apps that trust user certificates, mostly browsers, are decrypted; other apps fail on the hosts you list, so leave those hosts out. On Android 11 and later you finish the install yourself in system settings.'**
  String get mitmInstallUserCaTip;

  /// No description provided for @mitmCertificateSavedTip.
  ///
  /// In en, this message translates to:
  /// **'Saved {fileName} to Downloads. Install it in Settings under Security › Encryption & credentials › Install a certificate › CA certificate.'**
  String mitmCertificateSavedTip(Object fileName);

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @mitmRemoveOldCertificateTip.
  ///
  /// In en, this message translates to:
  /// **'Remove the old certificate, {name}, in Settings under Security › Encryption & credentials › Trusted credentials › User, then install the new one.'**
  String mitmRemoveOldCertificateTip(Object name);

  /// No description provided for @mitmOldCertificateLeftTip.
  ///
  /// In en, this message translates to:
  /// **'The old certificate, {name}, could not be removed. Remove it from the trusted roots yourself.'**
  String mitmOldCertificateLeftTip(Object name);

  /// No description provided for @mitmOldSystemCertificateLeftTip.
  ///
  /// In en, this message translates to:
  /// **'The old certificate, {name}, is still among the system\'s trusted CAs. Allow FlClash root access in your root manager and regenerate, or remove the FlClash MITM CA module there and restart.'**
  String mitmOldSystemCertificateLeftTip(Object name);

  /// No description provided for @removeCertificate.
  ///
  /// In en, this message translates to:
  /// **'Remove certificate'**
  String get removeCertificate;

  /// No description provided for @removeCertificateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Certificate removed'**
  String get removeCertificateSuccess;

  /// No description provided for @mitmSystemStoreRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Removing the certificate from the system\'s trusted roots failed'**
  String get mitmSystemStoreRemoveFailed;

  /// No description provided for @mitmRemoveInSettings.
  ///
  /// In en, this message translates to:
  /// **'Remove in Settings'**
  String get mitmRemoveInSettings;

  /// No description provided for @mitmRemoveUserCertificateTip.
  ///
  /// In en, this message translates to:
  /// **'Android doesn\'t let apps remove user certificates. Remove {name} in Settings under Security › Encryption & credentials › Trusted credentials › User.'**
  String mitmRemoveUserCertificateTip(Object name);

  /// No description provided for @mitmCannotRemove.
  ///
  /// In en, this message translates to:
  /// **'Can\'t remove'**
  String get mitmCannotRemove;

  /// No description provided for @mitmRemoveSystemCertificateTip.
  ///
  /// In en, this message translates to:
  /// **'The FlClash MITM CA root module added the certificate to the system. Allow FlClash root access in your root manager and try again, or remove the module there and restart.'**
  String get mitmRemoveSystemCertificateTip;

  /// No description provided for @mitmDecryptHost.
  ///
  /// In en, this message translates to:
  /// **'Decrypt this host'**
  String get mitmDecryptHost;

  /// No description provided for @mitmDecryptHostTip.
  ///
  /// In en, this message translates to:
  /// **'Add {host} to the hostname list? FlClash can then read what is sent to it, cookies and passwords included.'**
  String mitmDecryptHostTip(Object host);

  /// No description provided for @mitmClientRefusedCertificate.
  ///
  /// In en, this message translates to:
  /// **'The client refused the certificate. Install the CA, or exclude this host if the app pins its certificate.'**
  String get mitmClientRefusedCertificate;

  /// No description provided for @mitmExcludeHost.
  ///
  /// In en, this message translates to:
  /// **'Exclude from decryption'**
  String get mitmExcludeHost;

  /// No description provided for @mitmExcludeHostTip.
  ///
  /// In en, this message translates to:
  /// **'Add -{host} to the top of the hostname list? The host is then never decrypted.'**
  String mitmExcludeHostTip(Object host);

  /// No description provided for @urlRewrite.
  ///
  /// In en, this message translates to:
  /// **'URL rewrite'**
  String get urlRewrite;

  /// No description provided for @headerRewrite.
  ///
  /// In en, this message translates to:
  /// **'Header rewrite'**
  String get headerRewrite;

  /// No description provided for @bodyRewrite.
  ///
  /// In en, this message translates to:
  /// **'Body rewrite'**
  String get bodyRewrite;

  /// No description provided for @mapLocal.
  ///
  /// In en, this message translates to:
  /// **'Map local'**
  String get mapLocal;

  /// No description provided for @requestBodyMock.
  ///
  /// In en, this message translates to:
  /// **'Request body mock'**
  String get requestBodyMock;

  /// No description provided for @clientSourceAddress.
  ///
  /// In en, this message translates to:
  /// **'Client addresses'**
  String get clientSourceAddress;

  /// No description provided for @skipVerifyHostname.
  ///
  /// In en, this message translates to:
  /// **'Hosts without certificate checks'**
  String get skipVerifyHostname;

  /// No description provided for @mitmModules.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get mitmModules;

  /// No description provided for @mitmModule.
  ///
  /// In en, this message translates to:
  /// **'Module'**
  String get mitmModule;

  /// No description provided for @mitmModuleInvalid.
  ///
  /// In en, this message translates to:
  /// **'This is not a Surge module, a Loon plugin, a Quantumult X snippet or a Stash override'**
  String get mitmModuleInvalid;

  /// No description provided for @arguments.
  ///
  /// In en, this message translates to:
  /// **'Arguments'**
  String get arguments;

  /// No description provided for @mitmRoutingRules.
  ///
  /// In en, this message translates to:
  /// **'Routing rules'**
  String get mitmRoutingRules;

  /// No description provided for @mitmIgnoredLines.
  ///
  /// In en, this message translates to:
  /// **'Ignored lines'**
  String get mitmIgnoredLines;

  /// No description provided for @mitmModuleRulesDesc.
  ///
  /// In en, this message translates to:
  /// **'Routing rules go in front of the profile’s own.'**
  String get mitmModuleRulesDesc;

  /// No description provided for @mitmRequestRulesDesc.
  ///
  /// In en, this message translates to:
  /// **'The module’s URL-REGEX and USER-AGENT rules became URL rewrites, judged request by request: on every plain HTTP request, and on HTTPS only for hosts in the MITM hostname list.'**
  String get mitmRequestRulesDesc;

  /// No description provided for @mitmModuleSystemTip.
  ///
  /// In en, this message translates to:
  /// **'Written for {system}; some lines may not match apps on this device.'**
  String mitmModuleSystemTip(Object system);

  /// No description provided for @mitmModuleRequirementTip.
  ///
  /// In en, this message translates to:
  /// **'The module requires {requirement}, which this device does not meet; it may not work as intended.'**
  String mitmModuleRequirementTip(Object requirement);

  /// No description provided for @mitmExitModules.
  ///
  /// In en, this message translates to:
  /// **'From modules: {modules}'**
  String mitmExitModules(Object modules);

  /// No description provided for @mitmModuleRiskTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on this module?'**
  String get mitmModuleRiskTitle;

  /// No description provided for @mitmNetworkRisk.
  ///
  /// In en, this message translates to:
  /// **'When the config is generated, it changes the network settings below, ahead of what you set for the same ones in FlClash. Turning the module off or deleting it undoes this.'**
  String get mitmNetworkRisk;

  /// No description provided for @mitmSkipVerifyRisk.
  ///
  /// In en, this message translates to:
  /// **'Turning it on stops checking the certificates of these hosts\' servers, so a server posing as one of them goes unnoticed: {hosts}'**
  String mitmSkipVerifyRisk(Object hosts);

  /// No description provided for @mitmClientSourceRisk.
  ///
  /// In en, this message translates to:
  /// **'It decrypts only for these clients: {addresses}. With TUN on, this device\'s apps reach FlClash from the TUN\'s address, so they may be left out.'**
  String mitmClientSourceRisk(Object addresses);

  /// No description provided for @mitmClientSourceTunTip.
  ///
  /// In en, this message translates to:
  /// **'With TUN on, this device\'s apps come from the TUN\'s address; a list that leaves it out leaves their traffic undecrypted.'**
  String get mitmClientSourceTunTip;

  /// No description provided for @mitmNetworkChanges.
  ///
  /// In en, this message translates to:
  /// **'Network settings'**
  String get mitmNetworkChanges;

  /// No description provided for @mitmChangeReplace.
  ///
  /// In en, this message translates to:
  /// **'Replaced with {values}'**
  String mitmChangeReplace(Object values);

  /// No description provided for @mitmChangeInsert.
  ///
  /// In en, this message translates to:
  /// **'Adds {values} first'**
  String mitmChangeInsert(Object values);

  /// No description provided for @mitmChangeAppend.
  ///
  /// In en, this message translates to:
  /// **'Adds {values}'**
  String mitmChangeAppend(Object values);

  /// No description provided for @mitmChangeOverridesYours.
  ///
  /// In en, this message translates to:
  /// **'Goes over your setting'**
  String get mitmChangeOverridesYours;

  /// No description provided for @mitmChangeReplacedBy.
  ///
  /// In en, this message translates to:
  /// **'Overridden by the module {module}'**
  String mitmChangeReplacedBy(Object module);

  /// No description provided for @mitmSkipSection.
  ///
  /// In en, this message translates to:
  /// **'The [{section}] section is not supported'**
  String mitmSkipSection(Object section);

  /// No description provided for @mitmSkipSetting.
  ///
  /// In en, this message translates to:
  /// **'This setting is not supported'**
  String get mitmSkipSetting;

  /// No description provided for @mitmSkipScriptType.
  ///
  /// In en, this message translates to:
  /// **'This script type is not supported'**
  String get mitmSkipScriptType;

  /// No description provided for @mitmSkipRule.
  ///
  /// In en, this message translates to:
  /// **'This rule type is not supported'**
  String get mitmSkipRule;

  /// No description provided for @mitmSkipHttpRulePolicy.
  ///
  /// In en, this message translates to:
  /// **'URL-REGEX and USER-AGENT rules only take a REJECT policy'**
  String get mitmSkipHttpRulePolicy;

  /// No description provided for @mitmSkipFinalRule.
  ///
  /// In en, this message translates to:
  /// **'Module rules go first, so a final rule would hide every rule after it'**
  String get mitmSkipFinalRule;

  /// No description provided for @mitmSkipDeviceRule.
  ///
  /// In en, this message translates to:
  /// **'This rule needs device or network details FlClash cannot read'**
  String get mitmSkipDeviceRule;

  /// No description provided for @mitmSkipRequirement.
  ///
  /// In en, this message translates to:
  /// **'This line’s requirement is not met on this device'**
  String get mitmSkipRequirement;

  /// No description provided for @mitmSkipManagedCa.
  ///
  /// In en, this message translates to:
  /// **'FlClash manages the CA certificate; a module cannot change it'**
  String get mitmSkipManagedCa;

  /// No description provided for @mitmSkipProxies.
  ///
  /// In en, this message translates to:
  /// **'A module cannot change proxies or proxy groups'**
  String get mitmSkipProxies;

  /// No description provided for @mitmSkipAppOnly.
  ///
  /// In en, this message translates to:
  /// **'A feature of the app this was written for that FlClash does not have'**
  String get mitmSkipAppOnly;

  /// No description provided for @mitmSkipReflect.
  ///
  /// In en, this message translates to:
  /// **'FlClash cannot send packets back to their sender'**
  String get mitmSkipReflect;

  /// No description provided for @mitmSkipConditional.
  ///
  /// In en, this message translates to:
  /// **'Conditional rewrites are not supported'**
  String get mitmSkipConditional;

  /// No description provided for @mitmSkipSkipVerifyAll.
  ///
  /// In en, this message translates to:
  /// **'Certificate checks are not turned off for every host'**
  String get mitmSkipSkipVerifyAll;

  /// No description provided for @mitmSkipRelativeData.
  ///
  /// In en, this message translates to:
  /// **'The file this line names is not attached; use a URL or attach it'**
  String get mitmSkipRelativeData;

  /// No description provided for @mitmSkipNotDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Its file has not been downloaded'**
  String get mitmSkipNotDownloaded;

  /// No description provided for @mitmSkipUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This line cannot be read'**
  String get mitmSkipUnreadable;

  /// No description provided for @mitmAddLocalFile.
  ///
  /// In en, this message translates to:
  /// **'Add a local file'**
  String get mitmAddLocalFile;

  /// No description provided for @mitmNewModule.
  ///
  /// In en, this message translates to:
  /// **'New module'**
  String get mitmNewModule;

  /// No description provided for @mitmAttachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get mitmAttachments;

  /// No description provided for @mitmAttachmentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Lines refer to attachments by file name, as in script-path=a.js.'**
  String get mitmAttachmentsDesc;

  /// No description provided for @mitmFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The file is larger than {size} MB'**
  String mitmFileTooLarge(Object size);

  /// No description provided for @mitmSkipDisabled.
  ///
  /// In en, this message translates to:
  /// **'Turned off by an argument'**
  String get mitmSkipDisabled;

  /// No description provided for @mitmSkipEvent.
  ///
  /// In en, this message translates to:
  /// **'This event is not supported'**
  String get mitmSkipEvent;

  /// No description provided for @mitmRunScript.
  ///
  /// In en, this message translates to:
  /// **'Run now'**
  String get mitmRunScript;

  /// No description provided for @mitmScriptCron.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get mitmScriptCron;

  /// No description provided for @mitmScriptEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get mitmScriptEvent;

  /// No description provided for @mitmScriptGeneric.
  ///
  /// In en, this message translates to:
  /// **'Generic'**
  String get mitmScriptGeneric;

  /// No description provided for @mitmExcluded.
  ///
  /// In en, this message translates to:
  /// **'Excluded'**
  String get mitmExcluded;

  /// No description provided for @mitmScriptNoOutput.
  ///
  /// In en, this message translates to:
  /// **'The script finished without output'**
  String get mitmScriptNoOutput;

  /// No description provided for @mitmScriptRiskTitle.
  ///
  /// In en, this message translates to:
  /// **'Run this module\'s scripts?'**
  String get mitmScriptRiskTitle;

  /// No description provided for @mitmModulesTurnedOff.
  ///
  /// In en, this message translates to:
  /// **'Modules turned off'**
  String get mitmModulesTurnedOff;

  /// No description provided for @mitmModuleTurnedOffDesc.
  ///
  /// In en, this message translates to:
  /// **'An update to {name} brought scripts or network changes you have not agreed to'**
  String mitmModuleTurnedOffDesc(Object name);

  /// No description provided for @mitmModulesTurnedOffDesc.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} modules got updates with scripts or network changes you have not agreed to}}'**
  String mitmModulesTurnedOffDesc(num count);

  /// No description provided for @mitmScriptRisk.
  ///
  /// In en, this message translates to:
  /// **'Its scripts read and change the traffic of the hosts they match, cookies and tokens included, and can send requests of their own. Turn it on only if you trust where it comes from. Once on, its updates take effect without asking again.'**
  String get mitmScriptRisk;

  /// No description provided for @mitmModuleUnreadableRisk.
  ///
  /// In en, this message translates to:
  /// **'The module file could not be read, so what it changes is unknown. Turn it on only if you trust where it comes from.'**
  String get mitmModuleUnreadableRisk;

  /// No description provided for @skipServerCertVerify.
  ///
  /// In en, this message translates to:
  /// **'Skip server certificate verification'**
  String get skipServerCertVerify;

  /// No description provided for @blockQuic.
  ///
  /// In en, this message translates to:
  /// **'Block QUIC'**
  String get blockQuic;

  /// No description provided for @http2.
  ///
  /// In en, this message translates to:
  /// **'HTTP/2'**
  String get http2;

  /// No description provided for @decryptUntrusted.
  ///
  /// In en, this message translates to:
  /// **'Decrypt without local trust'**
  String get decryptUntrusted;

  /// No description provided for @invalidOfCount.
  ///
  /// In en, this message translates to:
  /// **'{invalid} of {total} invalid'**
  String invalidOfCount(Object invalid, Object total);

  /// No description provided for @batchLineInputTip.
  ///
  /// In en, this message translates to:
  /// **'One item per line'**
  String get batchLineInputTip;

  /// No description provided for @downloadingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Downloading update'**
  String get downloadingUpdate;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// No description provided for @updateDownloadTest.
  ///
  /// In en, this message translates to:
  /// **'Update download test'**
  String get updateDownloadTest;

  /// No description provided for @liveStatusTest.
  ///
  /// In en, this message translates to:
  /// **'Live status cards test'**
  String get liveStatusTest;

  /// No description provided for @updateDownloadStarted.
  ///
  /// In en, this message translates to:
  /// **'Downloading the update. Follow its progress on the dashboard.'**
  String get updateDownloadStarted;

  /// No description provided for @updateReady.
  ///
  /// In en, this message translates to:
  /// **'Update ready'**
  String get updateReady;

  /// No description provided for @updateReadyTip.
  ///
  /// In en, this message translates to:
  /// **'The update has downloaded. Tap to install it.'**
  String get updateReadyTip;

  /// No description provided for @stopUpdateDownloadTip.
  ///
  /// In en, this message translates to:
  /// **'Stop downloading the update?'**
  String get stopUpdateDownloadTip;

  /// No description provided for @forceRestartCoreAsk.
  ///
  /// In en, this message translates to:
  /// **'Force restart the core?'**
  String get forceRestartCoreAsk;

  /// No description provided for @forceRestartCoreAskDesc.
  ///
  /// In en, this message translates to:
  /// **'Connections in progress will drop'**
  String get forceRestartCoreAskDesc;

  /// No description provided for @stopUpdateDownloadDesc.
  ///
  /// In en, this message translates to:
  /// **'What has downloaded is deleted'**
  String get stopUpdateDownloadDesc;

  /// No description provided for @stopDownload.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopDownload;

  /// No description provided for @updateInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'The update could not be installed. You can download it from the release page instead.'**
  String get updateInstallFailed;

  /// No description provided for @updateNotVerified.
  ///
  /// In en, this message translates to:
  /// **'The downloaded update could not be verified.'**
  String get updateNotVerified;

  /// No description provided for @updateRestartTip.
  ///
  /// In en, this message translates to:
  /// **'FlClash closes to install the update and opens again when it is done.'**
  String get updateRestartTip;

  /// No description provided for @updateDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'The update could not be downloaded.'**
  String get updateDownloadFailed;

  /// No description provided for @defaultNameserverDesc.
  ///
  /// In en, this message translates to:
  /// **'Resolves the hostnames of the other DNS servers. Use IP addresses only.'**
  String get defaultNameserverDesc;

  /// No description provided for @nameserverDesc.
  ///
  /// In en, this message translates to:
  /// **'The default DNS servers, such as 223.5.5.5, tls://1.1.1.1 or https://dns.google/dns-query.'**
  String get nameserverDesc;

  /// No description provided for @fallbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Used instead of Nameserver when the fallback filter treats its answer as polluted.'**
  String get fallbackDesc;

  /// No description provided for @proxyServerNameserverDesc.
  ///
  /// In en, this message translates to:
  /// **'Resolves proxy server hostnames only.'**
  String get proxyServerNameserverDesc;

  /// No description provided for @proxyServerNameserverPolicyDesc.
  ///
  /// In en, this message translates to:
  /// **'Matching proxy server hostnames use the DNS server given here instead of Proxy Server Nameserver.'**
  String get proxyServerNameserverPolicyDesc;

  /// No description provided for @directNameserverDesc.
  ///
  /// In en, this message translates to:
  /// **'Resolves domains for connections that go direct.'**
  String get directNameserverDesc;

  /// No description provided for @nameserverPolicyDesc.
  ///
  /// In en, this message translates to:
  /// **'Matching domains use the DNS server given here instead of Nameserver and Fallback.'**
  String get nameserverPolicyDesc;

  /// No description provided for @fakeipFilterDesc.
  ///
  /// In en, this message translates to:
  /// **'These domains get real IPs instead of Fake-IPs. In whitelist mode, only they get Fake-IPs.'**
  String get fakeipFilterDesc;

  /// No description provided for @fallbackFilterGeositeDesc.
  ///
  /// In en, this message translates to:
  /// **'Domains in these GeoSite categories are resolved by Fallback directly.'**
  String get fallbackFilterGeositeDesc;

  /// No description provided for @fallbackFilterIpcidrDesc.
  ///
  /// In en, this message translates to:
  /// **'When Nameserver returns an IP in these ranges, the Fallback answer is used.'**
  String get fallbackFilterIpcidrDesc;

  /// No description provided for @fallbackFilterDomainDesc.
  ///
  /// In en, this message translates to:
  /// **'These domains are resolved by Fallback directly.'**
  String get fallbackFilterDomainDesc;

  /// No description provided for @liveStatus.
  ///
  /// In en, this message translates to:
  /// **'Live status'**
  String get liveStatus;

  /// No description provided for @coreStopped.
  ///
  /// In en, this message translates to:
  /// **'Core stopped'**
  String get coreStopped;

  /// No description provided for @coreStoppedDesc.
  ///
  /// In en, this message translates to:
  /// **'The app lost its connection to the core'**
  String get coreStoppedDesc;

  /// No description provided for @coreStoppedWithReason.
  ///
  /// In en, this message translates to:
  /// **'The app lost its connection to the core: {reason}'**
  String coreStoppedWithReason(Object reason);

  /// No description provided for @mixedPortReset.
  ///
  /// In en, this message translates to:
  /// **'The mixed port cannot be {value}, so it was set back to {port}'**
  String mixedPortReset(Object value, Object port);

  /// No description provided for @restartCore.
  ///
  /// In en, this message translates to:
  /// **'Restart core'**
  String get restartCore;

  /// No description provided for @installUpdate.
  ///
  /// In en, this message translates to:
  /// **'Install update'**
  String get installUpdate;

  /// No description provided for @liveStatusPosition.
  ///
  /// In en, this message translates to:
  /// **'{index} of {count}'**
  String liveStatusPosition(Object index, Object count);

  /// No description provided for @coreStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting core'**
  String get coreStarting;

  /// No description provided for @coreStartingDesc.
  ///
  /// In en, this message translates to:
  /// **'Connecting to the core'**
  String get coreStartingDesc;

  /// No description provided for @coreRunning.
  ///
  /// In en, this message translates to:
  /// **'Core running'**
  String get coreRunning;

  /// No description provided for @coreRunningDesc.
  ///
  /// In en, this message translates to:
  /// **'The app is connected to the core'**
  String get coreRunningDesc;

  /// No description provided for @forceRestartCore.
  ///
  /// In en, this message translates to:
  /// **'Force restart'**
  String get forceRestartCore;

  /// No description provided for @vpnPermissionNotGranted.
  ///
  /// In en, this message translates to:
  /// **'VPN permission was not granted, so the VPN did not start. An always-on VPN set for another app also blocks it.'**
  String get vpnPermissionNotGranted;

  /// No description provided for @vpnServiceStartFailed.
  ///
  /// In en, this message translates to:
  /// **'The VPN service could not start.'**
  String get vpnServiceStartFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
