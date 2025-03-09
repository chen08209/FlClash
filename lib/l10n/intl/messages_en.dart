// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This file is a library providing messages for the en locale. All messages from the main program should be redefined here with the same function names.

// Ignore common lint issues in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Access Control"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Only specified applications can use the VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Set proxy access permissions for applications",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Selected applications cannot use the VPN",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "accountTip": MessageLookupByLibrary.simpleMessage(
      "The account field cannot be empty",
    ),
    "action": MessageLookupByLibrary.simpleMessage("Action"),
    "action_mode": MessageLookupByLibrary.simpleMessage("Switch Mode"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("System Proxy"),
    "action_start": MessageLookupByLibrary.simpleMessage("Start/Stop"),
    "action_tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "action_view": MessageLookupByLibrary.simpleMessage("Show/Hide"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "WebDAV server address",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid WebDAV address",
    ),
    "adminAutoLaunch": MessageLookupByLibrary.simpleMessage(
      "Admin Auto-Launch",
    ),
    "adminAutoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Automatically launch with administrator privileges",
    ),
    "ago": MessageLookupByLibrary.simpleMessage("ago"),
    "agree": MessageLookupByLibrary.simpleMessage("Agree"),
    "allApps": MessageLookupByLibrary.simpleMessage("All Applications"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Allow Applications to Bypass VPN",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, some applications can bypass the VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("Allow LAN"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "Allow access to the proxy via LAN",
    ),
    "app": MessageLookupByLibrary.simpleMessage("App"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "App Access Control",
    ),
    "appDesc": MessageLookupByLibrary.simpleMessage(
      "Manage application-related settings",
    ),
    "application": MessageLookupByLibrary.simpleMessage("Application"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "Adjust application-related settings",
    ),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Auto Check Updates",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "Check for updates automatically on program startup",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Auto Close Connections",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Automatically close existing connections when switching nodes",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Auto Launch"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Start automatically with the system",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("Auto Run"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Run automatically when the application starts",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Auto Update"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Auto Update Interval (minutes)",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("Backup"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage(
      "Backup and Recovery",
    ),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Sync data via WebDAV or files",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("Backup Successful"),
    "bind": MessageLookupByLibrary.simpleMessage("Bind"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Blacklist Mode"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Bypass Domain"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Only applies when system proxy is enabled",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Cache is corrupted. Clear it?",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelFilterSystemApp": MessageLookupByLibrary.simpleMessage(
      "Cancel System App Filter",
    ),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "Deselect All",
    ),
    "checkError": MessageLookupByLibrary.simpleMessage("Check Error"),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Check Update"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "The current application is already the latest version",
    ),
    "checking": MessageLookupByLibrary.simpleMessage("Checking…"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("Export to Clipboard"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("Import from Clipboard"),
    "columns": MessageLookupByLibrary.simpleMessage("Columns"),
    "compatible": MessageLookupByLibrary.simpleMessage("Compatibility Mode"),
    "compatibleDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, some app features are sacrificed for full Clash support",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "connections": MessageLookupByLibrary.simpleMessage("Connections"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "View current connection information",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("Connectivity:"),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Copy Environment Variables",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copy Link"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Copy Successful"),
    "core": MessageLookupByLibrary.simpleMessage("Core"),
    "coreInfo": MessageLookupByLibrary.simpleMessage("Core Info"),
    "country": MessageLookupByLibrary.simpleMessage("Country/Region"),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "cut": MessageLookupByLibrary.simpleMessage("Cut"),
    "dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "days": MessageLookupByLibrary.simpleMessage("days"),
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "Default Nameserver",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Server used for DNS resolution",
    ),
    "defaultSort": MessageLookupByLibrary.simpleMessage("Default Sort"),
    "defaultText": MessageLookupByLibrary.simpleMessage("Default"),
    "delay": MessageLookupByLibrary.simpleMessage("Delay"),
    "delaySort": MessageLookupByLibrary.simpleMessage("Sort by Delay"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteProfileTip": MessageLookupByLibrary.simpleMessage(
      "Delete the current profile?",
    ),
    "desc": MessageLookupByLibrary.simpleMessage(
      "A multi-platform proxy client based on ClashMeta, easy to use, open-source, and ad-free",
    ),
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Depends on a third-party API, results are for reference only",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("Direct Connection"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Disclaimer"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "This software is limited to educational, research, and non-commercial use only. Commercial use is strictly prohibited. Any commercial activities (if any) are unrelated to this software",
    ),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "New Version Discovered",
    ),
    "discovery": MessageLookupByLibrary.simpleMessage(
      "New Version Discovered",
    ),
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "Update DNS-related settings",
    ),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS Mode"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to proceed?",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("Domain"),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "en": MessageLookupByLibrary.simpleMessage("English"),
    "entries": MessageLookupByLibrary.simpleMessage("Entries"),
    "exclude": MessageLookupByLibrary.simpleMessage("Hide from Recent Tasks"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "Hide the app from the recent tasks list when running in the background",
    ),
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "expand": MessageLookupByLibrary.simpleMessage("Standard"),
    "expirationTime": MessageLookupByLibrary.simpleMessage("Expiration Time"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Export File"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Export Logs"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Export Successful"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "External Controller",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, the Clash core can be controlled via port 9090",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("External Link"),
    "externalResources": MessageLookupByLibrary.simpleMessage(
      "External Resources",
    ),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake IP Filter"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake IP Range"),
    "fallback": MessageLookupByLibrary.simpleMessage("Fallback"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Typically uses an overseas DNS server",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Fallback Filter"),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("Upload a profile file directly"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "The file has been modified. Save changes?",
    ),
    "filterSystemApp": MessageLookupByLibrary.simpleMessage(
      "Filter System Apps",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Find Process Mode"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, there may be a risk of app crashes",
    ),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Font Family"),
    "fourColumns": MessageLookupByLibrary.simpleMessage("Four Columns"),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "generalDesc": MessageLookupByLibrary.simpleMessage(
      "Manage general settings",
    ),
    "geoData": MessageLookupByLibrary.simpleMessage("Geo Data"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Geo Data Low Memory Mode",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, a low-memory geo data loader is used",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("GeoIP Code"),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "go": MessageLookupByLibrary.simpleMessage("Go"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Go to Download"),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Save cache changes?",
    ),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("Add host settings"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("Hotkey Conflict"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Hotkey Management",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "Control the application with keyboard shortcuts",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("hours"),
    "icon": MessageLookupByLibrary.simpleMessage("Icon"),
    "iconConfiguration": MessageLookupByLibrary.simpleMessage(
      "Icon Configuration",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Icon Style"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Unlimited"),
    "init": MessageLookupByLibrary.simpleMessage("Initialize"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid hotkey",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Intelligent Selection",
    ),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Intranet IP"),
    "ipcidr": MessageLookupByLibrary.simpleMessage("IPCIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "When enabled, IPv6 traffic can be received",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Allow IPv6 inbound traffic",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("Japanese"),
    "just": MessageLookupByLibrary.simpleMessage("just now"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP keep-alive interval",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Key"),
    "ko": MessageLookupByLibrary.simpleMessage("Korean"),
    "fr": MessageLookupByLibrary.simpleMessage("French"),
    "de": MessageLookupByLibrary.simpleMessage("German"),
    "ar": MessageLookupByLibrary.simpleMessage("Arabic"),
    "fa": MessageLookupByLibrary.simpleMessage("Persian"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "layout": MessageLookupByLibrary.simpleMessage("Layout"),
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "list": MessageLookupByLibrary.simpleMessage("List"),
    "listen": MessageLookupByLibrary.simpleMessage("Listen"),
    "local": MessageLookupByLibrary.simpleMessage("Local"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Back up data locally",
    ),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data from a local file",
    ),
    "logLevel": MessageLookupByLibrary.simpleMessage("Log Level"),
    "logcat": MessageLookupByLibrary.simpleMessage("Log Capture"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "When disabled, log contents will be hidden",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Logs"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("View log records"),
    "loopback": MessageLookupByLibrary.simpleMessage("Loopback Unlock Tool"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "Used to unlock UWP loopback restrictions",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Loose"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Memory Info"),
    "min": MessageLookupByLibrary.simpleMessage("min"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("Minimize on Exit"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "Change the default exit behavior to minimize",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("minutes"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "months": MessageLookupByLibrary.simpleMessage("months"),
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameSort": MessageLookupByLibrary.simpleMessage("Sort by Name"),
    "nameserver": MessageLookupByLibrary.simpleMessage("Nameserver"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Server used for domain resolution",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "Nameserver Policy",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Specify the corresponding nameserver policy",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Network"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "Adjust network-related settings",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage(
      "Network Detection",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Network Speed"),
    "noData": MessageLookupByLibrary.simpleMessage("No Data"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("No Hotkey"),
    "noIcon": MessageLookupByLibrary.simpleMessage("No Icon"),
    "noInfo": MessageLookupByLibrary.simpleMessage("No Info"),
    "noMoreInfoDesc": MessageLookupByLibrary.simpleMessage("No More Info"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("No Network Connection"),
    "noProxy": MessageLookupByLibrary.simpleMessage("No Proxy"),
    "noProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Create a profile or add a valid profile",
    ),
    "notEmpty": MessageLookupByLibrary.simpleMessage("Cannot Be Empty"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "The current proxy group cannot be selected",
    ),
    "nullConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "No Connections",
    ),
    "nullCoreInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Unable to Retrieve Core Info",
    ),
    "nullLogsDesc": MessageLookupByLibrary.simpleMessage("No Log Records"),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "No Profile, Please Add a Profile",
    ),
    "nullProxies": MessageLookupByLibrary.simpleMessage("No Proxies"),
    "nullRequestsDesc": MessageLookupByLibrary.simpleMessage("No Request Records"),
    "oneColumn": MessageLookupByLibrary.simpleMessage("One Column"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Icon Only"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage(
      "Third-Party Apps Only",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Proxy Traffic Statistics Only",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, only proxy-related traffic is recorded",
    ),
    "options": MessageLookupByLibrary.simpleMessage("Options"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Other Contributors",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Outbound Mode"),
    "override": MessageLookupByLibrary.simpleMessage("Override"),
    "overrideDesc": MessageLookupByLibrary.simpleMessage(
      "Override proxy-related settings",
    ),
    "overrideDns": MessageLookupByLibrary.simpleMessage("Override DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, DNS settings in the profile will be overridden",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordTip": MessageLookupByLibrary.simpleMessage(
      "The password field cannot be empty",
    ),
    "paste": MessageLookupByLibrary.simpleMessage("Paste"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Please Bind WebDAV",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "Please Enter Admin Password",
    ),
    "pleaseUploadFile": MessageLookupByLibrary.simpleMessage(
      "Please Upload a File",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Please Upload a Valid QR Code",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "Prefer DOH via HTTP/3",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Press a Keyboard Key",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Please enter a valid interval format",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Please enter an auto-update interval",
        ),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "The profile has been modified. Disable auto-update?",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter a profile name",
    ),
    "profileParseErrorDesc": MessageLookupByLibrary.simpleMessage(
      "Profile parsing failed",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid profile URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter a profile URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Profiles"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Sort Profiles"),
    "project": MessageLookupByLibrary.simpleMessage("Project"),
    "providers": MessageLookupByLibrary.simpleMessage("Providers"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxies"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("Proxy Settings"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Proxy Group"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("Proxy Nameserver"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Server used to resolve proxy node domains",
    ),
    "proxyPort": MessageLookupByLibrary.simpleMessage("Proxy Port"),
    "proxyPortDesc": MessageLookupByLibrary.simpleMessage(
      "Set the listening port for Clash",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Proxy Providers"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Pure Black Mode"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR Code"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Scan a QR code to import a profile",
    ),
    "recovery": MessageLookupByLibrary.simpleMessage("Recovery"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("Recover All Data"),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage(
      "Recover Profiles Only",
    ),
    "recoverySuccess": MessageLookupByLibrary.simpleMessage("Recovery Successful"),
    "regExp": MessageLookupByLibrary.simpleMessage("Regular Expression"),
    "remote": MessageLookupByLibrary.simpleMessage("Remote"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Back up data to WebDAV",
    ),
    "remoteRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data from WebDAV",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "requests": MessageLookupByLibrary.simpleMessage("Requests"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "View recent request records",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetTip": MessageLookupByLibrary.simpleMessage("Reset settings?"),
    "resources": MessageLookupByLibrary.simpleMessage("Resources"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Information about external resources",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("Follow Rules"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS connections follow rules, requiring proxy and nameserver setup",
    ),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Route Address"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "Set the routing address to listen to",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("Route Mode"),
    "routeMode_bypassPrivate": MessageLookupByLibrary.simpleMessage(
      "Bypass Private Route Addresses",
    ),
    "routeMode_config": MessageLookupByLibrary.simpleMessage("Use Profile"),
    "ru": MessageLookupByLibrary.simpleMessage("Russian"),
    "rule": MessageLookupByLibrary.simpleMessage("Rule"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Rule Providers"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "seconds": MessageLookupByLibrary.simpleMessage("seconds"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Select All"),
    "selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "show": MessageLookupByLibrary.simpleMessage("Show"),
    "shrink": MessageLookupByLibrary.simpleMessage("Shrink"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Silent Launch"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Launch the application in the background",
    ),
    "size": MessageLookupByLibrary.simpleMessage("Size"),
    "sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "source": MessageLookupByLibrary.simpleMessage("Source"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Stack Mode"),
    "standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Starting VPN…"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "When off, the system DNS will be used",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Stop"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Stopping VPN…"),
    "style": MessageLookupByLibrary.simpleMessage("Style"),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "sync": MessageLookupByLibrary.simpleMessage("Sync"),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "systemFont": MessageLookupByLibrary.simpleMessage("System Font"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("System Proxy"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Add an HTTP proxy to VpnService",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("Tab"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Tab Animation"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, tab switching on the homepage will show an animation",
    ),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP Concurrent"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, concurrent TCP transmission is allowed",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("Test URL"),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Theme Color"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Set dark mode or adjust colors",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Theme Mode"),
    "threeColumns": MessageLookupByLibrary.simpleMessage("Three Columns"),
    "tight": MessageLookupByLibrary.simpleMessage("Compact"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "tip": MessageLookupByLibrary.simpleMessage("Tip"),
    "toggle": MessageLookupByLibrary.simpleMessage("Toggle"),
    "tools": MessageLookupByLibrary.simpleMessage("Tools"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Traffic Usage"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "Only works in administrator mode",
    ),
    "twoColumns": MessageLookupByLibrary.simpleMessage("Two Columns"),
    "unableToUpdateCurrentProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Unable to update the current profile",
    ),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Unified Delay"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "Remove additional delays such as handshake",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "upload": MessageLookupByLibrary.simpleMessage("Upload"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "Retrieve a profile via URL",
    ),
    "useHosts": MessageLookupByLibrary.simpleMessage("Use Host Settings"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("Use System Hosts"),
    "value": MessageLookupByLibrary.simpleMessage("Value"),
    "view": MessageLookupByLibrary.simpleMessage("View"),
    "vpnDesc": MessageLookupByLibrary.simpleMessage(
      "Adjust VPN-related settings",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, all system traffic will be automatically routed through VpnService",
    ),
    "vpnSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Integrate an HTTP proxy into VpnService",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "Settings take effect after restarting the VPN",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV Configuration",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Whitelist Mode"),
    "years": MessageLookupByLibrary.simpleMessage("years"),
    "zh_CN": MessageLookupByLibrary.simpleMessage("Simplified Chinese"),
    "zh_TW": MessageLookupByLibrary.simpleMessage("Traditional Chinese"),
  };
}
