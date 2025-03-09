// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// 本文件為 en 地區提供訊息的庫。主程式中的所有訊息應在此以相同函數名稱重複定義。

// 忽略此文件中常見的 lint 問題。
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
  String get localeName => 'zh_TW';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("關於"),
    "accessControl": MessageLookupByLibrary.simpleMessage("存取控制"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "僅允許指定的應用程式使用 VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "設定應用程式的代理存取權限",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "選定的應用程式將無法使用 VPN",
    ),
    "account": MessageLookupByLibrary.simpleMessage("帳戶"),
    "accountTip": MessageLookupByLibrary.simpleMessage(
      "帳戶欄位不得為空",
    ),
    "action": MessageLookupByLibrary.simpleMessage("操作"),
    "action_mode": MessageLookupByLibrary.simpleMessage("切換模式"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("系統代理"),
    "action_start": MessageLookupByLibrary.simpleMessage("啟動/停止"),
    "action_tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "action_view": MessageLookupByLibrary.simpleMessage("顯示/隱藏"),
    "add": MessageLookupByLibrary.simpleMessage("新增"),
    "address": MessageLookupByLibrary.simpleMessage("位址"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "WebDAV 伺服器位址",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "請輸入有效的 WebDAV 位址",
    ),
    "adminAutoLaunch": MessageLookupByLibrary.simpleMessage(
      "管理員自動啟動",
    ),
    "adminAutoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "以管理員權限自動啟動",
    ),
    "ago": MessageLookupByLibrary.simpleMessage("前"),
    "agree": MessageLookupByLibrary.simpleMessage("同意"),
    "allApps": MessageLookupByLibrary.simpleMessage("所有應用程式"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "允許應用程式繞過 VPN",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "啟用後，部分應用程式可繞過 VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("允許區域網路"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "允許透過區域網路存取代理",
    ),
    "app": MessageLookupByLibrary.simpleMessage("應用程式"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "應用程式存取控制",
    ),
    "appDesc": MessageLookupByLibrary.simpleMessage(
      "管理應用程式相關設定",
    ),
    "application": MessageLookupByLibrary.simpleMessage("應用程式"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "調整應用程式相關設定",
    ),
    "auto": MessageLookupByLibrary.simpleMessage("自動"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "自動檢查更新",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "程式啟動時自動檢查更新",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "自動關閉連線",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "更換節點後自動關閉現有連線",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("自動啟動"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "隨系統開機自動啟動",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("自動運行"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "應用程式啟動時自動執行",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("自動更新"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "自動更新間隔（分鐘）",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("備份"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage(
      "備份與恢復",
    ),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "透過 WebDAV 或檔案同步資料",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("備份成功"),
    "bind": MessageLookupByLibrary.simpleMessage("綁定"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("黑名單模式"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("繞過域名"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "僅在啟用系統代理時生效",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "快取已損壞，是否清除？",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancelFilterSystemApp": MessageLookupByLibrary.simpleMessage(
      "取消過濾系統應用程式",
    ),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "取消全選",
    ),
    "checkError": MessageLookupByLibrary.simpleMessage("檢查錯誤"),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("檢查更新"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "當前應用程式已是最新版本",
    ),
    "checking": MessageLookupByLibrary.simpleMessage("檢查中…"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("匯出至剪貼簿"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("從剪貼簿匯入"),
    "columns": MessageLookupByLibrary.simpleMessage("欄位"),
    "compatible": MessageLookupByLibrary.simpleMessage("相容模式"),
    "compatibleDesc": MessageLookupByLibrary.simpleMessage(
      "啟用後將犧牲部分應用程式功能，以換取對 Clash 的完整支援",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("確認"),
    "connections": MessageLookupByLibrary.simpleMessage("連線"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "查看當前連線資訊",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("連線狀態："),
    "copy": MessageLookupByLibrary.simpleMessage("複製"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "複製環境變數",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("複製連結"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("複製成功"),
    "core": MessageLookupByLibrary.simpleMessage("核心"),
    "coreInfo": MessageLookupByLibrary.simpleMessage("核心資訊"),
    "country": MessageLookupByLibrary.simpleMessage("國家/地區"),
    "create": MessageLookupByLibrary.simpleMessage("建立"),
    "cut": MessageLookupByLibrary.simpleMessage("剪下"),
    "dark": MessageLookupByLibrary.simpleMessage("深色"),
    "dashboard": MessageLookupByLibrary.simpleMessage("儀表板"),
    "days": MessageLookupByLibrary.simpleMessage("天"),
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "預設名稱伺服器",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "用於解析 DNS 的伺服器",
    ),
    "defaultSort": MessageLookupByLibrary.simpleMessage("預設排序"),
    "defaultText": MessageLookupByLibrary.simpleMessage("預設"),
    "delay": MessageLookupByLibrary.simpleMessage("延遲"),
    "delaySort": MessageLookupByLibrary.simpleMessage("按延遲排序"),
    "delete": MessageLookupByLibrary.simpleMessage("刪除"),
    "deleteProfileTip": MessageLookupByLibrary.simpleMessage(
      "確定要刪除當前設定檔嗎？",
    ),
    "desc": MessageLookupByLibrary.simpleMessage(
      "基於 ClashMeta 的多平台代理客戶端，簡單易用、開源且無廣告",
    ),
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "依賴第三方 API，結果僅供參考",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("直接連線"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("免責聲明"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "本軟體僅限於學習交流及科學研究等非商業用途，嚴禁用於商業目的。任何商業行為（如有）與本軟體無關",
    ),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "發現新版本",
    ),
    "discovery": MessageLookupByLibrary.simpleMessage(
      "發現新版本",
    ),
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "更新 DNS 相關設定",
    ),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS 模式"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage(
      "您確定要通過嗎？",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("域名"),
    "download": MessageLookupByLibrary.simpleMessage("下載"),
    "edit": MessageLookupByLibrary.simpleMessage("編輯"),
    "en": MessageLookupByLibrary.simpleMessage("英文"),
    "entries": MessageLookupByLibrary.simpleMessage("條目"),
    "exclude": MessageLookupByLibrary.simpleMessage("從最近任務中隱藏"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "在應用程式運行於背景時，從最近任務列表中隱藏",
    ),
    "exit": MessageLookupByLibrary.simpleMessage("退出"),
    "expand": MessageLookupByLibrary.simpleMessage("標準"),
    "expirationTime": MessageLookupByLibrary.simpleMessage("到期時間"),
    "exportFile": MessageLookupByLibrary.simpleMessage("匯出檔案"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("匯出日誌"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("匯出成功"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "外部控制器",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "啟用後，可透過 9090 端口控制 Clash 核心",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("外部連結"),
    "externalResources": MessageLookupByLibrary.simpleMessage(
      "外部資源",
    ),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("虛擬 IP 過濾"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("虛擬 IP 範圍"),
    "fallback": MessageLookupByLibrary.simpleMessage("備用"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "通常使用海外 DNS 伺服器",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("備用過濾"),
    "file": MessageLookupByLibrary.simpleMessage("檔案"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("直接上傳設定檔"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "檔案已變更，是否儲存修改？",
    ),
    "filterSystemApp": MessageLookupByLibrary.simpleMessage(
      "過濾系統應用程式",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("尋找進程模式"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "啟用後可能有程式閃退風險",
    ),
    "fontFamily": MessageLookupByLibrary.simpleMessage("字型家族"),
    "fourColumns": MessageLookupByLibrary.simpleMessage("四欄"),
    "general": MessageLookupByLibrary.simpleMessage("一般"),
    "generalDesc": MessageLookupByLibrary.simpleMessage(
      "管理一般設定",
    ),
    "geoData": MessageLookupByLibrary.simpleMessage("地理資料"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "地理資料低記憶體模式",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "啟用後將採用低記憶體地理資料載入器",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("地理 IP 代碼"),
    "global": MessageLookupByLibrary.simpleMessage("全局"),
    "go": MessageLookupByLibrary.simpleMessage("前往"),
    "goDownload": MessageLookupByLibrary.simpleMessage("前往下載"),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "是否儲存快取變更？",
    ),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("新增主機設定"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("快捷鍵衝突"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "快捷鍵管理",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "使用鍵盤快捷鍵控制應用程式",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("小時"),
    "icon": MessageLookupByLibrary.simpleMessage("圖示"),
    "iconConfiguration": MessageLookupByLibrary.simpleMessage(
      "圖示設定",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("圖示樣式"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("從 URL 匯入"),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("無限期有效"),
    "init": MessageLookupByLibrary.simpleMessage("初始化"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "請輸入有效的快捷鍵",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "智能選擇",
    ),
    "intranetIP": MessageLookupByLibrary.simpleMessage("內網 IP"),
    "ipcidr": MessageLookupByLibrary.simpleMessage("IPCIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "啟用後可接收 IPv6 流量",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "允許 IPv6 入站流量",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("日文"),
    "just": MessageLookupByLibrary.simpleMessage("剛剛"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP 保持連線間隔",
    ),
    "key": MessageLookupByLibrary.simpleMessage("鍵值"),
    "ko": MessageLookupByLibrary.simpleMessage("韓文"),
    "fr": MessageLookupByLibrary.simpleMessage("法文"),
    "de": MessageLookupByLibrary.simpleMessage("德文"),
    "ar": MessageLookupByLibrary.simpleMessage("阿拉伯文"),
    "fa": MessageLookupByLibrary.simpleMessage("波斯文"),
    "language": MessageLookupByLibrary.simpleMessage("語言"),
    "layout": MessageLookupByLibrary.simpleMessage("版面配置"),
    "light": MessageLookupByLibrary.simpleMessage("淺色"),
    "list": MessageLookupByLibrary.simpleMessage("列表"),
    "listen": MessageLookupByLibrary.simpleMessage("監聽"),
    "local": MessageLookupByLibrary.simpleMessage("本地"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "將資料備份至本地",
    ),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "從本地檔案恢復資料",
    ),
    "logLevel": MessageLookupByLibrary.simpleMessage("日誌等級"),
    "logcat": MessageLookupByLibrary.simpleMessage("日誌捕獲"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "停用後將隱藏日誌內容",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("日誌"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("查看日誌記錄"),
    "loopback": MessageLookupByLibrary.simpleMessage("回環解鎖工具"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "用於解鎖 UWP 回環限制",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("寬鬆"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("記憶體資訊"),
    "min": MessageLookupByLibrary.simpleMessage("分"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("退出時最小化"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "更改預設退出行為為最小化",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("分鐘"),
    "mode": MessageLookupByLibrary.simpleMessage("模式"),
    "months": MessageLookupByLibrary.simpleMessage("個月"),
    "more": MessageLookupByLibrary.simpleMessage("更多"),
    "name": MessageLookupByLibrary.simpleMessage("名稱"),
    "nameSort": MessageLookupByLibrary.simpleMessage("按名稱排序"),
    "nameserver": MessageLookupByLibrary.simpleMessage("名稱伺服器"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "用於解析域名的伺服器",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "名稱伺服器策略",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "指定對應的名稱伺服器策略",
    ),
    "network": MessageLookupByLibrary.simpleMessage("網路"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "調整網路相關設定",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage(
      "網路檢測",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("網路速度"),
    "noData": MessageLookupByLibrary.simpleMessage("無資料"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("無快捷鍵"),
    "noIcon": MessageLookupByLibrary.simpleMessage("無圖示"),
    "noInfo": MessageLookupByLibrary.simpleMessage("無資訊"),
    "noMoreInfoDesc": MessageLookupByLibrary.simpleMessage("無更多資訊"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("無網路連線"),
    "noProxy": MessageLookupByLibrary.simpleMessage("無代理"),
    "noProxyDesc": MessageLookupByLibrary.simpleMessage(
      "請建立設定檔或新增有效的設定檔",
    ),
    "notEmpty": MessageLookupByLibrary.simpleMessage("不得為空"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "當前代理群組無法選擇",
    ),
    "nullConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "無連線",
    ),
    "nullCoreInfoDesc": MessageLookupByLibrary.simpleMessage(
      "無法獲取核心資訊",
    ),
    "nullLogsDesc": MessageLookupByLibrary.simpleMessage("無日誌記錄"),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "無設定檔，請新增設定檔",
    ),
    "nullProxies": MessageLookupByLibrary.simpleMessage("無代理"),
    "nullRequestsDesc": MessageLookupByLibrary.simpleMessage("無請求記錄"),
    "oneColumn": MessageLookupByLibrary.simpleMessage("單欄"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("僅圖示"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage(
      "僅第三方應用程式",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "僅統計代理流量",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "啟用後僅記錄代理相關流量",
    ),
    "options": MessageLookupByLibrary.simpleMessage("選項"),
    "other": MessageLookupByLibrary.simpleMessage("其他"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "其他貢獻者",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("出站模式"),
    "override": MessageLookupByLibrary.simpleMessage("覆蓋"),
    "overrideDesc": MessageLookupByLibrary.simpleMessage(
      "覆蓋代理相關設定",
    ),
    "overrideDns": MessageLookupByLibrary.simpleMessage("覆蓋 DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "啟用後將覆蓋設定檔中的 DNS 設定",
    ),
    "password": MessageLookupByLibrary.simpleMessage("密碼"),
    "passwordTip": MessageLookupByLibrary.simpleMessage(
      "密碼欄位不得為空",
    ),
    "paste": MessageLookupByLibrary.simpleMessage("貼上"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "請綁定 WebDAV",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "請輸入管理員密碼",
    ),
    "pleaseUploadFile": MessageLookupByLibrary.simpleMessage(
      "請上傳檔案",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "請上傳有效的 QR Code",
    ),
    "port": MessageLookupByLibrary.simpleMessage("端口"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "優先使用 HTTP/3 的 DOH",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "請按下鍵盤按鍵",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("預覽"),
    "profile": MessageLookupByLibrary.simpleMessage("設定檔"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "請輸入有效的間隔時間格式",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "請輸入自動更新間隔時間",
        ),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "設定檔已變更，是否停用自動更新？",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "請輸入設定檔名稱",
    ),
    "profileParseErrorDesc": MessageLookupByLibrary.simpleMessage(
      "設定檔解析失敗",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "請輸入有效的設定檔 URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "請輸入設定檔 URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("設定檔"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("設定檔排序"),
    "project": MessageLookupByLibrary.simpleMessage("專案"),
    "providers": MessageLookupByLibrary.simpleMessage("提供者"),
    "proxies": MessageLookupByLibrary.simpleMessage("代理"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("代理設定"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("代理群組"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("代理名稱伺服器"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "用於解析代理節點域名的伺服器",
    ),
    "proxyPort": MessageLookupByLibrary.simpleMessage("代理端口"),
    "proxyPortDesc": MessageLookupByLibrary.simpleMessage(
      "設定 Clash 的監聽端口",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("代理提供者"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("純黑模式"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR Code"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "掃描 QR Code 以匯入設定檔",
    ),
    "recovery": MessageLookupByLibrary.simpleMessage("恢復"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("恢復所有資料"),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage(
      "僅恢復設定檔",
    ),
    "recoverySuccess": MessageLookupByLibrary.simpleMessage("恢復成功"),
    "regExp": MessageLookupByLibrary.simpleMessage("正規表達式"),
    "remote": MessageLookupByLibrary.simpleMessage("遠端"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "將資料備份至 WebDAV",
    ),
    "remoteRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "從 WebDAV 恢復資料",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("移除"),
    "requests": MessageLookupByLibrary.simpleMessage("請求"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "查看近期請求記錄",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("重置"),
    "resetTip": MessageLookupByLibrary.simpleMessage("確定要重置嗎？"),
    "resources": MessageLookupByLibrary.simpleMessage("資源"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "外部資源相關資訊",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("遵循規則"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS 連線遵循規則，需設定代理與名稱伺服器",
    ),
    "routeAddress": MessageLookupByLibrary.simpleMessage("路由位址"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "設定監聽的路由位址",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("路由模式"),
    "routeMode_bypassPrivate": MessageLookupByLibrary.simpleMessage(
      "繞過私有路由位址",
    ),
    "routeMode_config": MessageLookupByLibrary.simpleMessage("使用設定檔"),
    "ru": MessageLookupByLibrary.simpleMessage("俄文"),
    "rule": MessageLookupByLibrary.simpleMessage("規則"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("規則提供者"),
    "save": MessageLookupByLibrary.simpleMessage("儲存"),
    "search": MessageLookupByLibrary.simpleMessage("搜尋"),
    "seconds": MessageLookupByLibrary.simpleMessage("秒"),
    "selectAll": MessageLookupByLibrary.simpleMessage("全選"),
    "selected": MessageLookupByLibrary.simpleMessage("已選中"),
    "settings": MessageLookupByLibrary.simpleMessage("設定"),
    "show": MessageLookupByLibrary.simpleMessage("顯示"),
    "shrink": MessageLookupByLibrary.simpleMessage("縮減"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("靜默啟動"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "於背景中啟動應用程式",
    ),
    "size": MessageLookupByLibrary.simpleMessage("大小"),
    "sort": MessageLookupByLibrary.simpleMessage("排序"),
    "source": MessageLookupByLibrary.simpleMessage("來源"),
    "stackMode": MessageLookupByLibrary.simpleMessage("堆疊模式"),
    "standard": MessageLookupByLibrary.simpleMessage("標準"),
    "start": MessageLookupByLibrary.simpleMessage("啟動"),
    "startVpn": MessageLookupByLibrary.simpleMessage("正在啟動 VPN…"),
    "status": MessageLookupByLibrary.simpleMessage("狀態"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "關閉時將使用系統 DNS",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("停止"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("正在停止 VPN…"),
    "style": MessageLookupByLibrary.simpleMessage("樣式"),
    "submit": MessageLookupByLibrary.simpleMessage("提交"),
    "sync": MessageLookupByLibrary.simpleMessage("同步"),
    "system": MessageLookupByLibrary.simpleMessage("系統"),
    "systemFont": MessageLookupByLibrary.simpleMessage("系統字型"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("系統代理"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "將 HTTP 代理附加至 VpnService",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("標籤"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("標籤動畫"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "啟用後，首頁標籤切換將顯示動畫效果",
    ),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP 並行"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "啟用後允許 TCP 並行傳輸",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("測試 URL"),
    "theme": MessageLookupByLibrary.simpleMessage("主題"),
    "themeColor": MessageLookupByLibrary.simpleMessage("主題色彩"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "設定深色模式或調整色彩",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("主題模式"),
    "threeColumns": MessageLookupByLibrary.simpleMessage("三欄"),
    "tight": MessageLookupByLibrary.simpleMessage("緊湊"),
    "time": MessageLookupByLibrary.simpleMessage("時間"),
    "tip": MessageLookupByLibrary.simpleMessage("提示"),
    "toggle": MessageLookupByLibrary.simpleMessage("切換"),
    "tools": MessageLookupByLibrary.simpleMessage("工具"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("流量使用情況"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "僅在管理員模式下生效",
    ),
    "twoColumns": MessageLookupByLibrary.simpleMessage("雙欄"),
    "unableToUpdateCurrentProfileDesc": MessageLookupByLibrary.simpleMessage(
      "無法更新當前設定檔",
    ),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("統一延遲"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "移除握手等額外延遲時間",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("未知"),
    "update": MessageLookupByLibrary.simpleMessage("更新"),
    "upload": MessageLookupByLibrary.simpleMessage("上傳"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "透過 URL 獲取設定檔",
    ),
    "useHosts": MessageLookupByLibrary.simpleMessage("使用主機設定"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("使用系統主機"),
    "value": MessageLookupByLibrary.simpleMessage("值"),
    "view": MessageLookupByLibrary.simpleMessage("查看"),
    "vpnDesc": MessageLookupByLibrary.simpleMessage(
      "調整 VPN 相關設定",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "啟用後，所有系統流量將自動透過 VpnService 路由",
    ),
    "vpnSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "將 HTTP 代理整合至 VpnService",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "重啟 VPN 後設定生效",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV 設定",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("白名單模式"),
    "years": MessageLookupByLibrary.simpleMessage("年"),
    "zh_CN": MessageLookupByLibrary.simpleMessage("簡體中文"),
    "zh_TW": MessageLookupByLibrary.simpleMessage("繁體中文"),
  };
}
