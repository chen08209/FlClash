class EndpointInfo {
  final int id;
  final String name;
  final String point;
  final String tags;
  final int isActive;
  final int? successCount;
  final String createdAt;
  final String updatedAt;
  final String responseTime;
  final int priority;
  // 本地计算的延迟时间（毫秒），用于排序
  final int latencyMs;
  // 是否在线
  final bool isOnline;
  // 最后测试时间
  final String? lastTestedAt;

  const EndpointInfo({
    required this.id,
    required this.name,
    required this.point,
    required this.tags,
    required this.isActive,
    this.successCount,
    required this.createdAt,
    required this.updatedAt,
    required this.responseTime,
    required this.priority,
    this.latencyMs = 999999,
    this.isOnline = false,
    this.lastTestedAt,
  });

  factory EndpointInfo.fromJson(Map<String, dynamic> json) {
    return EndpointInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      point: json['point'] as String,
      tags: json['tags'] as String,
      isActive: json['isActive'] as int,
      successCount: json['successCount'] as int?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      responseTime: json['responseTime'] as String,
      priority: json['priority'] as int,
      latencyMs: json['latencyMs'] as int? ?? 999999,
      isOnline: json['isOnline'] as bool? ?? false,
      lastTestedAt: json['lastTestedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'point': point,
      'tags': tags,
      'isActive': isActive,
      'successCount': successCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'responseTime': responseTime,
      'priority': priority,
      'latencyMs': latencyMs,
      'isOnline': isOnline,
      'lastTestedAt': lastTestedAt,
    };
  }

  EndpointInfo copyWith({
    int? id,
    String? name,
    String? point,
    String? tags,
    int? isActive,
    int? successCount,
    String? createdAt,
    String? updatedAt,
    String? responseTime,
    int? priority,
    int? latencyMs,
    bool? isOnline,
    String? lastTestedAt,
  }) {
    return EndpointInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      point: point ?? this.point,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      successCount: successCount ?? this.successCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      responseTime: responseTime ?? this.responseTime,
      priority: priority ?? this.priority,
      latencyMs: latencyMs ?? this.latencyMs,
      isOnline: isOnline ?? this.isOnline,
      lastTestedAt: lastTestedAt ?? this.lastTestedAt,
    );
  }
}

class EndpointListResponse {
  final int code;
  final String msg;
  final List<EndpointInfo> data;

  const EndpointListResponse({
    required this.code,
    required this.msg,
    required this.data,
  });

  factory EndpointListResponse.fromJson(Map<String, dynamic> json) {
    return EndpointListResponse(
      code: json['code'] as int,
      msg: json['msg'] as String,
      data: (json['data'] as List)
          .map((item) => EndpointInfo.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class EndpointTestResponse {
  final int code;
  final String msg;
  final String data;

  const EndpointTestResponse({
    required this.code,
    required this.msg,
    required this.data,
  });

  factory EndpointTestResponse.fromJson(Map<String, dynamic> json) {
    return EndpointTestResponse(
      code: json['code'] as int,
      msg: json['msg'] as String,
      data: json['data'] as String,
    );
  }
}
