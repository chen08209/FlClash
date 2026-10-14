import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/ip_quality.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'labels.dart';

class IpQualityText extends ConsumerWidget {
  const IpQualityText({super.key, required this.ip, this.style});

  final String ip;
  final TextStyle? style;

  static const _mask = '*****';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quality = ref.watch(ipQualityProvider(ip)).value;
    final hideIp = ref.watch(
      appSettingProvider.select((state) => state.hideIp),
    );
    final shownIp = hideIp ? _mask : ip;
    final color = quality?.level.color(context);
    var style = this.style;
    if (hideIp) {
      style = (style ?? const TextStyle()).toJetBrainsMono;
    }
    if (color != null) {
      style = (style ?? const TextStyle()).copyWith(color: color);
    }
    return Tooltip(
      preferBelow: false,
      message: shownIp,
      child: Text(
        shownIp,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
