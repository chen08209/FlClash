import 'dart:async';

import 'package:fl_clash/ai_mcp/service.dart';
import 'package:fl_clash/providers/ai_mcp.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiMcpManager extends ConsumerStatefulWidget {
  const AiMcpManager({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AiMcpManager> createState() => _AiMcpManagerState();
}

class _AiMcpManagerState extends ConsumerState<AiMcpManager> {
  late final AiMcpService _service;

  @override
  void initState() {
    super.initState();
    _service = ref.read(aiMcpServiceProvider);
    unawaited(_service.initialize());
  }

  @override
  void dispose() {
    unawaited(_service.setEnabled(false));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
