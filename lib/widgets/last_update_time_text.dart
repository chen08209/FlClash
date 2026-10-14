import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

import 'active_polling.dart';

class LastUpdateTimeText extends StatelessWidget {
  final DateTime? lastUpdateDate;
  final TextStyle? style;
  final bool compact;

  const LastUpdateTimeText({
    super.key,
    required this.lastUpdateDate,
    this.style,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (lastUpdateDate == null) {
      return Text('', style: style);
    }
    return TickBuilder(
      duration: const Duration(minutes: 1),
      builder: (context, _) {
        return Text(
          lastUpdateDate!.getLastUpdateTimeDesc(context, compact: compact),
          style: style,
        );
      },
    );
  }
}
