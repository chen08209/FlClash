// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get rule => '规则';

  @override
  String get rules => '规则';

  @override
  String get global => '全局';

  @override
  String get direct => '直连';

  @override
  String get dashboard => '仪表盘';

  @override
  String get proxies => '代理';

  @override
  String get profile => '配置';

  @override
  String get profiles => '配置';

  @override
  String get tools => '工具';

  @override
  String get logs => '日志';

  @override
  String get resources => '资源';

  @override
  String get trafficUsage => '流量统计';

  @override
  String get networkSpeed => '网络速度';

  @override
  String get outboundMode => '出站模式';

  @override
  String get noProfileDirect => '未使用配置，全部直连';

  @override
  String get serviceStatus => '服务状态';

  @override
  String get serviceRestricted => '访问受限';

  @override
  String get serviceAvailable => '可用';

  @override
  String get serviceUnavailable => '不可用';

  @override
  String get serviceFailed => '检测失败';

  @override
  String get serviceDisallowedIsp => '不允许的 ISP';

  @override
  String get serviceBlocked => '已被封禁';

  @override
  String get serviceUnsupportedRegion => '地区不支持';

  @override
  String get serviceOriginalsOnly => '仅限自制内容';

  @override
  String get serviceComingSoon => '即将上线';

  @override
  String get servicePending => '待检测';

  @override
  String get serviceManage => '管理服务';

  @override
  String get serviceCheckAll => '全部检测';

  @override
  String get upload => '上传';

  @override
  String get download => '下载';

  @override
  String get usedTraffic => '已用流量';

  @override
  String get totalTraffic => '总流量';

  @override
  String get expireTime => '到期时间';

  @override
  String get nullProfileDesc => '添加一个配置文件后即可开始使用';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get defaultText => '默认';

  @override
  String get more => '更多';

  @override
  String get other => '其他';

  @override
  String get about => '关于';

  @override
  String get en => '英语';

  @override
  String get es => '西班牙语';

  @override
  String get fr => '法语';

  @override
  String get ja => '日语';

  @override
  String get ko => '韩语';

  @override
  String get ru => '俄语';

  @override
  String get zhCN => '中文简体';

  @override
  String get theme => '主题';

  @override
  String get extend => '扩展';

  @override
  String get runtimeConfig => '运行时配置';

  @override
  String get allowLan => '局域网代理';

  @override
  String get tun => '虚拟网卡';

  @override
  String get tunDesc => '虚拟网卡仅在管理员模式生效。';

  @override
  String get minimizeOnExit => '退出时最小化';

  @override
  String get autoLaunch => '自启动';

  @override
  String get silentLaunch => '静默启动';

  @override
  String get autoRun => '自动运行';

  @override
  String get autoRunDesc => '自动运行会在打开应用时启动代理。';

  @override
  String get logcat => '日志捕获';

  @override
  String get logcatDesc => '关闭日志捕获会隐藏日志入口。';

  @override
  String get autoCheckUpdate => '自动检查更新';

  @override
  String get updateChannel => '更新渠道';

  @override
  String get updateChannelStable => '正式版';

  @override
  String get updateChannelPre => '预览版';

  @override
  String get checkCertificate => '校验 TLS 证书';

  @override
  String get checkCertificateDesc => '关闭证书校验后，订阅和备份可能遭中间人攻击。';

  @override
  String get accessControl => '访问控制';

  @override
  String get edit => '编辑';

  @override
  String get confirm => '确定';

  @override
  String get update => '更新';

  @override
  String get add => '添加';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get seconds => '秒';

  @override
  String get qrcode => '二维码';

  @override
  String get qrcodeDesc => '扫描二维码获取配置文件';

  @override
  String get url => 'URL';

  @override
  String get link => '链接';

  @override
  String get file => '文件';

  @override
  String get name => '名称';

  @override
  String get profileNameNullValidationDesc => '请输入配置名称';

  @override
  String get rename => '重命名';

  @override
  String get profileUrlNullValidationDesc => '请输入配置URL';

  @override
  String get profileUrlInvalidValidationDesc => '请输入有效配置URL';

  @override
  String get autoUpdate => '自动更新';

  @override
  String get autoUpdateInterval => '自动更新间隔';

  @override
  String get profileAutoUpdateIntervalNullValidationDesc => '请输入自动更新间隔时间';

  @override
  String get profileAutoUpdateIntervalInvalidValidationDesc => '请输入有效间隔时间格式';

  @override
  String get themeMode => '主题模式';

  @override
  String get themeColor => '主题色彩';

  @override
  String get preview => '预览';

  @override
  String get auto => '自动';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get importFromLink => '从链接导入';

  @override
  String get sendFromPhone => '从手机发送';

  @override
  String get sendFromPhoneTip => '用手机相机扫描二维码，在打开的页面里粘贴链接。两台设备需要连在同一个网络。';

  @override
  String get sendFromPhoneNoNetwork => '这台设备没有连接局域网';

  @override
  String get sendFromPhonePermissionDenied =>
      '从手机接收链接需要「附近的设备」权限，FlClash 才能访问局域网。请在应用设置中开启。';

  @override
  String get sendFromPhonePageTitle => '把链接发送到 FlClash';

  @override
  String get sendFromPhonePageHint => '订阅链接或代理分享链接';

  @override
  String get send => '发送';

  @override
  String get sendFromPhonePageSent => '已发送，请在另一台设备上确认导入。';

  @override
  String get sendFromPhoneConfirmTitle => '导入手机发来的链接？';

  @override
  String get shareQrcodeTip => '在另一台设备上用 FlClash 扫码即可导入此配置。';

  @override
  String get qrcodeTooLongTip => '链接过长，无法生成二维码，请改用“复制链接”。';

  @override
  String get submit => '提交';

  @override
  String createProfileFromUrlTip(Object url) {
    return '是否要通过 $url 创建配置？';
  }

  @override
  String get create => '创建';

  @override
  String get pleaseUploadValidQrcode => '请上传有效的二维码';

  @override
  String get blacklistMode => '黑名单模式';

  @override
  String get whitelistMode => '白名单模式';

  @override
  String get selectAll => '全选';

  @override
  String get cancelSelectAll => '取消全选';

  @override
  String get appAccessControl => '应用访问控制';

  @override
  String get accessControlAllowDesc => '只允许选中应用进入VPN';

  @override
  String get accessControlNotAllowDesc => '选中应用将会被排除在VPN之外';

  @override
  String get accessControlDisabledDesc => '应用访问控制已关闭';

  @override
  String accessControlSelectedCount(num count) {
    return '已选 $count';
  }

  @override
  String get port => '端口';

  @override
  String get logLevel => '日志等级';

  @override
  String get show => '显示';

  @override
  String get exit => '退出';

  @override
  String get systemProxy => '系统代理';

  @override
  String get safeMode => '安全模式';

  @override
  String safeModeAppTitle(Object appName) {
    return '$appName（安全模式）';
  }

  @override
  String get project => '项目';

  @override
  String get core => '内核';

  @override
  String get tabAnimation => '选项卡动画';

  @override
  String get desc => '基于 Concord 内核的多平台代理客户端，简单易用，开源无广告。';

  @override
  String get startVpn => '正在启动VPN…';

  @override
  String get stopVpn => '正在停止VPN…';

  @override
  String get compatible => '兼容模式';

  @override
  String get notSelectedTip => '当前代理组无法选中';

  @override
  String get changeProxyFailedTip => '切换代理失败，已恢复上一次的选择';

  @override
  String get databaseWriteFailedTip => '保存更改失败，已回滚';

  @override
  String get tip => '提示';

  @override
  String get account => '账号';

  @override
  String get backup => '备份';

  @override
  String get backupSuccess => '备份成功';

  @override
  String get noInfo => '暂无信息';

  @override
  String get pleaseBindWebDAV => '请绑定WebDAV';

  @override
  String get bind => '绑定';

  @override
  String get connectivity => '连通性：';

  @override
  String get webDAVConfiguration => 'WebDAV配置';

  @override
  String get address => '地址';

  @override
  String get addressTip => '请输入有效的WebDAV地址';

  @override
  String get password => '密码';

  @override
  String get authentication => '认证';

  @override
  String get authenticationSystemProxyDesc => '认证启用时，系统代理不生效。';

  @override
  String get checkUpdate => '检查更新';

  @override
  String get discoverNewVersion => '发现新版本';

  @override
  String get checkUpdateError => '当前应用已经是最新版了';

  @override
  String get goDownload => '前往下载';

  @override
  String get unknown => '未知';

  @override
  String get country => '区域';

  @override
  String get search => '搜索';

  @override
  String get allowBypass => '允许应用绕过VPN';

  @override
  String get externalController => '外部控制器';

  @override
  String get externalControllerDesc => '外部控制器监听 9090 端口。';

  @override
  String get externalControllerSecret => '外部控制器密钥';

  @override
  String get externalControllerCors => '允许跨域访问';

  @override
  String get externalControllerCorsDesc => '允许网页面板从其他网址连接。';

  @override
  String get ipv6Desc => '开启 IPv6 后才会接收 IPv6 流量。';

  @override
  String get app => '应用';

  @override
  String get general => '常规';

  @override
  String get startupAndBackground => '启动与后台';

  @override
  String get logsAndDiagnostics => '日志与诊断';

  @override
  String get userAgent => '用户代理';

  @override
  String get unifiedDelay => '统一延迟';

  @override
  String get tcpConcurrent => 'TCP并发';

  @override
  String get requests => '请求';

  @override
  String get recentRequests => '最近请求';

  @override
  String get alwaysFindProcess => '始终查找进程';

  @override
  String get init => '初始化';

  @override
  String get infiniteTime => '长期有效';

  @override
  String get connections => '连接';

  @override
  String get liveConnections => '实时连接';

  @override
  String get speed => '速度';

  @override
  String get closeActiveConnections => '关闭全部活动连接';

  @override
  String closeActiveConnectionsTip(int count) {
    return '关闭全部 $count 条活动连接？正在使用它们的应用会自行重连，进行中的下载或通话可能中断。';
  }

  @override
  String get connectionsAll => '全部';

  @override
  String get connectionsActive => '活动';

  @override
  String get connectionsFailed => '失败';

  @override
  String get connectionsDecrypted => '已解密';

  @override
  String get connectionRuleGlobal => '全局模式';

  @override
  String get connectionRuleNone => '未经规则';

  @override
  String get failureRefused => '连接被拒绝';

  @override
  String get failureUnreachable => '不可达';

  @override
  String get failureDns => 'DNS 解析失败';

  @override
  String get dnsNoSuchDomain => '域名不存在';

  @override
  String get dnsServerFailure => '上游出错';

  @override
  String get dnsRefused => '上游拒绝了查询';

  @override
  String get dnsTimedOut => '查询超时';

  @override
  String get dnsBlockedByRule => '被规则拦截';

  @override
  String get failureHandshake => '握手失败';

  @override
  String get failureOther => '其他错误';

  @override
  String get connectionClosed => '已关闭';

  @override
  String get timeline => '时间线';

  @override
  String get connectionInfo => '信息';

  @override
  String get decryption => '解密';

  @override
  String connectionRuleIndex(Object number) {
    return '第 $number 条';
  }

  @override
  String get handshake => '握手';

  @override
  String get now => '现在';

  @override
  String get mitmCertificateRefused => '客户端拒绝了证书';

  @override
  String get connectionEndLocal => '本地关闭';

  @override
  String get connectionEndRemote => '对端关闭';

  @override
  String get connectionEndFinished => '已结束';

  @override
  String get connectionEndReset => '被重置';

  @override
  String get connectionEndCore => '被核心关闭';

  @override
  String get fakeIpMapping => 'fake-ip 映射';

  @override
  String get dnsFromHosts => '来自 hosts';

  @override
  String get condition => '条件';

  @override
  String get addCondition => '添加条件';

  @override
  String get conditionField => '字段';

  @override
  String get conditionContains => '包含';

  @override
  String get conditionEquals => '等于';

  @override
  String get conditionTip =>
      '同一字段的条件满足其一即可，不同字段的都要满足。搜索框里也能这样写：host:github.com -app:slack';

  @override
  String get conditionNotContains => '不包含';

  @override
  String get conditionNotEquals => '不等于';

  @override
  String get editCondition => '编辑条件';

  @override
  String conditionValuesIn(String field) {
    return '当前连接里的$field';
  }

  @override
  String conditionShows(String count) {
    return '将筛出 $count 条连接';
  }

  @override
  String get conditionRows => '同一行满足其一，各行都要满足';

  @override
  String get clearAll => '清除全部';

  @override
  String get conditionOr => '或';

  @override
  String get selectConnection => '选择一条连接';

  @override
  String get selectConnectionHint => '这里会显示它的时间线、HTTP 请求和连接信息';

  @override
  String get selectDnsQuery => '选择一次查询';

  @override
  String get selectDnsQueryHint => '这里会显示它的应答、上游，以及相关的连接';

  @override
  String get relatedConnections => '相关的连接';

  @override
  String get upstream => '上游';

  @override
  String get dnsQueryFields => '查询';

  @override
  String dnsQueryAskedBy(String initiator) {
    return '$initiator发起';
  }

  @override
  String get dnsConditionTip => '同一字段的条件满足其一即可，不同字段的都要满足。';

  @override
  String dnsConditionValuesIn(String field) {
    return '当前查询里的$field';
  }

  @override
  String dnsConditionShows(String count) {
    return '将筛出 $count 次查询';
  }

  @override
  String get connectionPath => '链路';

  @override
  String get processPath => '进程路径';

  @override
  String get proxyNode => '节点';

  @override
  String get closingTime => '关闭时间';

  @override
  String processUid(int uid) {
    return 'UID $uid';
  }

  @override
  String get onlyThisApp => '只看此应用';

  @override
  String get onlyThisDomain => '只看此域名';

  @override
  String get hideThisHost => '隐藏此主机';

  @override
  String get copySummary => '复制摘要';

  @override
  String get copyDomain => '复制域名';

  @override
  String get copyAnswers => '复制应答';

  @override
  String get viewHttp => '查看 HTTP';

  @override
  String get inbound => '入站';

  @override
  String get intranetIP => '内网 IP';

  @override
  String get view => '查看';

  @override
  String get cut => '剪切';

  @override
  String get copy => '复制';

  @override
  String get clipboardWriteFailed => '无法复制到剪贴板，所选内容可能过大';

  @override
  String get paste => '粘贴';

  @override
  String get testUrl => '测速链接';

  @override
  String get delayTestTimeout => '延迟测试超时';

  @override
  String get sync => '同步';

  @override
  String get exclude => '从最近任务中隐藏';

  @override
  String get compact => '紧凑';

  @override
  String get tab => '标签页';

  @override
  String get list => '列表';

  @override
  String get delay => '延迟';

  @override
  String get style => '风格';

  @override
  String get size => '尺寸';

  @override
  String get sort => '排序';

  @override
  String get columns => '列数';

  @override
  String get proxyGroup => '策略组';

  @override
  String get go => '前往';

  @override
  String get externalLink => '外部链接';

  @override
  String get otherContributors => '其他贡献者';

  @override
  String get appIconDesign => '应用图标设计';

  @override
  String get autoCloseConnections => '自动关闭连接';

  @override
  String get onlyStatisticsProxy => '仅统计代理流量';

  @override
  String get showNotificationStopAction => '通知栏显示停止按钮';

  @override
  String get pureBlackMode => '纯黑模式';

  @override
  String get sidebar => '侧边栏';

  @override
  String get backgroundBlur => '背景模糊';

  @override
  String get liquidGlass => '液态玻璃';

  @override
  String get keepAliveIntervalDesc => 'TCP保持活动间隔';

  @override
  String get entries => '个条目';

  @override
  String get local => '本地';

  @override
  String get remote => '远程';

  @override
  String get mode => '模式';

  @override
  String get time => '时间';

  @override
  String get source => '来源';

  @override
  String get action => '操作';

  @override
  String get intelligentSelected => '智能选择';

  @override
  String get clipboardImport => '剪贴板导入';

  @override
  String get clipboardNoPackageNames => '剪贴板中没有有效的包名';

  @override
  String get clipboardExport => '导出剪贴板';

  @override
  String get layout => '布局';

  @override
  String get tight => '紧凑';

  @override
  String get standard => '标准';

  @override
  String get ultra => '极致';

  @override
  String get loose => '宽松';

  @override
  String get profilesSort => '配置排序';

  @override
  String get start => '启动';

  @override
  String get runTime => '运行时长';

  @override
  String get stop => '暂停';

  @override
  String get key => '键';

  @override
  String get value => '值';

  @override
  String get options => '选项';

  @override
  String get enabled => '已开启';

  @override
  String get disabled => '已关闭';

  @override
  String get loopback => 'UWP 回环解锁';

  @override
  String get providers => '外部资源';

  @override
  String get proxyProviders => '代理集';

  @override
  String get ruleProviders => '规则集';

  @override
  String get providerUrlTip => '仅支持远程资源';

  @override
  String get ruleSetEmptyTip => '规则集中没有可用的条目';

  @override
  String get ruleSetMixedTip => '规则集同时包含域名和 IP 段，无法判断类型';

  @override
  String get ruleSetInvalidTip => '无法读取该 mrs 文件';

  @override
  String get subscriptionInfo => '订阅信息';

  @override
  String get server => '服务器';

  @override
  String get ntpInterval => '同步间隔（分钟）';

  @override
  String get dialerProxy => '拨号代理';

  @override
  String get writeToSystem => '写入系统';

  @override
  String get writeToSystemDesc => '写入系统在 Android 上不生效。';

  @override
  String get sniffer => '域名嗅探';

  @override
  String get overrideDestination => '覆盖目标地址';

  @override
  String get forceDnsMapping => '强制DNS映射';

  @override
  String get parsePureIp => '解析纯IP';

  @override
  String get forceDomain => '强制嗅探域名';

  @override
  String get forceDomainDesc => '强制嗅探域名中的域名同样会被嗅探，其余已有域名的连接不嗅探。';

  @override
  String get skipDomain => '跳过域名';

  @override
  String get skipSrcAddress => '跳过来源地址';

  @override
  String get skipDstAddress => '跳过目标地址';

  @override
  String get sniffProtocols => '协议';

  @override
  String get ports => '端口';

  @override
  String get overrideEntries => '覆写项';

  @override
  String get addOverrideEntry => '添加覆写项';

  @override
  String get dnsOverrideDesc => '添加的项覆写 URL 和文件配置的 DNS。';

  @override
  String get settingEntries => '设置项';

  @override
  String get addSettingEntry => '添加设置项';

  @override
  String get profileSettingsDesc => '仅作用于当前配置，未添加的项使用默认值。';

  @override
  String get healthCheck => '健康检查';

  @override
  String get discardChanges => '是否放弃更改？';

  @override
  String get quickEdit => '快速编辑';

  @override
  String get status => '状态';

  @override
  String get statusDesc => '关闭 DNS 后将使用系统 DNS。';

  @override
  String get respectRules => '遵守规则';

  @override
  String get respectRulesDesc => '遵守规则需配置 Proxy Server Nameserver。';

  @override
  String get dnsMode => 'DNS模式';

  @override
  String get fakeipRange => 'Fake-IP范围';

  @override
  String get fakeipFilter => 'Fake-IP过滤';

  @override
  String get useHosts => '使用Hosts';

  @override
  String get useSystemHosts => '使用系统Hosts';

  @override
  String get fallbackFilter => 'Fallback过滤';

  @override
  String get domain => '域名';

  @override
  String get listenRoutingMark => '监听路由标记';

  @override
  String get listenRoutingMarkDesc => '监听路由标记仅在 Linux 生效。';

  @override
  String get ipv6Timeout => 'IPv6超时（毫秒）';

  @override
  String get cacheAlgorithm => '缓存算法';

  @override
  String get cacheMaxSize => '缓存大小';

  @override
  String get fakeipRange6 => 'Fake-IP范围（IPv6）';

  @override
  String get fakeipFilterMode => 'Fake-IP过滤模式';

  @override
  String get fakeipTtl => 'Fake-IP TTL';

  @override
  String get reset => '重置';

  @override
  String get actionView => '显示/隐藏';

  @override
  String get actionStart => '启动/停止';

  @override
  String get actionMode => '切换模式';

  @override
  String get actionProxy => '系统代理';

  @override
  String get actionTun => '虚拟网卡';

  @override
  String get actionRuleMode => '规则模式';

  @override
  String get actionGlobalMode => '全局模式';

  @override
  String get actionDirectMode => '直连模式';

  @override
  String get actionDelayTest => '测试全部延迟';

  @override
  String get actionUpdateProfiles => '更新全部配置';

  @override
  String get disclaimer => '免责声明';

  @override
  String get disclaimerDesc =>
      '在使用 FlClash（以下简称“本软件”）前，请仔细阅读并充分理解本声明。点击“同意”表示你已阅读并理解以下内容；如不想继续，可点击“退出”。';

  @override
  String get disclaimerSoftwareTitle => '软件性质';

  @override
  String get disclaimerSoftwareContent =>
      '本软件是基于 Concord 内核的开源网络代理客户端，仅提供配置管理、规则分流与流量转发等本地工具功能。';

  @override
  String get disclaimerNoServiceStatement =>
      '本软件自身不提供任何代理服务器、节点、订阅、机场或网络接入服务，也不与任何此类服务的提供者存在合作、代理或担保关系。';

  @override
  String get disclaimerUsageTitle => '使用说明';

  @override
  String get disclaimerUsageContent =>
      '任何人基于本软件开展的商业活动，包括付费分发、捆绑销售或作为商业服务的组成部分，均与本软件的开发者无关，开发者不为其提供背书、支持或担保。\n\n你须自行遵守所在国家或地区的法律法规，因违法使用本软件产生的后果由你自行承担。';

  @override
  String get disclaimerResponsibilityTitle => '用户责任';

  @override
  String get disclaimerResponsibilityContent =>
      '你应自行确认使用本软件在你所在国家或地区是合法的，并对使用本软件的全部行为及其后果独立承担法律责任。\n\n你导入的订阅、节点与配置由你自行选择和判断，其来源是否合法、内容是否安全、服务是否稳定，均由你与相关提供者自行负责。';

  @override
  String get disclaimerThirdPartyTitle => '第三方内容';

  @override
  String get disclaimerThirdPartyContent =>
      '订阅链接、配置文件、规则集、脚本、外部资源及外部链接均由第三方提供，开发者无法也不会对其合法性、准确性、安全性和可用性进行审查或担保。\n\n因使用第三方内容导致的数据泄露、财产损失、账号封禁或其他任何损失，由你与第三方自行解决，开发者不承担任何责任。';

  @override
  String get disclaimerWarrantyTitle => '无担保声明';

  @override
  String get disclaimerWarrantyContent =>
      '本软件按“现状”和“可用”的原则提供，不附带任何明示或默示的担保，包括但不限于适销性、特定用途适用性、不侵权以及持续可用、无错误、无安全漏洞的担保。\n\n开发者不保证本软件能满足你的需求，也不保证本软件的运行不会中断或不会出现错误。';

  @override
  String get disclaimerLiabilityTitle => '责任限制';

  @override
  String get disclaimerLiabilityContent =>
      '在适用法律允许的最大范围内，开发者及所有贡献者均不对因使用或无法使用本软件而产生的任何直接、间接、偶然、特殊、惩罚性或后果性损害承担责任，包括但不限于数据丢失、设备损坏、网络异常、业务中断、利润损失或因此引起的任何法律纠纷，即使已被告知发生此类损害的可能性。';

  @override
  String get disclaimerPrivacyTitle => '数据收集与隐私';

  @override
  String get disclaimerPrivacyContent =>
      '本软件不会收集或上传你的订阅地址、节点信息、配置内容、访问的网站、连接记录、流量内容和日志，这些数据仅保存在你的设备本地，开发者无法获取。\n\n本软件只会在你使用相应功能时访问外部网络，例如更新订阅时访问你提供的订阅地址、检查更新时访问 GitHub。\n\n本软件在所有平台上均未集成任何数据统计或崩溃上报服务。';

  @override
  String get disclaimerLicenseTitle => '开源协议';

  @override
  String get disclaimerLicenseContent =>
      '本软件以 GPL-3.0 协议开源，你可以依该协议运行、研究、修改和分发本软件；分发本软件或其修改版本时，须同样以 GPL-3.0 协议提供源代码并保留原有的版权声明。\n\n本软件包含的第三方组件（包括 Concord 内核）分别遵循其各自的开源协议。基于本软件修改或分发的版本所产生的任何问题，与原作者无关。';

  @override
  String get disclaimerChangesTitle => '声明变更';

  @override
  String get disclaimerChangesContent => '本声明可能随版本更新而修订，以每个版本附带的内容为准。';

  @override
  String get disclaimerAcceptTitle => '与开源协议的关系';

  @override
  String get disclaimerAcceptContent =>
      '本声明是对软件性质、风险与责任的说明，不是 GPL-3.0 之外的附加条款，也不限制该协议授予你的运行、复制、修改和分发等任何权利；两者不一致时，以 GPL-3.0 为准。';

  @override
  String get disclaimerRestateTitle => '复述声明';

  @override
  String get disclaimerRestateTip => '为确认你已知悉，请在下方输入框中完整复述以下声明：';

  @override
  String get disclaimerRestateHint => '在此输入上述声明';

  @override
  String get disclaimerRestateMismatch => '与声明内容不一致';

  @override
  String get disclaimerAcknowledgeTitle => '确认声明';

  @override
  String get disclaimerAcknowledgeTip => '为确认你已知悉，请阅读以下声明并勾选下方选项：';

  @override
  String get disclaimerAcknowledgeLabel => '我已阅读并理解此声明';

  @override
  String get agree => '同意';

  @override
  String get hotkeyManagement => '快捷键管理';

  @override
  String get hotkeyDesc => '全局快捷键在窗口隐藏时依然生效，点击操作即可录制组合键。';

  @override
  String get hotkeyNotSet => '未设置';

  @override
  String get pressKeyboard => '请按下组合键';

  @override
  String hotkeyNeedsModifier(Object modifiers) {
    return '至少包含 $modifiers 中的一个';
  }

  @override
  String hotkeyConflictWith(Object action) {
    return '已被“$action”使用，保存后将移到这里';
  }

  @override
  String get hotkeyUnavailable => '未能注册，可能已被其他应用占用';

  @override
  String get remove => '移除';

  @override
  String get noNetwork => '无网络';

  @override
  String get exportLogs => '导出日志';

  @override
  String get exportSuccess => '导出成功';

  @override
  String get iconStyle => '图标样式';

  @override
  String get iconStyleFilled => '色块';

  @override
  String get iconStylePlain => '纯图标';

  @override
  String get iconStyleHidden => '隐藏';

  @override
  String get filter => '筛选';

  @override
  String get hideTimeoutProxies => '隐藏超时代理';

  @override
  String get network => '网络';

  @override
  String get bypassDomain => '排除域名';

  @override
  String get pacMode => 'PAC 模式';

  @override
  String get pacScript => 'PAC 脚本';

  @override
  String get bypassDomainDesc => '排除域名仅在系统代理启用时生效。';

  @override
  String get bypassLocalWindowsOnly => '仅 Windows：不带点的内网主机名';

  @override
  String get resetTip => '确定要重置吗？';

  @override
  String get icon => '图标';

  @override
  String get noData => '暂无数据';

  @override
  String get fontFamily => '字体';

  @override
  String get installedFonts => '已安装字体';

  @override
  String get toggle => '切换';

  @override
  String get system => '系统';

  @override
  String get routeAddress => '路由地址';

  @override
  String get interfaceNameMode => '出站网卡';

  @override
  String get interfaceNameModeClear => '清空';

  @override
  String get interfaceNameModeFollow => '跟随配置';

  @override
  String get interfaceNameModeCustom => '自定义';

  @override
  String get interfaceName => '网卡名称';

  @override
  String get copyEnvVar => '复制环境变量';

  @override
  String get memoryInfo => '内存信息';

  @override
  String get total => '总计';

  @override
  String get releaseMemory => '释放内存';

  @override
  String get memoryCoreHeapInuse => '堆内存使用中';

  @override
  String get memoryCoreHeapIdle => '堆内存空闲';

  @override
  String get memoryCoreStack => '协程栈';

  @override
  String get memoryCoreRuntime => '运行时开销';

  @override
  String get memoryCoreNotRunning => '内核未运行';

  @override
  String get memoryAppResident => '常驻内存';

  @override
  String get memoryAppShared => '应用及共享';

  @override
  String get memoryEstimateDesc => '基于进程常驻内存估算，可能与系统显示的数值不同。';

  @override
  String get memoryEstimateSharedDesc =>
      '内核与应用运行在同一进程，内核部分按运行时统计估算，其余计入应用及共享内存。';

  @override
  String get memoryReleased => '内存已释放';

  @override
  String memoryReleasedSize(Object size) {
    return '已释放 $size';
  }

  @override
  String get releaseMemoryFailed => '释放内存失败';

  @override
  String get dialog => '对话框';

  @override
  String get cancel => '取消';

  @override
  String get fileIsUpdate => '文件有修改，是否保存修改';

  @override
  String get profileHasUpdate => '配置文件已经修改，是否关闭自动更新？';

  @override
  String get hasCacheChange => '是否缓存修改';

  @override
  String get copySuccess => '复制成功';

  @override
  String get copyLink => '复制链接';

  @override
  String get exportFile => '导出文件';

  @override
  String get cacheCorrupt => '缓存已损坏，是否清空？';

  @override
  String get detectionTip => '依赖第三方api，仅供参考';

  @override
  String get listen => '监听';

  @override
  String get undo => '撤销';

  @override
  String get redo => '重做';

  @override
  String get lineWrap => '自动换行';

  @override
  String get none => '无';

  @override
  String get advancedConfig => '进阶配置';

  @override
  String get addRule => '添加规则';

  @override
  String get content => '内容';

  @override
  String get ruleTarget => '规则目标';

  @override
  String get exitDefault => '默认';

  @override
  String get customExit => '自定义出口';

  @override
  String get inputExitName => '输入出口名称';

  @override
  String get scriptFailed => '脚本运行失败';

  @override
  String get sourceIp => '源IP';

  @override
  String get noResolve => '不解析IP';

  @override
  String get saveChanges => '是否保存更改？';

  @override
  String get applyNow => '立即应用';

  @override
  String get applied => '已应用';

  @override
  String get cannotSave => '无法保存';

  @override
  String get navigationBarStyle => '底栏';

  @override
  String get floating => '悬浮';

  @override
  String get docked => '固定';

  @override
  String get slide => '滑动';

  @override
  String get fade => '淡入';

  @override
  String get pureBlack => '纯黑';

  @override
  String get customColor => '自定义颜色';

  @override
  String get colorStyle => '配色风格';

  @override
  String get grid => '网格';

  @override
  String get spectrum => '光谱';

  @override
  String get sliders => '滑块';

  @override
  String get hue => '色相';

  @override
  String get saturation => '饱和度';

  @override
  String get brightness => '亮度';

  @override
  String get hex => '十六进制';

  @override
  String get monochromeScheme => '单色';

  @override
  String get vividStyle => '鲜明';

  @override
  String get tintedStyle => '氛围';

  @override
  String get softStyle => '柔和';

  @override
  String get developerMode => '开发者模式';

  @override
  String get developerModeEnableTip => '开发者模式已启用。';

  @override
  String get messageTest => '消息测试';

  @override
  String get messageTestTip => '这是一条消息。';

  @override
  String get crashTest => '崩溃测试';

  @override
  String get crashDetected => '检测到崩溃';

  @override
  String crashDetectedTip(Object name) {
    return '应用连续两次未能完成启动。为打断崩溃循环，已取消选中配置 $name，并跳过本次自动配置，你可以随时重新选中它。';
  }

  @override
  String get launchInterrupted => '启动未完成';

  @override
  String get launchInterruptedTip => '应用上次在启动过程中意外退出。已跳过本次自动配置，你可以手动启动重试。';

  @override
  String get clearData => '清除数据';

  @override
  String get textScale => '文本缩放';

  @override
  String get textScalePreview => '应用内的文字将以这个大小显示';

  @override
  String get followSystem => '跟随系统';

  @override
  String get internet => '互联网';

  @override
  String get systemApp => '系统应用';

  @override
  String get noNetworkApp => '无网络应用';

  @override
  String get restoreStrategy => '恢复策略';

  @override
  String get restoreStrategyOverride => '覆盖';

  @override
  String get restoreStrategyCompatible => '兼容';

  @override
  String get logsTest => '日志测试';

  @override
  String emptyTip(Object label) {
    return '$label不能为空';
  }

  @override
  String urlTip(Object label) {
    return '$label必须为URL';
  }

  @override
  String get invalidLinkTip => '不是有效的订阅链接或代理分享链接';

  @override
  String numberTip(Object label) {
    return '$label必须为数字';
  }

  @override
  String numberRangeTip(Object label, Object min, Object max) {
    return '$label必须在 $min 到 $max 之间';
  }

  @override
  String get interval => '间隔';

  @override
  String existsTip(Object label) {
    return '$label当前已存在';
  }

  @override
  String maxLengthTip(Object label, Object max) {
    return '$label最多$max个字符';
  }

  @override
  String get singleImport => '单条导入';

  @override
  String get batchImport => '批量导入';

  @override
  String get batchUrlInputTip => '每行一个URL';

  @override
  String get batchLinkInputTip => '每行一个链接';

  @override
  String batchPreviewTip(Object count, Object skipped) {
    return '将添加 $count 项，跳过 $skipped 项已存在';
  }

  @override
  String lineIssueTip(Object line, Object message) {
    return '第 $line 行：$message';
  }

  @override
  String singleValueTip(Object label) {
    return '$label只能是一项';
  }

  @override
  String deleteTip(Object label) {
    return '确定删除当前$label吗？';
  }

  @override
  String deleteMultipTip(Object label) {
    return '确定删除选中的$label吗？';
  }

  @override
  String nullTip(Object label) {
    return '暂无$label';
  }

  @override
  String get script => '脚本';

  @override
  String get color => '颜色';

  @override
  String get unnamed => '未命名';

  @override
  String get pleaseEnterScriptName => '请输入脚本名称';

  @override
  String get mixedPort => '混合端口';

  @override
  String get socksPort => 'Socks端口';

  @override
  String get redirPort => 'Redir端口';

  @override
  String get tproxyPort => 'Tproxy端口';

  @override
  String portTip(Object label) {
    return '$label 必须在 1024 到 49151 之间';
  }

  @override
  String get portConflictTip => '请输入不同的端口';

  @override
  String get import => '导入';

  @override
  String get importFile => '通过文件导入';

  @override
  String get importUrl => '通过URL导入';

  @override
  String get startFromScratch => '从零开始';

  @override
  String details(Object label) {
    return '$label详情';
  }

  @override
  String get creationTime => '创建时间';

  @override
  String get process => '进程';

  @override
  String get host => '主机';

  @override
  String get destination => '目标地址';

  @override
  String get destinationGeoIP => '目标地理定位';

  @override
  String get destinationIPASN => '目标IP ASN';

  @override
  String get specialProxy => '特殊代理';

  @override
  String get specialRules => '特殊规则';

  @override
  String get remoteDestination => '远程目标';

  @override
  String get networkType => '网络类型';

  @override
  String get proxyChains => '代理链';

  @override
  String get log => '日志';

  @override
  String get connection => '连接';

  @override
  String get request => '请求';

  @override
  String get connected => '已连接';

  @override
  String get disconnected => '已断开';

  @override
  String get connecting => '连接中…';

  @override
  String get restartCoreTip => '您确定要重启核心吗？';

  @override
  String get forceRestartCoreTip => '您确定要强制重启核心吗？';

  @override
  String get dnsHijacking => 'DNS劫持';

  @override
  String get coreStatus => '核心状态';

  @override
  String get appendSystemDns => '追加系统DNS';

  @override
  String get editRule => '编辑规则';

  @override
  String get addedRules => '附加规则';

  @override
  String get addedRulesAfterScript => '在脚本之后插入，排在配置规则前面';

  @override
  String get controlGlobalAddedRules => '控制全局附加规则';

  @override
  String get quickActions => '快捷操作';

  @override
  String get rulePresetBlockQuic => '屏蔽 QUIC';

  @override
  String get rulePresetBlockStun => '屏蔽 STUN';

  @override
  String get rulePresetBlockDot => '屏蔽 DNS over TLS';

  @override
  String get rulePresetBlockLoopback => '防止代理回环';

  @override
  String get rulePresetSystemServicesDirect => 'Apple 与 Microsoft 直连';

  @override
  String get rulePresetBittorrentDirect => 'BT 下载直连';

  @override
  String get rulePresetLanDirect => '局域网直连';

  @override
  String get extendScript => '扩展脚本';

  @override
  String get goToConfigureScript => '前往配置脚本';

  @override
  String get goToConfigureAddedRules => '前往配置附加规则';

  @override
  String get editGlobalRules => '编辑全局规则';

  @override
  String get confirmForceCrashCore => '确定要强制崩溃核心？';

  @override
  String get confirmClearAllData => '确定要清除所有数据？';

  @override
  String get loading => '加载中…';

  @override
  String yearsAgo(num count) {
    return '$count 年前';
  }

  @override
  String monthsAgo(num count) {
    return '$count 个月前';
  }

  @override
  String daysAgo(num count) {
    return '$count 天前';
  }

  @override
  String hoursAgo(num count) {
    return '$count 小时前';
  }

  @override
  String minutesAgo(num count) {
    return '$count 分钟前';
  }

  @override
  String get justNow => '刚刚';

  @override
  String yearsAgoShort(num count) {
    return '$count 年前';
  }

  @override
  String monthsAgoShort(num count) {
    return '$count 个月前';
  }

  @override
  String daysAgoShort(num count) {
    return '$count 天前';
  }

  @override
  String hoursAgoShort(num count) {
    return '$count 小时前';
  }

  @override
  String minutesAgoShort(num count) {
    return '$count 分钟前';
  }

  @override
  String get noLongerRemind => '不再提示';

  @override
  String get turnOn => '开启';

  @override
  String get turnOff => '关闭';

  @override
  String get vpnConfigChangeDetected => 'VPN 相关配置已改动，点击重启';

  @override
  String get restart => '重启';

  @override
  String get speedStatistics => '网速统计';

  @override
  String get resetPageChangesTip => '当前页面存在更改，确定重置吗？';

  @override
  String get customProfile => '自定义';

  @override
  String get customResources => '自定义';

  @override
  String get unknownNetworkError => '未知网络错误';

  @override
  String get backupFromNewerVersion => '该备份来自更高版本的应用，请先更新应用再恢复';

  @override
  String get networkTimeoutError => '请求超时，请检查网络或代理后重试';

  @override
  String get networkHostLookupError => '无法解析服务器地址，请确认链接正确且 DNS 可用';

  @override
  String get monochromeIcon => '单色图标';

  @override
  String get networkConnectionError => '无法连接到服务器，请检查网络连接或代理设置';

  @override
  String get networkTlsError => '安全连接失败，服务器证书可能无效，或连接被拦截';

  @override
  String get networkCancelledError => '请求已取消';

  @override
  String networkAccessDeniedError(Object code) {
    return '服务器拒绝访问（HTTP $code），链接可能已过期或凭据有误';
  }

  @override
  String networkNotFoundError(Object code) {
    return '该地址下没有内容（HTTP $code），请确认链接是否正确';
  }

  @override
  String get networkRateLimitedError => '请求过于频繁（HTTP 429），请稍后再试';

  @override
  String networkServerError(Object code) {
    return '服务器出现问题（HTTP $code），请稍后再试';
  }

  @override
  String networkBadResponseError(Object code) {
    return '服务器拒绝了请求（HTTP $code）';
  }

  @override
  String networkRequestFailed(Object detail) {
    return '网络请求失败：$detail';
  }

  @override
  String get invalidBackupFile => '无效备份文件';

  @override
  String get pruneCache => '修剪缓存';

  @override
  String get backupAndRestore => '备份与恢复';

  @override
  String get restore => '恢复';

  @override
  String get restoreSuccess => '恢复成功';

  @override
  String get restoreOnlyConfig => '仅恢复配置文件';

  @override
  String get restoreAllData => '恢复所有数据';

  @override
  String get addProfile => '添加配置';

  @override
  String get delayTest => '延迟测试';

  @override
  String get proxyGroupEmpty => '策略组为空';

  @override
  String get confirmExitWindow => '确定要退出当前窗口吗？';

  @override
  String get optional => '可选';

  @override
  String get maxFailedTimes => '最大失败次数';

  @override
  String get testInterval => '测试间隔';

  @override
  String get excludeFilter => '排除筛选';

  @override
  String get expectedStatus => '预期状态';

  @override
  String get strategy => '策略';

  @override
  String get tolerance => '容差';

  @override
  String get inputProxyGroupName => '输入策略组名称';

  @override
  String get helperCorruptTip => 'Helper 服务不可用，无法启用 TUN 模式，请重新安装 FlClash。';

  @override
  String get tunAuthorizationFailed => '虚拟网卡授权失败，本次运行不使用虚拟网卡。';

  @override
  String get sudoPasswordTitle => '输入 sudo 密码';

  @override
  String coreBlockedByPolicyTip(Object code) {
    return 'Windows 拒绝运行 FlClashCore.exe（错误 $code）。智能应用控制、AppLocker 等应用控制策略会拦截未签名程序，请在该策略中放行 FlClash 或关闭策略后重试。';
  }

  @override
  String get coreBlockedBySmartAppControlTip =>
      'Windows 智能应用控制拦截了未签名的 FlClashCore.exe。请打开 Windows 安全中心 → 应用和浏览器控制 → 智能应用控制设置，选择「关闭」后重新启动 FlClash。智能应用控制关闭后无法再开启，除非重装 Windows。';

  @override
  String get hideFromList => '从列表中隐藏';

  @override
  String get testWhenUsed => '使用时测试';

  @override
  String get disableUDP => '禁用UDP';

  @override
  String get confirmDeleteProxyGroup => '确定要删除当前策略组吗？';

  @override
  String get ruleEmpty => '规则为空';

  @override
  String get inputRuleContent => '输入规则内容';

  @override
  String get ruleSet => '规则集';

  @override
  String get selectRuleSet => '请选择规则集';

  @override
  String get splitStrategy => '分流策略';

  @override
  String get selectSplitStrategy => '请选择分流策略';

  @override
  String get noResolveHostname => '不解析主机名';

  @override
  String get matchSourceIp => '匹配来源IP';

  @override
  String get basicInfo => '基础信息';

  @override
  String get additionalParameters => '附加参数';

  @override
  String get proxyType => '代理类型';

  @override
  String get basicStrategy => '基础策略';

  @override
  String get editProxy => '编辑代理';

  @override
  String get addNodes => '添加节点';

  @override
  String get addProxyGroup => '添加策略组';

  @override
  String get editProxyGroup => '编辑策略组';

  @override
  String get iconUrl => '图标链接';

  @override
  String get iconRecords => '图标记录';

  @override
  String get custom => '自定义';

  @override
  String get ruleActionDomainDesc => '匹配完整域名';

  @override
  String get ruleActionDomainSuffixDesc => '匹配域名后缀';

  @override
  String get ruleActionDomainKeywordDesc => '匹配域名关键字';

  @override
  String get ruleActionDomainRegexDesc => '使用域名正则表达式匹配';

  @override
  String get ruleActionDomainWildcardDesc => '通配符匹配，仅支持*和?通配符';

  @override
  String get ruleActionGeositeDesc => '匹配 Geosite 内的域名';

  @override
  String get ruleActionIpCidrDesc => '匹配 IP 地址范围';

  @override
  String get ruleActionIpCidr6Desc => '匹配 IP 地址范围，IP-CIDR6 只是一个别名';

  @override
  String get ruleActionIpSuffixDesc => '匹配 IP 后缀范围';

  @override
  String get ruleActionIpAsnDesc => '匹配 IP 所属 ASN';

  @override
  String get ruleActionGeoipDesc => '匹配 IP 所属国家代码';

  @override
  String get ruleActionSrcGeoipDesc => '匹配来源 IP 所属国家代码';

  @override
  String get ruleActionSrcIpAsnDesc => '匹配来源 IP 所属 ASN';

  @override
  String get ruleActionSrcIpCidrDesc => '匹配来源 IP 地址范围';

  @override
  String get ruleActionSrcIpSuffixDesc => '匹配来源 IP 后缀范围';

  @override
  String get ruleActionDstPortDesc => '匹配请求目标端口范围';

  @override
  String get ruleActionSrcPortDesc => '匹配请求来源端口范围';

  @override
  String get ruleActionInPortDesc => '匹配入站端口';

  @override
  String get ruleActionInTypeDesc => '匹配入站类型';

  @override
  String get ruleActionInUserDesc => '匹配入站用户名，支持使用 / 分隔多个用户名';

  @override
  String get ruleActionInNameDesc => '匹配入站名称';

  @override
  String get ruleActionRematchNameDesc => '匹配重匹配名称，多个名称用/分隔';

  @override
  String get ruleActionProcessPathDesc => '使用完整进程路径匹配';

  @override
  String get ruleActionProcessPathRegexDesc => '使用进程路径正则表达式匹配';

  @override
  String get ruleActionProcessPathWildcardDesc => '使用进程路径通配符匹配，仅支持*和?通配符';

  @override
  String get ruleActionProcessNameDesc => '使用进程匹配，在Android平台可以匹配包名';

  @override
  String get ruleActionProcessNameRegexDesc => '使用进程名称正则表达式匹配，在Android平台可以匹配包名';

  @override
  String get ruleActionProcessNameWildcardDesc => '使用进程名称通配符匹配，仅支持*和?通配符';

  @override
  String get ruleActionUidDesc => '匹配 Linux USER ID';

  @override
  String get ruleActionNetworkDesc => '匹配TCP或者UDP';

  @override
  String get ruleActionDscpDesc => '匹配DSCP标记（仅限 tproxy udp 入站）';

  @override
  String get ruleActionRuleSetDesc => '引用规则集合，需配置rule-providers';

  @override
  String get ruleActionAndDesc => '逻辑规则 AND';

  @override
  String get ruleActionOrDesc => '逻辑规则 OR';

  @override
  String get ruleActionNotDesc => '逻辑规则 NOT';

  @override
  String get ruleActionSubRuleDesc => '匹配至子规则，需要注意括号的使用';

  @override
  String get ruleActionMatchDesc => '匹配所有请求，无需条件';

  @override
  String get contentNotEmpty => '内容不能为空';

  @override
  String get splitStrategyNotEmpty => '分流策略不能为空';

  @override
  String get timeout => '超时';

  @override
  String get delayFailed => '失败';

  @override
  String invalidSubRule(Object subRule) {
    return '$subRule 是一个无效的SUB_RULE';
  }

  @override
  String invalidPolicy(Object target) {
    return '$target 是一个无效的策略';
  }

  @override
  String invalidProxyProvider(Object providerName) {
    return '$providerName 是一个无效的代理集';
  }

  @override
  String invalidRuleSet(Object ruleSet) {
    return '$ruleSet 不是有效的规则集';
  }

  @override
  String get invalidNetworkContent => '仅支持 tcp 或 udp';

  @override
  String get invalidRangeContent => '请输入数字或范围，如 80 或 8000-9000，多个用 / 分隔';

  @override
  String get invalidDscpContent => 'DSCP 标记不能超过 63';

  @override
  String get invalidCidrContent => '请输入 CIDR 格式的 IP 段，如 192.168.0.0/16';

  @override
  String get invalidPortRangeContent => '请输入端口或范围，如 443 或 8000-9000';

  @override
  String get invalidHostContent => '请输入域名或 IP 地址';

  @override
  String get invalidListenContent => '请输入地址和端口，如 0.0.0.0:1053';

  @override
  String invalidProxy(Object proxyName) {
    return '$proxyName 是一个无效的代理';
  }

  @override
  String get locationPermissionRequired => '需要位置权限';

  @override
  String locationPermissionGuide(Object appName) {
    return '1. 打开 系统设置 > 隐私与安全性\n2. 选择 定位服务\n3. 在右侧列表中找到并勾选 $appName\n\n完成设置后，返回应用即可正常使用。感谢您的配合。';
  }

  @override
  String get prerequisites => '前置条件';

  @override
  String get ignoreBatteryOptimization => '忽略电池优化';

  @override
  String get locationPermission => '位置权限';

  @override
  String get locationPermissionDesc =>
      '根据系统要求，获取Wi-Fi名称需要您授予位置权限。Android 上请选择“始终允许”，否则应用在后台时无法获取 Wi-Fi 名称。';

  @override
  String get excludeSsids => '排除SSIDs';

  @override
  String get excludeSsidsDesc => '连接到被排除 SSID 的 Wi-Fi 时，将会自动切换应用运行状态。';

  @override
  String get ssidsEmpty => 'SSIDs为空';

  @override
  String get onDemand => '按需运行';

  @override
  String get locationPermissionDeniedMessage =>
      '位置权限已被拒绝，无法获取当前 Wi-Fi 名称。请前往系统设置手动开启位置权限。';

  @override
  String get addSsid => '添加SSID';

  @override
  String get editSsid => '编辑SSID';

  @override
  String get authorized => '已授权';

  @override
  String get tapToAuthorize => '点击授权';

  @override
  String get suspended => '挂起中…';

  @override
  String get resourceUpdateInterval => '自动更新间隔';

  @override
  String get resourceUpdateIntervalTip => '自动更新间隔必须大于0';

  @override
  String get hours => '小时';

  @override
  String get minutes => '分钟';

  @override
  String get geoResources => 'Geo';

  @override
  String geoSkipped(Object name) {
    return '$name 已是最新版本';
  }

  @override
  String geoUpdated(Object name) {
    return '$name 已更新';
  }

  @override
  String secondsCount(num count) {
    return '$count 秒';
  }

  @override
  String proxiesCount(num count, Object label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label 个代理',
    );
    return '$_temp0';
  }

  @override
  String rulesCount(num count, Object label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label 条规则',
    );
    return '$_temp0';
  }

  @override
  String proxyGroupsCount(num count, Object label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label 个策略组',
    );
    return '$_temp0';
  }

  @override
  String get changelogBreaking => '重大变更';

  @override
  String get changelogFeatures => '新功能';

  @override
  String get changelogFixes => '问题修复';

  @override
  String get changelogPerformance => '性能优化';

  @override
  String get changelogReverts => '已回滚';

  @override
  String get close => '关闭';

  @override
  String get back => '返回';

  @override
  String get minimize => '最小化';

  @override
  String get maximize => '最大化';

  @override
  String get unmaximize => '向下还原';

  @override
  String get pinWindow => '窗口置顶';

  @override
  String get unpinWindow => '取消置顶';

  @override
  String get exitFullScreen => '退出全屏';

  @override
  String get torch => '手电筒';

  @override
  String get pickFromAlbum => '从相册选择';

  @override
  String get scrollToSelected => '滚动到已选';

  @override
  String get showMore => '展开';

  @override
  String get showLess => '收起';

  @override
  String get previousMatch => '上一个匹配';

  @override
  String get nextMatch => '下一个匹配';

  @override
  String get clearSearch => '清除搜索';

  @override
  String get noSearchResults => '没有匹配的结果';

  @override
  String get showPassword => '显示密码';

  @override
  String get hidePassword => '隐藏密码';

  @override
  String get authorize => '授权';

  @override
  String get installedAppsPermissionRequired => '需要读取应用列表权限';

  @override
  String get installedAppsPermissionDesc =>
      '当前系统在授权前不会提供已安装的应用列表，授权后即可配置分应用代理。';

  @override
  String get installedAppsPermissionDeniedMessage =>
      '读取应用列表权限已被拒绝，无法获取已安装的应用。请前往系统设置手动开启。';

  @override
  String get outboundIp => '出站 IP';

  @override
  String get ipAddress => 'IP 地址';

  @override
  String get ipQualityLevel => '等级';

  @override
  String get ipQualityGood => '优';

  @override
  String get ipQualityNormal => '普通';

  @override
  String get ipQualityRisky => '风险';

  @override
  String get ipType => '类型';

  @override
  String get ipTypeResidential => '住宅';

  @override
  String get ipTypeMobile => '移动网络';

  @override
  String get ipTypeBusiness => '商业';

  @override
  String get ipTypeHosting => '机房';

  @override
  String get ipFlags => '命中标记';

  @override
  String get ipFlagProxy => '代理';

  @override
  String get ipFlagVpn => 'VPN';

  @override
  String get ipFlagTor => 'Tor';

  @override
  String get ipFlagAbuser => '滥用记录';

  @override
  String get ipOrganization => '组织';

  @override
  String get ipAsn => 'ASN';

  @override
  String get ipQualitySource => '采用来源';

  @override
  String get ipQualitySources => '各来源';

  @override
  String get ipQualityFailed => '类型查询失败';

  @override
  String get ipQualityRetry => '重新查询';

  @override
  String get ipSourceNoType => '无法判定类型';

  @override
  String get ipSourceRateLimited => '限流';

  @override
  String get ipSourceIpMismatch => '出站 IP 不一致';

  @override
  String get hideIp => '隐藏 IP';

  @override
  String get editorUnavailable => '编辑器不可用';

  @override
  String get replace => '替换';

  @override
  String get replaceAll => '全部替换';

  @override
  String get cameraPermissionRequired => '需要相机权限';

  @override
  String get cameraPermissionDesc => '请在系统设置中允许访问相机以扫描二维码，或从相册选择二维码图片。';

  @override
  String get cameraUnavailable => '相机不可用';

  @override
  String get retry => '重试';

  @override
  String get invalidProfileQrcode => '该二维码不包含配置文件链接';

  @override
  String get dnsQueries => 'DNS查询';

  @override
  String get recordType => '记录类型';

  @override
  String get answers => '应答';

  @override
  String get responseCode => '响应码';

  @override
  String get error => '错误';

  @override
  String get initiator => '发起方';

  @override
  String get cache => '缓存';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get nonTextProviderFile => '该外部资源不是文本文件';

  @override
  String get addCustomProxy => '添加代理';

  @override
  String get definitionNotMap => '配置必须是包含 name 和 type 的 YAML 映射';

  @override
  String get ruleTextInvalid => '规则必须以受支持的类型开头，例如 DOMAIN,example.com,DIRECT';

  @override
  String get ruleListInvalid =>
      '规则必须是 YAML 列表，每项一条规则，例如 - DOMAIN,example.com,DIRECT';

  @override
  String get shareLinksInvalid => '无法从链接中读取代理';

  @override
  String shareLinkUnreadable(Object link) {
    return '无法从 $link 中读取代理';
  }

  @override
  String proxiesProfileLabel(Object name, Object count) {
    return '$name 等 $count 个代理';
  }

  @override
  String get singleShareLinkOnly => '这里只能填写一条链接，多条请在列表的快速编辑中填写';

  @override
  String get username => '用户名';

  @override
  String get emptyFallback => '空组兜底';

  @override
  String get defaultSelected => '默认选中';

  @override
  String get hashByInUser => '按入站用户哈希';

  @override
  String get appProxiesEmpty => '暂无本地代理';

  @override
  String get nodes => '节点';

  @override
  String get localProxies => '本地代理';

  @override
  String get customIssueEmptyName => '名称为空';

  @override
  String customIssueReservedName(Object name) {
    return '$name 是内置策略名，不能在此使用';
  }

  @override
  String customIssueDuplicateName(Object name) {
    return '名称 $name 已被其他代理或策略组使用';
  }

  @override
  String customIssueCoreRejected(Object message) {
    return '内核无法解析该代理：$message';
  }

  @override
  String customIssueMissingProxies(Object names) {
    return '以下代理或策略不存在：$names';
  }

  @override
  String customIssueMissingProviders(Object names) {
    return '以下代理集不存在：$names';
  }

  @override
  String get customIssueNoProxySource => '未选择任何代理或代理集，内核会拒绝该策略组';

  @override
  String customIssueGroupLoop(Object path) {
    return '策略组之间存在循环引用：$path';
  }

  @override
  String customIssueInvalidEmptyFallback(Object name) {
    return '空组兜底只能是代理，$name 不存在或是策略组';
  }

  @override
  String customIssueInvalidFilter(Object name, Object message) {
    return '$name不是有效的正则：$message';
  }

  @override
  String customIssueMissingDialer(Object name) {
    return '拨号代理 $name 不存在';
  }

  @override
  String customIssueDialerLoop(Object proxy, Object target) {
    return '$proxy 经 $target 拨号，而 $target 又会回到 $proxy，形成环路';
  }

  @override
  String dialerProxyLoopStopped(Object name) {
    return '经 $name 拨号会绕回使用它的代理，连接已中止';
  }

  @override
  String scriptNotification(Object script, Object text) {
    return '脚本 $script\n$text';
  }

  @override
  String customIssuesSummary(Object count) {
    return '$count 项存在问题，应用配置可能失败';
  }

  @override
  String providerInUse(Object label, Object profiles) {
    return '$label 仍被 $profiles 使用，删除后这些配置会异常。确定删除吗？';
  }

  @override
  String proxyGroupInUse(Object label) {
    return '$label 仍被当前配置的规则、策略组、拨号代理、DNS 或 NTP 引用，删除后这些引用会失效。确定删除吗？';
  }

  @override
  String proxiesRemovedTip(Object removed) {
    return '以下代理将被删除：$removed。改了名字的行按新代理处理，自定义配置中对被删除代理的引用会标为缺失。确定应用吗？';
  }

  @override
  String proxiesReplacedTip(Object removed, Object added) {
    return '以下代理将被删除：$removed。以下代理将新增：$added。改了名字的行按新代理处理，自定义配置中对被删除代理的引用会标为缺失。确定应用吗？';
  }

  @override
  String get fontSize => '大小';

  @override
  String get large => '大';

  @override
  String get extraLarge => '超大';

  @override
  String get switchProfile => '切换配置';

  @override
  String get lastUpdated => '上次更新';

  @override
  String get filters => '筛选';

  @override
  String get label => '标签';

  @override
  String get regex => '正则';

  @override
  String get matchCase => '区分大小写';

  @override
  String get iconSets => '图标集';

  @override
  String get invalidIconSet => '不是有效的图标集';

  @override
  String get recommendedIcons => '推荐';

  @override
  String get localImage => '本地图片';

  @override
  String get iconSetsEmptyTip => '暂无图标集，可在「自定义配置资源 → 图标集」中添加';

  @override
  String get outbound => '出站';

  @override
  String get strictRoute => '严格路由';

  @override
  String get congestionController => 'TCP 拥塞控制';

  @override
  String get routeExcludeAddress => '排除路由地址';

  @override
  String get keepAliveIdle => 'TCP 保持活动空闲时间';

  @override
  String get disableKeepAlive => '禁用 TCP 保持活动';

  @override
  String get routingMark => '路由标记';

  @override
  String get strictRouteDesc => '关闭 IPv6 时，严格路由会阻断本机的 IPv6 连接。';

  @override
  String get initFailed => '启动失败';

  @override
  String get initFailedTip =>
      'FlClash 启动时出错，无法继续运行。可以复制错误详情用于反馈；如果问题反复出现，清除数据后通常可以重新启动。';

  @override
  String get errorDetails => '错误详情';

  @override
  String get stackTrace => '堆栈信息';

  @override
  String get clearDataAndExitTip => '将删除所有配置、设置和本地数据，随后关闭应用。重新打开即可从头开始。';

  @override
  String clearDataFailed(Object detail) {
    return '清除数据失败：$detail';
  }

  @override
  String get bypassPrivateRoute => '绕过私有路由地址';

  @override
  String get disableIcmpForwarding => '禁用ICMP转发';

  @override
  String get disableIcmpForwardingDesc => '禁用 ICMP 转发后，ping 不再显示真实延迟。';

  @override
  String get excludeInterface => '排除网卡';

  @override
  String get includeInterface => '包含网卡';

  @override
  String get includeInterfaceDesc => '设置后排除网卡不再生效。';

  @override
  String get includeUid => '包含用户 ID';

  @override
  String get excludeUid => '排除用户 ID';

  @override
  String get excludeSrcPort => '排除源端口';

  @override
  String get excludeDstPort => '排除目标端口';

  @override
  String get udpTimeout => 'UDP 超时';

  @override
  String get udpTimeoutDesc => 'UDP 超时以秒为单位。';

  @override
  String get dnsHijackDesc => '未添加时劫持所有发往 53 端口的 DNS 请求（any:53）。';

  @override
  String get tunOverrideDesc => '添加的项覆写所有配置的设置，自定义配置自己的项优先。';

  @override
  String get generalOverrideDesc => '添加的项覆写所有配置的对应设置。';

  @override
  String get profileTunSettingsDesc => '仅作用于当前配置，优先于网络设置中的覆写项。';

  @override
  String settingsCount(num count) {
    return '$count 项设置';
  }

  @override
  String sectionsInEffect(Object count) {
    return '$count 项生效';
  }

  @override
  String itemsCount(num count) {
    return '$count 项';
  }

  @override
  String get additionalPrefix => '名称前缀';

  @override
  String get additionalSuffix => '名称后缀';

  @override
  String get skipCertVerify => '跳过证书验证';

  @override
  String get ipVersion => 'IP 版本';

  @override
  String get addFilters => '添加筛选';

  @override
  String failedItem(Object label, Object message) {
    return '$label：$message';
  }

  @override
  String failedCount(Object count) {
    return '$count 项失败，点击查看';
  }

  @override
  String get importConfigInvalid => '此文件不是可导入的配置';

  @override
  String get importConfigReplaceTip => '导入会替换此配置现有的策略组、规则和设置';

  @override
  String get networkName => '网络名称';

  @override
  String get networkSecret => '网络密码';

  @override
  String get peers => '初始节点';

  @override
  String get virtualIpv4 => '虚拟 IPv4';

  @override
  String get hostname => '主机名';

  @override
  String get exitNodes => '出口节点';

  @override
  String get cipher => '加密方式';

  @override
  String get protocol => '协议';

  @override
  String get protocolParam => '协议参数';

  @override
  String get obfs => '混淆';

  @override
  String get obfsParam => '混淆参数';

  @override
  String get obfsPassword => '混淆密码';

  @override
  String get obfsMode => '混淆模式';

  @override
  String get obfsHost => '混淆主机';

  @override
  String get plugin => '插件';

  @override
  String get pluginMode => '插件模式';

  @override
  String get pluginHost => '插件主机';

  @override
  String get pluginPath => '插件路径';

  @override
  String get pluginUsername => '插件用户名';

  @override
  String get pluginPassword => '插件密码';

  @override
  String get pluginCipher => '插件加密方式';

  @override
  String get privateKey => '私钥';

  @override
  String get publicKey => '公钥';

  @override
  String get privateKeyPassphrase => '私钥密码';

  @override
  String get preSharedKey => '预共享密钥';

  @override
  String get secretKey => '密钥';

  @override
  String get transport => '传输协议';

  @override
  String get uploadBandwidth => '上行带宽';

  @override
  String get downloadBandwidth => '下行带宽';

  @override
  String get protocolVersion => '协议版本';

  @override
  String get portHopping => '端口跳跃';

  @override
  String get hopInterval => '跳跃间隔';

  @override
  String get congestionControl => '拥塞控制';

  @override
  String get udpRelayMode => 'UDP 中继模式';

  @override
  String get allowedIps => '允许的 IP';

  @override
  String get remoteDnsResolve => '远程 DNS 解析';

  @override
  String get clientFingerprint => '客户端指纹';

  @override
  String get requestHeaders => '请求头';

  @override
  String transportHeaders(Object transport) {
    return '$transport 请求头';
  }

  @override
  String get required => '必填';

  @override
  String get ageSecretKey => 'age 私钥';

  @override
  String get ageEncryptedProfile => '配置已加密';

  @override
  String get ageSecretKeyRequiredTip => '该配置已用 age 加密，需要 age 私钥才能解密';

  @override
  String get currentOutboundDesc => '含启动键，不可移除';

  @override
  String get running => '运行中';

  @override
  String get root => 'Root';

  @override
  String get notRunning => '未运行';

  @override
  String trafficPeak(Object value) {
    return '峰值 $value';
  }

  @override
  String trafficTotal(Object value) {
    return '累计 $value';
  }

  @override
  String get ipQualityShort => '质量';

  @override
  String get ipTypeUnknown => '类型未知';

  @override
  String get tapIconToRetry => '点击图标重试';

  @override
  String get networkTakeover => '网络接管';

  @override
  String portValue(Object port) {
    return '端口 $port';
  }

  @override
  String serviceAbnormalCount(num count) {
    return '$count 项异常';
  }

  @override
  String get serviceAllAvailable => '全部可用';

  @override
  String get serviceShownOnDashboard => '显示在仪表盘';

  @override
  String groupTimeoutCount(Object count) {
    return '$count 超时';
  }

  @override
  String get groupCountUnit => '个';

  @override
  String groupCount(num count) {
    return '$count 个';
  }

  @override
  String get proxyGroupsAfterStart => '启动后在这里显示策略组';

  @override
  String get usedShort => '已用';

  @override
  String profileUpdatedAt(Object time) {
    return '更新于 $time';
  }

  @override
  String profileExpiresIn(Object date, num days) {
    return '$date 到期，剩余 $days 天';
  }

  @override
  String profileDaysLeft(num days) {
    return '剩余 $days 天';
  }

  @override
  String get target => '目标';

  @override
  String get outboundExit => '出口';

  @override
  String get duration => '时长';

  @override
  String get traffic => '流量';

  @override
  String get totalDownload => '下载总量';

  @override
  String get totalUpload => '上传总量';

  @override
  String get initiatorShort => '发起';

  @override
  String get result => '结果';

  @override
  String get elapsed => '耗时';

  @override
  String get connectionStats => '连接统计';

  @override
  String get connectionStatsDesc => '实时连接、最近请求、DNS查询';

  @override
  String get memoryInfoDesc => '应用与内核占用的内存';

  @override
  String get editDashboard => '编辑仪表盘';

  @override
  String get done => '完成';

  @override
  String get dashboardAddableSection => '可添加';

  @override
  String customImportDroppedSubRules(num count, Object label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '自定义配置不支持子规则，已丢弃 $label 条 SUB-RULE 规则',
    );
    return '$_temp0';
  }

  @override
  String get autoInclude => '自动包含';

  @override
  String get allReferencedProxies => '全部被引用的代理';

  @override
  String get allReferencedProxyProviders => '全部被引用的代理集';

  @override
  String get clearDnsCache => '清除DNS缓存';

  @override
  String get dnsCacheCleared => 'DNS缓存已清除';

  @override
  String get clearDnsCacheFailed => '清除DNS缓存失败';

  @override
  String get select => '选中';

  @override
  String get preferred => '首选';

  @override
  String get addToLocalProxies => '添加到本地代理';

  @override
  String addedToLocalProxies(Object name) {
    return '已将 $name 添加到本地代理';
  }

  @override
  String alreadyInLocalProxies(Object name) {
    return '本地代理中已有 $name';
  }

  @override
  String get mitm => 'MITM';

  @override
  String get httpsDecryption => 'HTTPS 解密';

  @override
  String get httpCapture => '抓包';

  @override
  String get httpCaptureNoHosts => '在“主机名”中添加主机后才会记录。';

  @override
  String get httpCaptureLimit => '最多记录条数';

  @override
  String get httpCaptureMemoryOnly => '仅保存在内存中';

  @override
  String get httpRequests => 'HTTP 请求';

  @override
  String httpRequestCount(int count) {
    return '$count 个 HTTP 请求';
  }

  @override
  String latestHttpRequest(String request) {
    return '最近一次 $request';
  }

  @override
  String get httpRequestsMissing => '抓包开启前发出或已被清除的请求不在列表中。';

  @override
  String get noHttpRequests => '还没有请求';

  @override
  String get noHttpRequestsHint => '这条连接已经解密，上面的 HTTP 请求会出现在这里';

  @override
  String get httpRequestCleared => '这条请求的记录已清除';

  @override
  String get httpCaptureOff => '抓包未开启';

  @override
  String get inProgress => '进行中';

  @override
  String get method => '方法';

  @override
  String get originalUrl => '原 URL';

  @override
  String get httpTiming => '耗时';

  @override
  String get httpWaiting => '等待响应';

  @override
  String get httpReceiving => '接收';

  @override
  String get requestBody => '请求体';

  @override
  String get response => '响应';

  @override
  String get responseBody => '响应体';

  @override
  String get responseHeaders => '响应头';

  @override
  String get matchedRules => '命中的规则';

  @override
  String get overview => '概览';

  @override
  String get viewAll => '查看全部';

  @override
  String get copyAsBase64 => '复制为 Base64';

  @override
  String get copyAsCurl => '复制为 cURL';

  @override
  String get closeConnection => '关闭连接';

  @override
  String get copyHost => '复制主机';

  @override
  String get copyDestination => '复制目标地址';

  @override
  String get copyRequest => '复制请求';

  @override
  String get copyResponse => '复制响应';

  @override
  String get copyResponseBody => '复制响应体';

  @override
  String get httpBodyProtobufGuess => '按 Protobuf 解析，没有 .proto：只有字段编号，类型是推测的。';

  @override
  String get exportHar => '导出 HAR';

  @override
  String get mitmAddRejectRule => '添加拒绝规则';

  @override
  String get mitmAddMapLocalRule => '添加本地映射规则';

  @override
  String get httpExportPrivateTitle => '包含隐私信息';

  @override
  String get httpExportPrivate => '请求里可能有 Cookie、令牌、密码和表单内容，分享前请确认内容和对象。';

  @override
  String get mitmRuleCopiedForStash => '这个模块是 Stash 覆写，规则已复制，请手动添加。';

  @override
  String get binaryData => '二进制数据';

  @override
  String get httpBodyNotKept => '内存紧张时未记录这段内容。';

  @override
  String get httpBodyTruncated => '只记录了这段内容的开头部分。';

  @override
  String httpBodyUndecoded(Object encoding) {
    return '无法解码 $encoding，显示的是传输时的原始数据。';
  }

  @override
  String get mitmEnableTip =>
      '开启后，FlClash 能读取发往被解密主机的全部内容，包括 Cookie 和密码。请只为需要改写的主机开启。';

  @override
  String get generateCertificate => '生成证书';

  @override
  String get regenerateCertificate => '重新生成证书';

  @override
  String get regenerateCertificateTip =>
      '新证书会替换当前证书，FlClash 会尽量把当前证书从本机信任的根证书中移除。信任当前证书的其他设备都需要安装新证书。';

  @override
  String get exportCertificate => '导出证书';

  @override
  String get installCertificate => '安装到系统';

  @override
  String get installCertificateSuccess => '证书已安装';

  @override
  String validUntil(Object date) {
    return '有效期至 $date';
  }

  @override
  String get mitmCertificateExportTip => '导出后在要解密的设备上信任此证书。';

  @override
  String get mitmTrustReady => '已信任';

  @override
  String get mitmTrustUntrusted => '未完全信任';

  @override
  String get mitmTrustNotInstalled => '未安装';

  @override
  String get mitmTrustChecking => '正在检查…';

  @override
  String get mitmCertificateAndroidReadyTip => '只有信任用户证书的应用（多为浏览器）会被解密。';

  @override
  String get mitmAndroidRootDesc => '未 root 时只解密信任用户证书的应用。';

  @override
  String get mitmCertificateLinuxTip => 'Flatpak 版浏览器需要手动导入导出的证书。';

  @override
  String mitmCertutilMissing(Object command) {
    return 'Chrome 和 Firefox 使用自己的证书库，需要 certutil：$command';
  }

  @override
  String mitmMissingStores(Object stores) {
    return '尚未加入：$stores';
  }

  @override
  String get httpRequestsReadFailed => '无法读取请求';

  @override
  String get requestBodyReadFailed => '无法读取请求体';

  @override
  String get responseBodyReadFailed => '无法读取响应体';

  @override
  String mitmGrpcOverLimit(Object size) {
    return '解压后超过 $size MB，显示压缩数据';
  }

  @override
  String mitmUntrustedStores(Object stores) {
    return '已安装但未信任：$stores';
  }

  @override
  String get mitmSystemStoreFailed => '无法把证书加入系统信任的根证书';

  @override
  String get mitmRootUntilReboot =>
      '未找到可保留证书的 Magisk、KernelSU 或 APatch，重启手机后需要重新安装。';

  @override
  String get mitmRootPendingReboot => '证书将在重启手机后生效。';

  @override
  String get mitmInstallSystemCaTip =>
      '检测到 root，证书将以 Magisk、KernelSU 或 APatch 模块“FlClash MITM CA”加入系统信任的根证书。之后本机所有应用都会信任它，持有其私钥的人可以解密本机的 HTTPS 流量。如需撤销，可重新生成证书，或在 root 管理器中移除该模块并重启。若拒绝 root 授权，将改为安装用户证书。';

  @override
  String get mitmInstallUserCaTip =>
      '未检测到 root，证书只能安装为用户证书。只有信任用户证书的应用（多为浏览器）会被解密，其他应用访问列出的主机会失败，请不要列出它们的主机。Android 11 起需在系统设置中手动完成安装。';

  @override
  String mitmCertificateSavedTip(Object fileName) {
    return '已将 $fileName 保存到“下载”。请在系统设置的“安全 › 加密与凭据 › 安装证书 › CA 证书”中安装。';
  }

  @override
  String get openSettings => '打开设置';

  @override
  String mitmRemoveOldCertificateTip(Object name) {
    return '请在系统设置的“安全 › 加密与凭据 › 信任的凭据 › 用户”中移除旧证书 $name，再安装新证书。';
  }

  @override
  String mitmOldCertificateLeftTip(Object name) {
    return '无法移除旧证书 $name，请自行从信任的根证书中移除。';
  }

  @override
  String mitmOldSystemCertificateLeftTip(Object name) {
    return '旧证书 $name 仍在系统信任的证书中。请在 root 管理器中允许 FlClash 使用 root 后重新生成，或在其中移除“FlClash MITM CA”模块并重启。';
  }

  @override
  String get removeCertificate => '移除证书';

  @override
  String get removeCertificateSuccess => '已移除证书';

  @override
  String get mitmSystemStoreRemoveFailed => '无法把证书从系统信任的根证书中移除';

  @override
  String get mitmRemoveInSettings => '在系统设置中移除';

  @override
  String mitmRemoveUserCertificateTip(Object name) {
    return 'Android 不允许应用移除用户证书。请在“安全 › 加密与凭据 › 信任的凭据 › 用户”中移除 $name。';
  }

  @override
  String get mitmCannotRemove => '无法移除';

  @override
  String get mitmRemoveSystemCertificateTip =>
      '证书由 root 模块“FlClash MITM CA”加入系统。请在 root 管理器中允许 FlClash 使用 root 后再试，或在其中移除该模块并重启手机。';

  @override
  String get mitmDecryptHost => '解密此主机';

  @override
  String mitmDecryptHostTip(Object host) {
    return '要把 $host 加入主机名列表吗？之后 FlClash 能读取发往它的内容，包括 Cookie 和密码。';
  }

  @override
  String get mitmClientRefusedCertificate => '客户端拒绝了证书。请安装证书；如果应用固定了证书，请排除此主机。';

  @override
  String get mitmExcludeHost => '排除解密';

  @override
  String mitmExcludeHostTip(Object host) {
    return '要把 -$host 加到主机名列表顶部吗？之后不再解密该主机。';
  }

  @override
  String get urlRewrite => 'URL 重写';

  @override
  String get headerRewrite => 'Header 重写';

  @override
  String get bodyRewrite => 'Body 重写';

  @override
  String get mapLocal => '本地映射';

  @override
  String get requestBodyMock => '请求体替换';

  @override
  String get clientSourceAddress => '客户端地址';

  @override
  String get skipVerifyHostname => '不校验证书的主机';

  @override
  String get mitmModules => '模块';

  @override
  String get mitmModule => '模块';

  @override
  String get mitmModuleInvalid =>
      '这不是 Surge 模块、Loon 插件、Quantumult X 片段或 Stash 覆写';

  @override
  String get arguments => '参数';

  @override
  String get mitmRoutingRules => '分流规则';

  @override
  String get mitmIgnoredLines => '忽略的行';

  @override
  String get mitmModuleRulesDesc => '先于配置自身的规则匹配。';

  @override
  String get mitmRequestRulesDesc =>
      'URL-REGEX 和 USER-AGENT 规则改作 URL 重写，HTTPS 只对主机名中的主机生效。';

  @override
  String mitmExtendedMatchingNote(Object count) {
    return '其中 $count 条使用扩展匹配';
  }

  @override
  String mitmActionModule(Object module) {
    return '来自 $module';
  }

  @override
  String mitmModuleSystemTip(Object system) {
    return '为 $system 编写，部分行可能不适用于本设备。';
  }

  @override
  String mitmModuleRequirementTip(Object requirement) {
    return '模块要求 $requirement，本设备不满足，可能无法按预期工作。';
  }

  @override
  String mitmExitModules(Object modules) {
    return '来自模块：$modules';
  }

  @override
  String get mitmModuleRiskTitle => '启用此模块？';

  @override
  String get mitmNetworkRisk => '启用时会覆盖下列网络设置。';

  @override
  String mitmSkipVerifyRisk(Object hosts) {
    return '开启后，将不再校验下列主机的服务器证书，冒充这些服务器的连接不会被发现：$hosts';
  }

  @override
  String mitmClientSourceRisk(Object addresses) {
    return '它只为这些客户端解密：$addresses。开启 TUN 时，本机应用经 TUN 地址连入 FlClash，可能因此不再解密。';
  }

  @override
  String get mitmClientSourceTunTip => '开启 TUN 时，需包含 TUN 地址才能解密本机应用。';

  @override
  String get mitmNetworkChanges => '网络设置';

  @override
  String mitmChangeReplace(Object values) {
    return '替换为 $values';
  }

  @override
  String mitmChangeInsert(Object values) {
    return '在前面添加 $values';
  }

  @override
  String mitmChangeAppend(Object values) {
    return '添加 $values';
  }

  @override
  String get mitmChangeOverridesYours => '会盖过你的设置';

  @override
  String mitmChangeReplacedBy(Object module) {
    return '已被模块 $module 覆盖';
  }

  @override
  String mitmSkipSection(Object section) {
    return '不支持 [$section] 段';
  }

  @override
  String get mitmSkipSetting => '不支持此设置';

  @override
  String get mitmSkipScriptType => '不支持此类脚本';

  @override
  String get mitmSkipRule => '不支持此规则类型';

  @override
  String get mitmSkipFinalRule => '模块的规则排在最前面，兜底规则会盖住后面的所有规则';

  @override
  String get mitmSkipDeviceRule => '这类规则依赖 FlClash 读不到的设备或网络信息';

  @override
  String get mitmSkipRequirement => '这一行的使用条件在本设备上不满足';

  @override
  String get mitmSkipManagedCa => 'CA 证书由 FlClash 管理，模块不能更改';

  @override
  String get mitmSkipProxies => '模块不能修改节点和策略组';

  @override
  String get mitmSkipAppOnly => '这是原 App 独有的功能，FlClash 没有对应项';

  @override
  String get mitmSkipReflect => 'FlClash 不能把数据包原路弹回';

  @override
  String get mitmSkipSkipVerifyAll => '不会对全部主机关闭证书校验';

  @override
  String get mitmSkipRelativeData => '此行引用的文件不是附件，请改用 URL 或添加为附件';

  @override
  String get mitmSkipUnreadable => '无法识别此行';

  @override
  String get mitmSkipNoSection => '此行不在任何段内';

  @override
  String get mitmSkipRequirementUnreadable => '无法识别此行的生效条件';

  @override
  String get mitmSkipPolicy => '此规则的策略没有指向任何目标';

  @override
  String get mitmSkipNestedRuleSet => '规则集里不能再引用规则集';

  @override
  String get mitmSkipCondition => '无法判断此条件';

  @override
  String get mitmSkipRuntimeValue => '此行需要只有当前请求才有的值';

  @override
  String get mitmResources => '远程文件';

  @override
  String get mitmResourceOk => '已下载';

  @override
  String get mitmResourceFetching => '正在下载';

  @override
  String get mitmResourceMissing => '尚未下载';

  @override
  String get mitmFetchDns => '下载失败：无法解析主机名';

  @override
  String get mitmFetchTls => '下载失败：无法建立安全连接';

  @override
  String get mitmFetchTimeout => '下载失败：服务器响应超时';

  @override
  String get mitmFetchConnection => '下载失败：连接中断';

  @override
  String get mitmFetchOther => '下载失败';

  @override
  String get mitmResourcesFetch => '重新下载';

  @override
  String mitmFetchHttp(int status) {
    return '下载失败：服务器返回 $status';
  }

  @override
  String get mitmAddLocalFile => '添加本地文件';

  @override
  String get mitmNewModule => '新建模块';

  @override
  String get mitmAttachments => '附件';

  @override
  String get mitmAttachmentsDesc => '行内按文件名引用附件，如 script-path=a.js。';

  @override
  String mitmFileTooLarge(Object size) {
    return '文件大于 $size MB';
  }

  @override
  String get mitmSkipDisabled => '已被参数关闭';

  @override
  String get mitmSkipEvent => '不支持此事件';

  @override
  String get mitmRunScript => '立即运行';

  @override
  String get mitmScriptCron => '定时';

  @override
  String get mitmScriptEvent => '事件';

  @override
  String get mitmScriptGeneric => '通用';

  @override
  String get mitmScriptDns => 'DNS';

  @override
  String get mitmExcluded => '排除';

  @override
  String get mitmScriptNoOutput => '脚本已运行完毕，没有输出';

  @override
  String get mitmScriptRiskTitle => '运行此模块的脚本？';

  @override
  String get mitmModulesTurnedOff => '模块已关闭';

  @override
  String mitmModuleTurnedOffDesc(Object name) {
    return '$name 的更新带来了你未同意过的脚本或网络改动';
  }

  @override
  String mitmModulesTurnedOffDesc(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个模块的更新带来了你未同意过的脚本或网络改动',
    );
    return '$_temp0';
  }

  @override
  String get mitmScriptRisk =>
      '它的脚本能读取并修改所匹配主机的流量，包括 Cookie 和令牌，还能自行发送请求。只在信任其来源时开启。开启后，它之后的更新会直接生效。';

  @override
  String get mitmModuleUnreadableRisk => '无法读取模块文件，不清楚它会改动什么。只在信任其来源时开启。';

  @override
  String get skipServerCertVerify => '跳过服务器证书验证';

  @override
  String get blockQuic => '阻止 QUIC';

  @override
  String get http2 => 'HTTP/2';

  @override
  String get decryptUntrusted => '本机未信任时也解密';

  @override
  String invalidOfCount(Object invalid, Object total) {
    return '$total 条中 $invalid 条无效';
  }

  @override
  String get batchLineInputTip => '每行一项';

  @override
  String get downloadingUpdate => '正在下载更新';

  @override
  String get updateFailed => '更新失败';

  @override
  String get updateDownloadTest => '更新下载测试';

  @override
  String get liveStatusTest => '实时状态卡片测试';

  @override
  String get updateDownloadStarted => '已开始下载更新，可在首页查看进度';

  @override
  String get updateReady => '更新已就绪';

  @override
  String get updateReadyTip => '更新已下载，点击安装';

  @override
  String get stopUpdateDownloadTip => '要停止下载更新吗？';

  @override
  String get forceRestartCoreAsk => '强制重启核心？';

  @override
  String get forceRestartCoreAskDesc => '进行中的连接会断开';

  @override
  String get stopUpdateDownloadDesc => '已下载的部分会被删除';

  @override
  String get stopDownload => '停止';

  @override
  String get updateInstallFailed => '无法安装更新，可以前往发布页手动下载。';

  @override
  String get updateNotVerified => '下载的更新未通过校验。';

  @override
  String get updateRestartTip => 'FlClash 将关闭以安装更新，完成后自动重新打开。';

  @override
  String get updateDownloadFailed => '无法下载更新。';

  @override
  String get updateFileMissing => '未找到更新文件，请在发布页手动下载。';

  @override
  String get defaultNameserverDesc => '用于解析其他 DNS 服务器的域名，只能填写 IP 地址。';

  @override
  String get nameserverDesc =>
      '默认使用的 DNS 服务器，如 223.5.5.5、tls://1.1.1.1、https://dns.google/dns-query。';

  @override
  String get fallbackDesc => 'Nameserver 的结果被 Fallback 过滤判定为污染时，改用这些服务器的结果。';

  @override
  String get proxyServerNameserverDesc => '仅用于解析代理服务器的域名。';

  @override
  String get proxyServerNameserverPolicyDesc =>
      '匹配的代理服务器域名改用此处指定的 DNS 服务器，优先于 Proxy Server Nameserver。';

  @override
  String get directNameserverDesc => '用于解析直连连接的域名。';

  @override
  String get nameserverPolicyDesc =>
      '匹配的域名改用此处指定的 DNS 服务器，优先于 Nameserver 和 Fallback。';

  @override
  String get fakeipFilterDesc =>
      '这些域名不使用 Fake-IP，返回真实 IP；过滤模式为 whitelist 时则只有它们使用 Fake-IP。';

  @override
  String get fallbackFilterGeositeDesc => '属于这些 GeoSite 分类的域名直接使用 Fallback 解析。';

  @override
  String get fallbackFilterIpcidrDesc =>
      'Nameserver 返回这些网段内的 IP 时，改用 Fallback 的结果。';

  @override
  String get fallbackFilterDomainDesc => '这些域名直接使用 Fallback 解析。';

  @override
  String get liveStatus => '实时状态';

  @override
  String get coreStopped => '核心已停止';

  @override
  String get coreStoppedDesc => '应用与核心的连接已断开';

  @override
  String coreStoppedWithReason(Object reason) {
    return '应用与核心的连接已断开：$reason';
  }

  @override
  String get coreUnavailableTip => '核心未运行，请在核心启动后重试';

  @override
  String mixedPortReset(Object value, Object port) {
    return '混合端口不能是 $value，已恢复为 $port';
  }

  @override
  String get restartCore => '重启核心';

  @override
  String get installUpdate => '安装更新';

  @override
  String liveStatusPosition(Object index, Object count) {
    return '第 $index 项，共 $count 项';
  }

  @override
  String get coreStarting => '正在启动核心';

  @override
  String get coreStartingDesc => '正在连接核心';

  @override
  String get coreRunning => '核心运行中';

  @override
  String get coreRunningDesc => '应用已连接到核心';

  @override
  String get forceRestartCore => '强制重启';

  @override
  String get configWarnings => '配置警告';

  @override
  String configWarningsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '加载配置时有 $count 条警告',
    );
    return '$_temp0';
  }

  @override
  String get httpPort => 'HTTP端口';

  @override
  String get dnsServer => 'DNS 服务器';

  @override
  String get serviceFaults => '未能启动的服务';

  @override
  String get faultAddressInUse => '地址已被占用。';

  @override
  String get faultAddressNotAvailable => '本机没有这个地址。';

  @override
  String get faultPermissionDenied => '没有权限。';

  @override
  String get tunStartFailed => '虚拟网卡启动失败，本次运行不再尝试。';

  @override
  String get vpnPermissionNotGranted =>
      '未获得 VPN 权限，VPN 没有启动。其他应用设为始终开启的 VPN 时也会如此。';

  @override
  String get vpnServiceStartFailed => 'VPN 服务无法启动。';

  @override
  String get requestPath => '路径';

  @override
  String get statusCode => '状态码';

  @override
  String get contentKind => '类型';

  @override
  String get httpRewritten => '已改写';

  @override
  String get httpAnswerReject => '拒绝';

  @override
  String get httpAnswerRedirect => '重定向';

  @override
  String get httpAnswerScript => '脚本响应';

  @override
  String get httpBodyText => '文本';

  @override
  String get httpBodyImage => '图片';

  @override
  String get regexReplace => '正则替换';

  @override
  String get owningConnection => '所属连接';

  @override
  String get selectHttpRequest => '选择一个请求';

  @override
  String get selectHttpRequestHint => '这里会显示它的请求、响应和耗时';

  @override
  String httpConditionShows(String count) {
    return '将筛出 $count 个请求';
  }

  @override
  String httpConditionValuesIn(String field) {
    return '当前请求里的$field';
  }

  @override
  String get httpConditionTip => '同一字段的条件满足其一即可，不同字段的都要满足。';
}
