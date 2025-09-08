class PaymentMethod {
  final int id;
  final String name;
  final String payment;
  final String? icon;
  final int? handlingFeeFixed;
  final int? handlingFeePercent;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.payment,
    this.icon,
    this.handlingFeeFixed,
    this.handlingFeePercent,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as int,
      name: json['name'] as String,
      payment: json['payment'] as String,
      icon: json['icon'] as String?,
      handlingFeeFixed: json['handling_fee_fixed'] as int?,
      handlingFeePercent: json['handling_fee_percent'] as int?,
    );
  }

  // 格式化手续费显示
  String get formattedHandlingFee {
    if (handlingFeeFixed != null && handlingFeeFixed! > 0) {
      return '固定手续费 ¥${(handlingFeeFixed! / 100).toStringAsFixed(2)}';
    } else if (handlingFeePercent != null && handlingFeePercent! > 0) {
      return '手续费 ${handlingFeePercent}%';
    } else {
      return '无手续费';
    }
  }

  // 是否有手续费
  bool get hasHandlingFee {
    return (handlingFeeFixed != null && handlingFeeFixed! > 0) ||
           (handlingFeePercent != null && handlingFeePercent! > 0);
  }
}

enum PaymentResultType {
  qrcode,    // 二维码支付
  url,       // URL跳转支付
  completed, // 订单已完成支付（优惠码全额抵扣）
}

class PaymentResult {
  final PaymentResultType type;
  final String? data; // 二维码内容或支付URL，completed类型时为null
  final bool? completed; // 当type为completed时表示是否成功

  PaymentResult({
    required this.type,
    this.data,
    this.completed,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    final type = _parsePaymentResultType(json['type'] as int);
    
    if (type == PaymentResultType.completed) {
      return PaymentResult(
        type: type,
        completed: json['data'] as bool? ?? false,
      );
    } else {
      return PaymentResult(
        type: type,
        data: json['data'] as String,
      );
    }
  }

  static PaymentResultType _parsePaymentResultType(int type) {
    switch (type) {
      case 0:
        return PaymentResultType.qrcode;
      case 1:
        return PaymentResultType.url;
      case -1:
        return PaymentResultType.completed;
      default:
        return PaymentResultType.qrcode;
    }
  }

  // 获取支付类型文本
  String get typeText {
    switch (type) {
      case PaymentResultType.qrcode:
        return '扫码支付';
      case PaymentResultType.url:
        return 'URL支付';
      case PaymentResultType.completed:
        return '支付完成';
    }
  }
}
