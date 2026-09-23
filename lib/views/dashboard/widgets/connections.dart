import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/views/connection/connections.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feed_card.dart';

class ConnectionsCard extends ConsumerStatefulWidget {
  final Future<int> Function()? countReader;

  const ConnectionsCard({super.key, @visibleForTesting this.countReader});

  @override
  ConsumerState<ConnectionsCard> createState() => _ConnectionsCardState();
}

class _ConnectionsCardState extends ConsumerState<ConnectionsCard>
    with WidgetsBindingObserver, ActivePollingMixin<ConnectionsCard> {
  final _countNotifier = ValueNotifier(0);

  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  Duration get pollInterval => const Duration(seconds: 2);

  @override
  void dispose() {
    _countNotifier.dispose();
    super.dispose();
  }

  @override
  Future<void> poll(PollGuard isCurrent) async {
    final count = await _readCount();
    if (count == null || !isCurrent()) {
      return;
    }
    _countNotifier.value = count;
  }

  Future<int?> _readCount() async {
    final countReader = widget.countReader;
    if (countReader == null &&
        ref.read(coreStatusProvider) != CoreStatus.connected) {
      return 0;
    }
    try {
      return await (countReader ?? _core.getConnectionCount)();
    } catch (error) {
      commonPrint.log(
        'updateConnectionCount error: $error',
        logLevel: coreFailureLogLevel(error),
      );
      return null;
    }
  }

  void _openConnections(BuildContext context) {
    showSnapSheet(
      context,
      builder: (_, controller) => ConnectionsView(scrollController: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FeedCard(
      label: PageLabel.connections.label,
      glyph: AppGlyphs.connections,
      onPressed: () => _openConnections(context),
      child: ValueListenableBuilder(
        valueListenable: _countNotifier,
        builder: (_, count, _) => FeedCount(count: count),
      ),
    );
  }
}
