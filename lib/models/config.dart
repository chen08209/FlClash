import 'dart:convert'; // 导入 JSON 解析库，支持 jsonDecode 方法
import 'dart:io'; // 导入 IO 库，用于平台检测
import 'package:http/http.dart' as http; // 导入 HTTP 客户端，用于网络请求

import 'package:fl_clash/common/common.dart'; // 自定义通用工具模块
import 'package:fl_clash/enum/enum.dart'; // 自定义枚举类型
import 'package:flutter/material.dart'; // Flutter Material 库，提供 UI 和状态管理支持
import 'package:freezed_annotation/freezed_annotation.dart'; // Freezed 库，用于生成不可变数据类

import 'models.dart'; // 导入其他自定义模型

part 'generated/config.freezed.dart'; // Freezed 生成的不可变类代码
part 'generated/config.g.dart'; // JSON 序列化生成代码

/// 默认 API 基础地址，用于网络请求的默认服务器。
const String defaultApiBaseUrl = "https://api.ppanel.dev";

/// 备用域名，用于通过 DNS TXT 记录获取其他 API 地址。
const String fallbackDomain = "example.com";

/// 公共 DNS 服务地址列表，用于解析 TXT 记录以获取备用 API 地址。
const List<String> dnsServices = [
  "https://1.1.1.1/dns-query", // Cloudflare DNS
  "https://dns.google/resolve", // Google Public DNS
  "https://dns.adguard.com/dns-query", // AdGuard DNS
];

/// 检查指定 URL 的延迟和可用性。
/// - [url]: 要检查的 URL 地址。
/// - 返回: 延迟（毫秒），若不可用则返回 -1。
/// - 注意: 使用 HEAD 请求，超时设为 5 秒。
Future<int> _checkUrlLatency(String url) async {
  try {
    final stopwatch = Stopwatch()..start(); // 开始计时
    final response = await http.head(Uri.parse(url)).timeout(const Duration(seconds: 5));
    stopwatch.stop(); // 停止计时
    // 检查状态码是否在 200-299 范围内，表示可用
    return response.statusCode >= 200 && response.statusCode < 300
        ? stopwatch.elapsedMilliseconds
        : -1;
  } catch (e) {
    print("Failed to check $url: $e"); // 打印错误日志
    return -1; // 返回不可用标记
  }
}

/// 从多个 DNS 服务解析 fallbackDomain 的 TXT 记录，获取备用 API 地址。
/// - 返回: 包含备用 API 地址的列表，若失败则返回空列表。
/// - 逻辑: 遍历 dnsServices，发送 GET 请求并解析 JSON 响应。
Future<List<String>> _fetchTxtRecords() async {
  for (final dnsService in dnsServices) {
    try {
      final response = await http.get(
        Uri.parse('$dnsService?name=$fallbackDomain&type=TXT'),
        headers: dnsService.contains("dns-query") ? {'Accept': 'application/dns-json'} : null,
      ).timeout(const Duration(seconds: 10)); // 10 秒超时
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // 解析 JSON 响应
        final txtRecords = (data['Answer'] as List<dynamic>?) ?? []; // 获取 Answer 字段
        if (txtRecords.isEmpty) return []; // 无记录时返回空列表
        final txtData = txtRecords.first['data'] as String?; // 提取第一个 TXT 数据
        if (txtData == null || txtData.trim().isEmpty) return []; // 数据为空时返回空列表
        return txtData
            .split(' ') // 按空格分割
            .map((url) => 'https://$url') // 添加 HTTPS 前缀
            .where((url) => Uri.tryParse(url)?.isAbsolute == true) // 过滤有效 URL
            .toList();
      }
    } catch (e) {
      print("Failed to fetch TXT records from $dnsService: $e"); // 打印失败日志
    }
  }
  print("All DNS services failed to fetch TXT records"); // 所有服务失败时打印
  return []; // 返回空列表
}

// 默认应用设置，根据平台调整动画开关（桌面端禁用）。
final defaultAppSetting = const AppSetting().copyWith(
  isAnimateToPage: system.isDesktop ? false : true,
);

/// 默认仪表盘小部件列表，定义初始显示的内容。
const List<DashboardWidget> defaultDashboardWidgets = [
  DashboardWidget.networkSpeed,
  DashboardWidget.systemProxyButton,
  DashboardWidget.tunButton,
  DashboardWidget.outboundMode,
  DashboardWidget.networkDetection,
  DashboardWidget.trafficUsage,
  DashboardWidget.intranetIp,
];

/// 将 JSON 数据转换为 DashboardWidget 枚举列表。
/// - [dashboardWidgets]: 动态 JSON 数据。
/// - 返回: 解析后的小部件列表，若失败则返回默认值。
List<DashboardWidget> dashboardWidgetsRealFormJson(List<dynamic>? dashboardWidgets) {
  try {
    return dashboardWidgets
            ?.map((e) => $enumDecode(_$DashboardWidgetEnumMap, e)) // 枚举解码
            .toList() ??
        defaultDashboardWidgets;
  } catch (_) {
    return defaultDashboardWidgets; // 解析失败时返回默认值
  }
}

/// 应用设置模型，存储用户偏好设置。
@freezed
class AppSetting with _$AppSetting {
  const factory AppSetting({
    String? locale, // 语言设置
    @JsonKey(fromJson: dashboardWidgetsRealFormJson)
    @Default(defaultDashboardWidgets)
    List<DashboardWidget> dashboardWidgets, // 仪表盘小部件
    @Default(false) bool onlyStatisticsProxy, // 是否仅统计代理
    @Default(false) bool autoLaunch, // 自动启动
    @Default(false) bool silentLaunch, // 静默启动
    @Default(false) bool autoRun, // 开机自启
    @Default(false) bool openLogs, // 开启日志
    @Default(true) bool closeConnections, // 关闭连接
    @Default(defaultTestUrl) String testUrl, // 测试 URL
    @Default(true) bool isAnimateToPage, // 页面动画
    @Default(true) bool autoCheckUpdate, // 自动检查更新
    @Default(false) bool showLabel, // 显示标签
    @Default(false) bool disclaimerAccepted, // 免责声明接受
    @Default(true) bool minimizeOnExit, // 退出时最小化
    @Default(false) bool hidden, // 隐藏窗口
  }) = _AppSetting;

  factory AppSetting.fromJson(Map<String, Object?> json) => _$AppSettingFromJson(json);

  /// 从 JSON 创建实例，提供容错和平台适配。
  factory AppSetting.realFromJson(Map<String, Object?>? json) {
    final appSetting = json == null ? defaultAppSetting : AppSetting.fromJson(json);
    return appSetting.copyWith(
      isAnimateToPage: system.isDesktop ? false : appSetting.isAnimateToPage,
    );
  }
}

/// 访问控制模型，定义代理访问规则。
@freezed
class AccessControl with _$AccessControl {
  const factory AccessControl({
    @Default(AccessControlMode.rejectSelected) AccessControlMode mode, // 模式
    @Default([]) List<String> acceptList, // 接受列表
    @Default([]) List<String> rejectList, // 拒绝列表
    @Default(AccessSortType.none) AccessSortType sort, // 排序类型
    @Default(true) bool isFilterSystemApp, // 过滤系统应用
  }) = _AccessControl;

  factory AccessControl.fromJson(Map<String, Object?> json) => _$AccessControlFromJson(json);
}

/// 访问控制扩展，提供当前生效的列表。
extension AccessControlExt on AccessControl {
  List<String> get currentList => switch (mode) {
        AccessControlMode.acceptSelected => acceptList,
        AccessControlMode.rejectSelected => rejectList,
      };
}

/// 窗口属性模型，定义窗口大小和位置。
@freezed
class WindowProps with _$WindowProps {
  const factory WindowProps({
    @Default(900) double width, // 宽度
    @Default(600) double height, // 高度
    double? top, // 顶部位置
    double? left, // 左侧位置
  }) = _WindowProps;

  factory WindowProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const WindowProps() : _$WindowPropsFromJson(json);
}

/// 默认绕过域名列表，定义不需要代理的域名。
const defaultBypassDomain = [
  "*zhihu.com",
  "*zhimg.com",
  "*jd.com",
  "100ime-iat-api.xfyun.cn",
  "*360buyimg.com",
  "localhost",
  "*.local",
  "127.*",
  "10.*",
  "172.16.*",
  "172.17.*",
  "172.18.*",
  "172.19.*",
  "172.2*",
  "172.30.*",
  "172.31.*",
  "192.168.*"
];

/// 默认 VPN 属性。
const defaultVpnProps = VpnProps();

/// VPN 属性模型，定义 VPN 相关设置。
@freezed
class VpnProps with _$VpnProps {
  const factory VpnProps({
    @Default(true) bool enable, // 是否启用
    @Default(true) bool systemProxy, // 系统代理
    @Default(false) bool ipv6, // IPv6 支持
    @Default(true) bool allowBypass, // 允许绕过
  }) = _VpnProps;

  factory VpnProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const VpnProps() : _$VpnPropsFromJson(json);
}

/// 网络属性模型，定义网络代理设置。
@freezed
class NetworkProps with _$NetworkProps {
  const factory NetworkProps({
    @Default(true) bool systemProxy, // 系统代理
    @Default(defaultBypassDomain) List<String> bypassDomain, // 绕过域名
  }) = _NetworkProps;

  factory NetworkProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const NetworkProps() : _$NetworkPropsFromJson(json);
}

/// 默认代理样式。
const defaultProxiesStyle = ProxiesStyle();

/// 代理样式模型，定义代理显示样式。
@freezed
class ProxiesStyle with _$ProxiesStyle {
  const factory ProxiesStyle({
    @Default(ProxiesType.tab) ProxiesType type, // 类型
    @Default(ProxiesSortType.none) ProxiesSortType sortType, // 排序
    @Default(ProxiesLayout.standard) ProxiesLayout layout, // 布局
    @Default(ProxiesIconStyle.standard) ProxiesIconStyle iconStyle, // 图标样式
    @Default(ProxyCardType.expand) ProxyCardType cardType, // 卡片类型
    @Default({}) Map<String, String> iconMap, // 图标映射
  }) = _ProxiesStyle;

  factory ProxiesStyle.fromJson(Map<String, Object?>? json) =>
      json == null ? defaultProxiesStyle : _$ProxiesStyleFromJson(json);
}

/// 默认主题属性，根据平台调整字体和颜色。
final defaultThemeProps = Platform.isWindows
    ? const ThemeProps().copyWith(
        fontFamily: FontFamily.miSans,
        primaryColor: defaultPrimaryColor.value,
      )
    : const ThemeProps().copyWith(
        primaryColor: defaultPrimaryColor.value,
      );

/// 主题属性模型，定义 UI 主题设置。
@freezed
class ThemeProps with _$ThemeProps {
  const factory ThemeProps({
    int? primaryColor, // 主色值
    @Default(ThemeMode.system) ThemeMode themeMode, // 主题模式
    @Default(false) bool prueBlack, // 纯黑模式
    @Default(FontFamily.system) FontFamily fontFamily, // 字体
  }) = _ThemeProps;

  factory ThemeProps.fromJson(Map<String, Object?> json) => _$ThemePropsFromJson(json);

  /// 从 JSON 创建实例，提供容错处理。
  factory ThemeProps.realFromJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultThemeProps;
    }
    try {
      return ThemeProps.fromJson(json);
    } catch (_) {
      return defaultThemeProps; // 解析失败时返回默认值
    }
  }
}

/// 用户信息模型，存储用户认证数据。
@freezed
class User with _$User {
  const factory User({
    required String email, // 邮箱（必填）
    String? password, // 密码（可选）
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}

/// 配置类，管理应用的所有状态。
@JsonSerializable()
class Config extends ChangeNotifier {
  AppSetting _appSetting; // 应用设置
  List<Profile> _profiles; // 配置文件列表
  String? _currentProfileId; // 当前配置文件 ID
  bool _isAccessControl; // 是否启用访问控制（Android 专属）
  AccessControl _accessControl; // 访问控制设置
  DAV? _dav; // WebDAV 配置
  WindowProps _windowProps; // 窗口属性
  ThemeProps _themeProps; // 主题设置
  VpnProps _vpnProps; // VPN 设置
  NetworkProps _networkProps; // 网络设置
  bool _overrideDns; // 是否覆盖 DNS
  List<HotKeyAction> _hotKeyActions; // 快捷键动作
  ProxiesStyle _proxiesStyle; // 代理样式
  bool _isAuthenticated; // 认证状态
  String? _token; // 认证令牌
  User? _user; // 用户信息
  String _apiBaseUrl; // API 基础地址

  /// 默认构造函数，调用初始化方法。
  Config() : this._init();

  /// 初始化构造函数，设置默认值并启动 API 地址检测。
  Config._init()
      : _profiles = [],
        _isAccessControl = false,
        _accessControl = const AccessControl(),
        _windowProps = const WindowProps(),
        _vpnProps = defaultVpnProps,
        _networkProps = const NetworkProps(),
        _overrideDns = false,
        _appSetting = defaultAppSetting,
        _hotKeyActions = [],
        _proxiesStyle = defaultProxiesStyle,
        _themeProps = defaultThemeProps,
        _isAuthenticated = false,
        _token = null,
        _user = null,
        _apiBaseUrl = defaultApiBaseUrl {
    _initializeApiBaseUrl();
  }

  /// 初始化 API 地址，默认使用 defaultApiBaseUrl 并异步检测最佳地址。
  void _initializeApiBaseUrl() {
    _apiBaseUrl = defaultApiBaseUrl;
    Future.microtask(_updateToBestApiBaseUrl); // 在微任务中执行检测
  }

  /// 检测所有地址并切换到延迟最低的可用地址。
  Future<void> _updateToBestApiBaseUrl() async {
    final futures = <Future<Map<String, int>>>[
      _checkUrlLatency(defaultApiBaseUrl).then((latency) => {defaultApiBaseUrl: latency}),
      _fetchTxtRecords().then((urls) async {
        final results = <String, int>{};
        final latencyFutures = urls.map((url) => _checkUrlLatency(url).then((latency) => {url: latency}));
        final latencies = await Future.wait(latencyFutures);
        for (var latency in latencies) {
          results.addAll(latency);
        }
        return results;
      }),
    ];

    // 等待所有延迟检查完成
    final results = await Future.wait(futures);
    final allLatencies = <String, int>{};
    for (var result in results) {
      allLatencies.addAll(result);
    }

    // 选择延迟最低的可用地址
    String? bestUrl;
    int minLatency = -1;
    for (var entry in allLatencies.entries) {
      final latency = entry.value;
      if (latency >= 0 && (minLatency == -1 || latency < minLatency)) {
        minLatency = latency;
        bestUrl = entry.key;
      }
    }

    // 更新 API 地址并通知监听者
    if (bestUrl != null && bestUrl != _apiBaseUrl) {
      _apiBaseUrl = bestUrl;
      notifyListeners();
    }

    print("Selected API base URL: $_apiBaseUrl with latency: $minLatency ms");
  }

  @JsonKey(fromJson: AppSetting.realFromJson)
  AppSetting get appSetting => _appSetting;

  set appSetting(AppSetting value) {
    if (_appSetting != value) {
      _appSetting = value;
      notifyListeners(); // 通知 UI 更新
    }
  }

  /// 删除指定 ID 的配置文件。
  deleteProfileById(String id) {
    _profiles = profiles.where((element) => element.id != id).toList();
    notifyListeners();
  }

  /// 根据 ID 获取配置文件。
  Profile? getCurrentProfileForId(String? value) {
    if (value == null) return null;
    return _profiles.firstWhere((element) => element.id == value);
  }

  /// 获取当前配置文件。
  Profile? getCurrentProfile() {
    return getCurrentProfileForId(_currentProfileId);
  }

  /// 获取唯一标签，处理重复情况。
  String? _getLabel(String? label, String id) {
    final realLabel = label ?? id;
    final hasDup = _profiles.indexWhere(
            (element) => element.label == realLabel && element.id != id) != -1;
    if (hasDup) {
      return _getLabel(other.getOverwriteLabel(realLabel), id);
    } else {
      return label;
    }
  }

  /// 更新或添加配置文件（内部方法）。
  _setProfile(Profile profile) {
    final List<Profile> profilesTemp = List.from(_profiles);
    final index = profilesTemp.indexWhere((element) => element.id == profile.id);
    final updateProfile = profile.copyWith(
      label: _getLabel(profile.label, profile.id),
    );
    if (index == -1) {
      profilesTemp.add(updateProfile);
    } else {
      profilesTemp[index] = updateProfile;
    }
    _profiles = profilesTemp;
  }

  /// 更新或添加配置文件（公开方法）。
  setProfile(Profile profile) {
    _setProfile(profile);
    notifyListeners();
  }

  @JsonKey(defaultValue: [])
  List<Profile> get profiles => _profiles;

  set profiles(List<Profile> value) {
    if (_profiles != value) {
      _profiles = value;
      notifyListeners();
    }
  }

  String? get currentProfileId => _currentProfileId;

  set currentProfileId(String? value) {
    if (_currentProfileId != value) {
      _currentProfileId = value;
      notifyListeners();
    }
  }

  Profile? get currentProfile {
    final index = profiles.indexWhere((profile) => profile.id == _currentProfileId);
    return index == -1 ? null : profiles[index];
  }

  String? get currentGroupName => currentProfile?.currentGroupName;

  Set<String> get currentUnfoldSet => currentProfile?.unfoldSet ?? {};

  /// 更新当前配置的展开状态。
  updateCurrentUnfoldSet(Set<String> value) {
    if (!stringSetEquality.equals(currentUnfoldSet, value)) {
      _setProfile(
        currentProfile!.copyWith(unfoldSet: value),
      );
      notifyListeners();
    }
  }

  /// 更新当前配置的分组名称。
  updateCurrentGroupName(String groupName) {
    if (currentProfile != null && currentProfile!.currentGroupName != groupName) {
      _setProfile(
        currentProfile!.copyWith(currentGroupName: groupName),
      );
      notifyListeners();
    }
  }

  SelectedMap get currentSelectedMap {
    return currentProfile?.selectedMap ?? {};
  }

  /// 更新当前配置的代理选择。
  updateCurrentSelectedMap(String groupName, String proxyName) {
    if (currentProfile != null && currentProfile!.selectedMap[groupName] != proxyName) {
      final SelectedMap selectedMap = Map.from(currentProfile?.selectedMap ?? {})..[groupName] = proxyName;
      _setProfile(
        currentProfile!.copyWith(selectedMap: selectedMap),
      );
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: false)
  bool get isAccessControl {
    if (!Platform.isAndroid) return false; // 非 Android 平台禁用
    return _isAccessControl;
  }

  set isAccessControl(bool value) {
    if (_isAccessControl != value) {
      _isAccessControl = value;
      notifyListeners();
    }
  }

  AccessControl get accessControl => _accessControl;

  set accessControl(AccessControl value) {
    if (_accessControl != value) {
      _accessControl = value;
      notifyListeners();
    }
  }

  DAV? get dav => _dav;

  set dav(DAV? value) {
    if (_dav != value) {
      _dav = value;
      notifyListeners();
    }
  }

  WindowProps get windowProps => _windowProps;

  set windowProps(WindowProps value) {
    if (_windowProps != value) {
      _windowProps = value;
      notifyListeners();
    }
  }

  VpnProps get vpnProps => _vpnProps;

  set vpnProps(VpnProps value) {
    if (_vpnProps != value) {
      _vpnProps = value;
      notifyListeners();
    }
  }

  NetworkProps get networkProps => _networkProps;

  set networkProps(NetworkProps value) {
    if (_networkProps != value) {
      _networkProps = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: false)
  bool get overrideDns => _overrideDns;

  set overrideDns(bool value) {
    if (_overrideDns != value) {
      _overrideDns = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: [])
  List<HotKeyAction> get hotKeyActions => _hotKeyActions;

  set hotKeyActions(List<HotKeyAction> value) {
    if (_hotKeyActions != value) {
      _hotKeyActions = value;
      notifyListeners();
    }
  }

  ProxiesStyle get proxiesStyle => _proxiesStyle;

  set proxiesStyle(ProxiesStyle value) {
    if (_proxiesStyle != value ||
        !stringAndStringMapEntryIterableEquality.equals(_proxiesStyle.iconMap.entries, value.iconMap.entries)) {
      _proxiesStyle = value;
      notifyListeners();
    }
  }

  @JsonKey(fromJson: ThemeProps.realFromJson)
  ThemeProps get themeProps => _themeProps;

  set themeProps(ThemeProps value) {
    if (_themeProps != value) {
      _themeProps = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: false)
  bool get isAuthenticated => _isAuthenticated;

  set isAuthenticated(bool value) {
    if (_isAuthenticated != value) {
      _isAuthenticated = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: null)
  String? get token => _token;

  set token(String? value) {
    if (_token != value) {
      _token = value;
      notifyListeners();
    }
  }

  User? get user => _user;

  set user(User? value) {
    if (_user != value) {
      _user = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: defaultApiBaseUrl)
  String get apiBaseUrl => _apiBaseUrl;

  set apiBaseUrl(String value) {
    if (!Uri.parse(value).isAbsolute) {
      throw ArgumentError("Invalid API base URL: $value"); // 验证 URL 有效性
    }
    if (_apiBaseUrl != value) {
      _apiBaseUrl = value;
      notifyListeners();
    }
  }

  /// 更新或添加快捷键动作。
  updateOrAddHotKeyAction(HotKeyAction hotKeyAction) {
    final index = _hotKeyActions.indexWhere((item) => item.action == hotKeyAction.action);
    if (index == -1) {
      _hotKeyActions = List.from(_hotKeyActions)..add(hotKeyAction);
    } else {
      _hotKeyActions = List.from(_hotKeyActions)..[index] = hotKeyAction;
    }
    notifyListeners();
  }

  /// 从另一个 Config 对象更新状态，支持部分更新。
  update([
    Config? config,
    RecoveryOption recoveryOptions = RecoveryOption.all,
  ]) {
    if (config != null) {
      _profiles = config._profiles;
      for (final profile in config._profiles) {
        _setProfile(profile);
      }
      final onlyProfiles = recoveryOptions == RecoveryOption.onlyProfiles;
      if (_currentProfileId == null && onlyProfiles && profiles.isNotEmpty) {
        _currentProfileId = _profiles.first.id;
      }
      if (onlyProfiles) return;
      _appSetting = config._appSetting;
      _currentProfileId = config._currentProfileId;
      _dav = config._dav;
      _isAccessControl = config._isAccessControl;
      _accessControl = config._accessControl;
      _themeProps = config._themeProps;
      _windowProps = config._windowProps;
      _proxiesStyle = config._proxiesStyle;
      _vpnProps = config._vpnProps;
      _overrideDns = config._overrideDns;
      _networkProps = config._networkProps;
      _hotKeyActions = config._hotKeyActions;
      _isAuthenticated = config._isAuthenticated;
      _token = config._token;
      _user = config._user;
      _apiBaseUrl = config._apiBaseUrl;
    }
    notifyListeners();
  }

  /// 转换为 JSON。
  Map<String, dynamic> toJson() {
    return _$ConfigToJson(this);
  }

  /// 从 JSON 创建实例。
  factory Config.fromJson(Map<String, dynamic> json) {
    return _$ConfigFromJson(json);
  }

  @override
  String toString() {
    return 'Config{_appSetting: $_appSetting, _profiles: $_profiles, _currentProfileId: $_currentProfileId, '
        '_isAccessControl: $_isAccessControl, _accessControl: $_accessControl, _dav: $_dav, '
        '_windowProps: $_windowProps, _themeProps: $_themeProps, _vpnProps: $_vpnProps, '
        '_networkProps: $_networkProps, _overrideDns: $_overrideDns, _hotKeyActions: $_hotKeyActions, '
        '_proxiesStyle: $_proxiesStyle, _isAuthenticated: $_isAuthenticated, _token: $_token, '
        '_user: $_user, _apiBaseUrl: $_apiBaseUrl}';
  }
}
