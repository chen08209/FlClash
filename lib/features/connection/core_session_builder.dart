import 'package:fl_clash/providers/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Builds with whether the Core session it first built in has ended.
class CoreSessionBuilder extends ConsumerStatefulWidget {
  final Widget Function(BuildContext context, WidgetRef ref, bool ended)
  builder;

  const CoreSessionBuilder({super.key, required this.builder});

  @override
  ConsumerState<CoreSessionBuilder> createState() => _CoreSessionBuilderState();
}

class _CoreSessionBuilderState extends ConsumerState<CoreSessionBuilder> {
  late final _ended = ref.read(endedCoreSessionsProvider);

  @override
  Widget build(BuildContext context) => widget.builder(
    context,
    ref,
    ref.watch(endedCoreSessionsProvider) != _ended,
  );
}
