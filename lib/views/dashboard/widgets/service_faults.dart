import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

import 'status_badge.dart';

/// The dashboard's bar badge for services that did not start; a tap lists
/// them. The dashboard leaves it out while there are none.
class ServiceFaultsButton extends StatelessWidget {
  const ServiceFaultsButton(this.faults, {super.key});

  final List<ServiceFault> faults;

  Future<void> _handlePressed() {
    return dialogs.showAlert(
      title: currentAppLocalizations.serviceFaults,
      message: TextSpan(
        text: faults
            .map((fault) => '${fault.serviceLabel}\n${fault.reasonLabel}')
            .join('\n\n'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return StatusBadge(
      tooltip: context.appLocalizations.serviceFaults,
      glyph: AppGlyphs.error,
      label: '${faults.length}',
      background: colorScheme.errorContainer,
      foreground: colorScheme.onErrorContainer,
      onPressed: () => unawaited(_handlePressed()),
    );
  }
}
