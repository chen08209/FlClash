/// 关于信息数据模型
class AboutInfo {
  final int id;
  final String key;
  final String value;

  const AboutInfo({
    required this.id,
    required this.key,
    required this.value,
  });

  /// 从JSON创建AboutInfo对象
  factory AboutInfo.fromJson(Map<String, dynamic> json) {
    return AboutInfo(
      id: json['id'] as int,
      key: json['key'] as String,
      value: json['value'] as String,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'value': value,
    };
  }

  /// 是否是链接类型
  bool get isLink => value.startsWith('http://') || value.startsWith('https://') || value.startsWith('mailto:');

  /// 是否是邮箱
  bool get isEmail => value.contains('@') && !value.startsWith('http');

  /// 是否是Telegram链接
  bool get isTelegram => value.contains('t.me');

  /// 获取显示图标
  String get displayIcon {
    if (isTelegram) {
      return '📱'; // Telegram图标
    } else if (isEmail) {
      return '📧'; // 邮箱图标
    } else if (isLink) {
      return '🔗'; // 链接图标
    } else {
      return 'ℹ️'; // 信息图标
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AboutInfo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AboutInfo{id: $id, key: $key, value: $value}';
  }
}

/// 关于信息响应模型
class AboutInfoResponse {
  final int code;
  final String message;
  final List<AboutInfo> data;

  const AboutInfoResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  /// 从JSON创建AboutInfoResponse对象
  factory AboutInfoResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataJson = json['data'] as List<dynamic>;
    final aboutInfos = dataJson
        .map((item) => AboutInfo.fromJson(item as Map<String, dynamic>))
        .toList();

    return AboutInfoResponse(
      code: json['code'] as int,
      message: json['msg'] as String,
      data: aboutInfos,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }

  /// 是否成功
  bool get isSuccess => code == 200;

  /// 是否有数据
  bool get hasData => data.isNotEmpty;

  @override
  String toString() {
    return 'AboutInfoResponse{code: $code, message: $message, data: $data}';
  }
}
