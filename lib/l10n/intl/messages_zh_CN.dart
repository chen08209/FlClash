// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// 本文件为 en 地区提供消息的库。主程序中的所有消息应在此以相同函数名称重复定义。

// 忽略此文件中常见的 lint 问题。
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
  String get localeName => 'zh_CN';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("关于"),
    "accessControl": MessageLookupByLibrary.simpleMessage("访问控制"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "仅允许指定的应用程序使用 VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "设置应用程序的代理访问权限",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "选定的应用程序将无法使用 VPN",
    ),
    "account": MessageLookupByLibrary.simpleMessage("账户"),
    "accountTip": MessageLookupByLibrary.simpleMessage(
      "账户字段不得为空",
    ),
    "action": MessageLookupByLibrary.simpleMessage("操作"),
    "action_mode": MessageLookupByLibrary.simpleMessage("切换模式"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("系统代理"),
    "action_start": MessageLookupByLibrary.simpleMessage("启动/停止"),
    "action_tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "action_view": MessageLookupByLibrary.simpleMessage("显示/隐藏"),
    "add": MessageLookupByLibrary.simpleMessage("新增"),
    "address": MessageLookupByLibrary.simpleMessage("地址"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "WebDAV 服务器地址",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "请输入有效的 WebDAV 地址",
    ),
    "adminAutoLaunch": MessageLookupByLibrary.simpleMessage(
      "管理员自动启动",
    ),
    "adminAutoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "以管理员权限自动启动",
    ),
    "ago": MessageLookupByLibrary.simpleMessage("前"),
    "agree": MessageLookupByLibrary.simpleMessage("同意"),
    "allApps": MessageLookupByLibrary.simpleMessage("所有应用程序"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "允许应用程序绕过 VPN",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "启用后，部分应用程序可绕过 VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("允许局域网"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "允许通过局域网访问代理",
    ),
    "app": MessageLookupByLibrary.simpleMessage("应用程序"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "应用程序访问控制",
    ),
    "appDesc": MessageLookupByLibrary.simpleMessage(
      "管理应用程序相关设置",
    ),
    "application": MessageLookupByLibrary.simpleMessage("应用程序"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "调整应用程序相关设置",
    ),
    "auto": MessageLookupByLibrary.simpleMessage("自动"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "自动检查更新",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "程序启动时自动检查更新",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "自动关闭连接",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "更换节点后自动关闭现有连接",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("自动启动"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "随系统开机自动启动",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("自动运行"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "应用程序启动时自动运行",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("自动更新"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "自动更新间隔（分钟）",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("备份"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage(
      "备份与恢复",
    ),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "通过 WebDAV 或文件同步数据",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("备份成功"),
    "bind": MessageLookupByLibrary.simpleMessage("绑定"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("黑名单模式"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("绕过域名"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "仅在启用系统代理时生效",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "缓存已损坏，是否清除？",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancelFilterSystemApp": MessageLookupByLibrary.simpleMessage(
      "取消过滤系统应用程序",
    ),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "取消全选",
    ),
    "checkError": MessageLookupByLibrary.simpleMessage("检查错误"),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("检查更新"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "当前应用程序已是最新版本",
    ),
    "checking": MessageLookupByLibrary.simpleMessage("检查中…"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("导出至剪贴板"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("从剪贴板导入"),
    "columns": MessageLookupByLibrary.simpleMessage("列"),
    "compatible": MessageLookupByLibrary.simpleMessage("兼容模式"),
    "compatibleDesc": MessageLookupByLibrary.simpleMessage(
      "启用后将牺牲部分应用程序功能，以换取对 Clash 的完整支持",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("确认"),
    "connections": MessageLookupByLibrary.simpleMessage("连接"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "查看当前连接信息",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("连接状态："),
    "copy": MessageLookupByLibrary.simpleMessage("复制"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "复制环境变量",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("复制链接"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("复制成功"),
    "core": MessageLookupByLibrary.simpleMessage("核心"),
    "coreInfo": MessageLookupByLibrary.simpleMessage("核心信息"),
    "country": MessageLookupByLibrary.simpleMessage("国家/地区"),
    "create": MessageLookupByLibrary.simpleMessage("创建"),
    "cut": MessageLookupByLibrary.simpleMessage("剪切"),
    "dark": MessageLookupByLibrary.simpleMessage("深色"),
    "dashboard": MessageLookupByLibrary.simpleMessage("仪表盘"),
    "days": MessageLookupByLibrary.simpleMessage("天"),
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "默认名称服务器",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "用于解析 DNS 的服务器",
    ),
    "defaultSort": MessageLookupByLibrary.simpleMessage("默认排序"),
    "defaultText": MessageLookupByLibrary.simpleMessage("默认"),
    "delay": MessageLookupByLibrary.simpleMessage("延迟"),
    "delaySort": MessageLookupByLibrary.simpleMessage("按延迟排序"),
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "deleteProfileTip": MessageLookupByLibrary.simpleMessage(
      "确定要删除当前配置文件吗？",
    ),
    "desc": MessageLookupByLibrary.simpleMessage(
      "基于 ClashMeta 的多平台代理客户端，简单易用、开源且无广告",
    ),
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "依赖第三方 API，结果仅供参考",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("直接连接"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("免责声明"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "本软件仅限于学习交流及科学研究等非商业用途，严禁用于商业目的。任何商业行为（如有）与本软件无关",
    ),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "发现新版本",
    ),
    "discovery": MessageLookupByLibrary.simpleMessage(
      "发现新版本",
    ),
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "更新 DNS 相关设置",
    ),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS 模式"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage(
      "您确定要通过吗？",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("域名"),
    "download": MessageLookupByLibrary.simpleMessage("下载"),
    "edit": MessageLookupByLibrary.simpleMessage("编辑"),
    "en": MessageLookupByLibrary.simpleMessage("英文"),
    "entries": MessageLookupByLibrary.simpleMessage("条目"),
    "exclude": MessageLookupByLibrary.simpleMessage("从最近任务中隐藏"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "在应用程序运行于后台时，从最近任务列表中隐藏",
    ),
    "exit": MessageLookupByLibrary.simpleMessage("退出"),
    "expand": MessageLookupByLibrary.simpleMessage("标准"),
    "expirationTime": MessageLookupByLibrary.simpleMessage("到期时间"),
    "exportFile": MessageLookupByLibrary.simpleMessage("导出文件"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("导出日志"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("导出成功"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "外部控制器",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "启用后，可通过 9090 端口控制 Clash 核心",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("外部链接"),
    "externalResources": MessageLookupByLibrary.simpleMessage(
      "外部资源",
    ),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("虚拟 IP 过滤"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("虚拟 IP 范围"),
    "fallback": MessageLookupByLibrary.simpleMessage("备用"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "通常使用海外 DNS 服务器",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("备用过滤"),
    "file": MessageLookupByLibrary.simpleMessage("文件"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("直接上传配置文件"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "文件已变更，是否保存修改？",
    ),
    "filterSystemApp": MessageLookupByLibrary.simpleMessage(
      "过滤系统应用程序",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("查找进程模式"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "启用后可能有程序闪退风险",
    ),
    "fontFamily": MessageLookupByLibrary.simpleMessage("字体家族"),
    "fourColumns": MessageLookupByLibrary.simpleMessage("四列"),
    "general": MessageLookupByLibrary.simpleMessage("常规"),
    "generalDesc": MessageLookupByLibrary.simpleMessage(
      "管理常规设置",
    ),
    "geoData": MessageLookupByLibrary.simpleMessage("地理数据"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "地理数据低内存模式",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "启用后将采用低内存地理数据加载器",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("地理 IP 代码"),
    "global": MessageLookupByLibrary.simpleMessage("全局"),
    "go": MessageLookupByLibrary.simpleMessage("前往"),
    "goDownload": MessageLookupByLibrary.simpleMessage("前往下载"),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "是否保存缓存变更？",
    ),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("新增主机设置"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("快捷键冲突"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "快捷键管理",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "使用键盘快捷键控制应用程序",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("小时"),
    "icon": MessageLookupByLibrary.simpleMessage("图标"),
    "iconConfiguration": MessageLookupByLibrary.simpleMessage(
      "图标设置",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("图标样式"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("从 URL 导入"),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("无限期有效"),
    "init": MessageLookupByLibrary.simpleMessage("初始化"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "请输入有效的快捷键",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "智能选择",
    ),
    "intranetIP": MessageLookupByLibrary.simpleMessage("内网 IP"),
    "ipcidr": MessageLookupByLibrary.simpleMessage("IPCIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "启用后可接收 IPv6 流量",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "允许 IPv6 入站流量",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("日文"),
    "just": MessageLookupByLibrary.simpleMessage("刚刚"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP 保持连接间隔",
    ),
    "key": MessageLookupByLibrary.simpleMessage("键值"),
    "ko": MessageLookupByLibrary.simpleMessage("韩文"),
    "fr": MessageLookupByLibrary.simpleMessage("法文"),
    "de": MessageLookupByLibrary.simpleMessage("德文"),
    "ar": MessageLookupByLibrary.simpleMessage("阿拉伯文"),
    "fa": MessageLookupByLibrary.simpleMessage("波斯文"),
    "language": MessageLookupByLibrary.simpleMessage("语言"),
    "layout": MessageLookupByLibrary.simpleMessage("布局"),
    "light": MessageLookupByLibrary.simpleMessage("浅色"),
    "list": MessageLookupByLibrary.simpleMessage("列表"),
    "listen": MessageLookupByLibrary.simpleMessage("监听"),
    "local": MessageLookupByLibrary.simpleMessage("本地"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "将数据备份至本地",
    ),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "从本地文件恢复数据",
    ),
    "logLevel": MessageLookupByLibrary.simpleMessage("日志级别"),
    "logcat": MessageLookupByLibrary.simpleMessage("日志捕获"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "禁用后将隐藏日志内容",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("日志"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("查看日志记录"),
    "loopback": MessageLookupByLibrary.simpleMessage("回环解锁工具"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "用于解锁 UWP 回环限制",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("宽松"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("内存信息"),
    "min": MessageLookupByLibrary.simpleMessage("分"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("退出时最小化"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "更改默认退出行为为最小化",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("分钟"),
    "mode": MessageLookupByLibrary.simpleMessage("模式"),
    "months": MessageLookupByLibrary.simpleMessage("个月"),
    "more": MessageLookupByLibrary.simpleMessage("更多"),
    "name": MessageLookupByLibrary.simpleMessage("名称"),
    "nameSort": MessageLookupByLibrary.simpleMessage("按名称排序"),
    "nameserver": MessageLookupByLibrary.simpleMessage("名称服务器"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "用于解析域名的服务器",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "名称服务器策略",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "指定对应的名称服务器策略",
    ),
    "network": MessageLookupByLibrary.simpleMessage("网络"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "调整网络相关设置",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage(
      "网络检测",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("网络速度"),
    "noData": MessageLookupByLibrary.simpleMessage("无数据"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("无快捷键"),
    "noIcon": MessageLookupByLibrary.simpleMessage("无图标"),
    "noInfo": MessageLookupByLibrary.simpleMessage("无信息"),
    "noMoreInfoDesc": MessageLookupByLibrary.simpleMessage("无更多信息"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("无网络连接"),
    "noProxy": MessageLookupByLibrary.simpleMessage("无代理"),
    "noProxyDesc": MessageLookupByLibrary.simpleMessage(
      "请创建配置文件或新增有效的配置文件",
    ),
    "notEmpty": MessageLookupByLibrary.simpleMessage("不得为空"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "当前代理组无法选择",
    ),
    "nullConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "无连接",
    ),
    "nullCoreInfoDesc": MessageLookupByLibrary.simpleMessage(
      "无法获取核心信息",
    ),
    "nullLogsDesc": MessageLookupByLibrary.simpleMessage("无日志记录"),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "无配置文件，请新增配置文件",
    ),
    "nullProxies": MessageLookupByLibrary.simpleMessage("无代理"),
    "nullRequestsDesc": MessageLookupByLibrary.simpleMessage("无请求记录"),
    "oneColumn": MessageLookupByLibrary.simpleMessage("单列"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("仅图标"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage(
      "仅第三方应用程序",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "仅统计代理流量",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "启用后仅记录代理相关流量",
    ),
    "options": MessageLookupByLibrary.simpleMessage("选项"),
    "other": MessageLookupByLibrary.simpleMessage("其他"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "其他贡献者",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("出站模式"),
    "override": MessageLookupByLibrary.simpleMessage("覆盖"),
    "overrideDesc": MessageLookupByLibrary.simpleMessage(
      "覆盖代理相关设置",
    ),
    "overrideDns": MessageLookupByLibrary.simpleMessage("覆盖 DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "启用后将覆盖配置文件中的 DNS 设置",
    ),
    "password": MessageLookupByLibrary.simpleMessage("密码"),
    "passwordTip": MessageLookupByLibrary.simpleMessage(
      "密码字段不得为空",
    ),
    "paste": MessageLookupByLibrary.simpleMessage("粘贴"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "请绑定 WebDAV",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "请输入管理员密码",
    ),
    "pleaseUploadFile": MessageLookupByLibrary.simpleMessage(
      "请上传文件",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "请上传有效的 QR Code",
    ),
    "port": MessageLookupByLibrary.simpleMessage("端口"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "优先使用 HTTP/3 的 DOH",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "请按下键盘按键",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("预览"),
    "profile": MessageLookupByLibrary.simpleMessage("配置文件"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "请输入有效的间隔时间格式",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "请输入自动更新间隔时间",
        ),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "配置文件已变更，是否禁用自动更新？",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "请输入配置文件名称",
    ),
    "profileParseErrorDesc": MessageLookupByLibrary.simpleMessage(
      "配置文件解析失败",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "请输入有效的配置文件 URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "请输入配置文件 URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("配置文件"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("配置文件排序"),
    "project": MessageLookupByLibrary.simpleMessage("项目"),
    "providers": MessageLookupByLibrary.simpleMessage("提供者"),
    "proxies": MessageLookupByLibrary.simpleMessage("代理"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("代理设置"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("代理组"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("代理名称服务器"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "用于解析代理节点域名的服务器",
    ),
    "proxyPort": MessageLookupByLibrary.simpleMessage("代理端口"),
    "proxyPortDesc": MessageLookupByLibrary.simpleMessage(
      "设置 Clash 的监听端口",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("代理提供者"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("纯黑模式"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR Code"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "扫描 QR Code 以导入配置文件",
    ),
    "recovery": MessageLookupByLibrary.simpleMessage("恢复"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("恢复所有数据"),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage(
      "仅恢复配置文件",
    ),
    "recoverySuccess": MessageLookupByLibrary.simpleMessage("恢复成功"),
    "regExp": MessageLookupByLibrary.simpleMessage("正则表达式"),
    "remote": MessageLookupByLibrary.simpleMessage("远程"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "将数据备份至 WebDAV",
    ),
    "remoteRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "从 WebDAV 恢复数据",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("移除"),
    "requests": MessageLookupByLibrary.simpleMessage("请求"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "查看近期请求记录",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("重置"),
    "resetTip": MessageLookupByLibrary.simpleMessage("确定要重置吗？"),
    "resources": MessageLookupByLibrary.simpleMessage("资源"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "外部资源相关信息",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("遵循规则"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS 连接遵循规则，需设置代理与名称服务器",
    ),
    "routeAddress": MessageLookupByLibrary.simpleMessage("路由地址"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "设置监听的路由地址",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("路由模式"),
    "routeMode_bypassPrivate": MessageLookupByLibrary.simpleMessage(
      "绕过私有路由地址",
    ),
    "routeMode_config": MessageLookupByLibrary.simpleMessage("使用配置文件"),
    "ru": MessageLookupByLibrary.simpleMessage("俄文"),
    "rule": MessageLookupByLibrary.simpleMessage("规则"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("规则提供者"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "search": MessageLookupByLibrary.simpleMessage("搜索"),
    "seconds": MessageLookupByLibrary.simpleMessage("秒"),
    "selectAll": MessageLookupByLibrary.simpleMessage("全选"),
    "selected": MessageLookupByLibrary.simpleMessage("已选中"),
    "settings": MessageLookupByLibrary.simpleMessage("设置"),
    "show": MessageLookupByLibrary.simpleMessage("显示"),
    "shrink": MessageLookupByLibrary.simpleMessage("缩减"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("静默启动"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "于后台中启动应用程序",
    ),
    "size": MessageLookupByLibrary.simpleMessage("大小"),
    "sort": MessageLookupByLibrary.simpleMessage("排序"),
    "source": MessageLookupByLibrary.simpleMessage("来源"),
    "stackMode": MessageLookupByLibrary.simpleMessage("堆叠模式"),
    "standard": MessageLookupByLibrary.simpleMessage("标准"),
    "start": MessageLookupByLibrary.simpleMessage("启动"),
    "startVpn": MessageLookupByLibrary.simpleMessage("正在启动 VPN…"),
    "status": MessageLookupByLibrary.simpleMessage("状态"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "关闭时将使用系统 DNS",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("停止"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("正在停止 VPN…"),
    "style": MessageLookupByLibrary.simpleMessage("样式"),
    "submit": MessageLookupByLibrary.simpleMessage("提交"),
    "sync": MessageLookupByLibrary.simpleMessage("同步"),
    "system": MessageLookupByLibrary.simpleMessage("系统"),
    "systemFont": MessageLookupByLibrary.simpleMessage("系统字体"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("系统代理"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "将 HTTP 代理附加至 VpnService",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("标签"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("标签动画"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "启用后，首页标签切换将显示动画效果",
    ),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP 并行"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "启用后允许 TCP 并行传输",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("测试 URL"),
    "theme": MessageLookupByLibrary.simpleMessage("主题"),
    "themeColor": MessageLookupByLibrary.simpleMessage("主题色彩"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "设置深色模式或调整色彩",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("主题模式"),
    "threeColumns": MessageLookupByLibrary.simpleMessage("三列"),
    "tight": MessageLookupByLibrary.simpleMessage("紧凑"),
    "time": MessageLookupByLibrary.simpleMessage("时间"),
    "tip": MessageLookupByLibrary.simpleMessage("提示"),
    "toggle": MessageLookupByLibrary.simpleMessage("切换"),
    "tools": MessageLookupByLibrary.simpleMessage("工具"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("流量使用情况"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "仅在管理员模式下生效",
    ),
    "twoColumns": MessageLookupByLibrary.simpleMessage("双列"),
    "unableToUpdateCurrentProfileDesc": MessageLookupByLibrary.simpleMessage(
      "无法更新当前配置文件",
    ),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("统一延迟"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "移除握手等额外延迟时间",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("未知"),
    "update": MessageLookupByLibrary.simpleMessage("更新"),
    "upload": MessageLookupByLibrary.simpleMessage("上传"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "通过 URL 获取配置文件",
    ),
    "useHosts": MessageLookupByLibrary.simpleMessage("使用主机设置"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("使用系统主机"),
    "value": MessageLookupByLibrary.simpleMessage("值"),
    "view": MessageLookupByLibrary.simpleMessage("查看"),
    "vpnDesc": MessageLookupByLibrary.simpleMessage(
      "调整 VPN 相关设置",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "启用后，所有系统流量将自动通过 VpnService 路由",
    ),
    "vpnSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "将 HTTP 代理整合至 VpnService",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "重启 VPN 后设置生效",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV 设置",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("白名单模式"),
    "years": MessageLookupByLibrary.simpleMessage("年"),
    "zh_CN": MessageLookupByLibrary.simpleMessage("简体中文"),
    "zh_TW": MessageLookupByLibrary.simpleMessage("繁体中文"),
  };
}
