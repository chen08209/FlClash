/// 公告数据模型
class Notice {
  final int id;
  final String title;
  final String content;
  final int show; // 是否显示，1为显示，0为不显示
  final String? imgUrl; // 图片URL（可选）
  final String? tags; // 标签（可选）
  final int createdAt; // 创建时间戳
  final int updatedAt; // 更新时间戳

  const Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.show,
    this.imgUrl,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从JSON创建Notice对象
  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      show: json['show'] as int,
      imgUrl: json['img_url'] as String?,
      tags: json['tags'] as String?,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'show': show,
      'img_url': imgUrl,
      'tags': tags,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// 获取格式化的创建时间
  DateTime get createdDate => DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
  
  /// 获取格式化的更新时间
  DateTime get updatedDate => DateTime.fromMillisecondsSinceEpoch(updatedAt * 1000);

  /// 是否应该显示这个公告
  bool get shouldShow => show == 1;

  /// 创建一个副本，允许修改某些字段
  Notice copyWith({
    int? id,
    String? title,
    String? content,
    int? show,
    String? imgUrl,
    String? tags,
    int? createdAt,
    int? updatedAt,
  }) {
    return Notice(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      show: show ?? this.show,
      imgUrl: imgUrl ?? this.imgUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Notice && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Notice{id: $id, title: $title, content: $content, show: $show, imgUrl: $imgUrl, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}

/// 公告列表响应模型
class NoticeListResponse {
  final List<Notice> data;
  final int total;

  const NoticeListResponse({
    required this.data,
    required this.total,
  });

  /// 从JSON创建NoticeListResponse对象
  factory NoticeListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> noticesJson = json['data'] as List<dynamic>;
    final notices = noticesJson
        .map((noticeJson) => Notice.fromJson(noticeJson as Map<String, dynamic>))
        .where((notice) => notice.shouldShow) // 只返回应该显示的公告
        .toList();

    // 按更新时间倒序排序（最新的在前面）
    notices.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return NoticeListResponse(
      data: notices,
      total: json['total'] as int,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data.map((notice) => notice.toJson()).toList(),
      'total': total,
    };
  }

  /// 获取有效的公告数量
  int get validCount => data.length;

  /// 是否有公告
  bool get hasNotices => data.isNotEmpty;

  @override
  String toString() {
    return 'NoticeListResponse{data: $data, total: $total}';
  }
}
