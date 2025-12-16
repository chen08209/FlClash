import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

import 'builder.dart';

class CommonFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Icon icon;
  final String label;

  const CommonFloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        floatingActionButtonTheme: Theme.of(context).floatingActionButtonTheme
            .copyWith(
              extendedIconLabelSpacing: 0,
              extendedPadding: EdgeInsets.all(16),
            ),
      ),
      child: FloatingActionButtonExtendedBuilder(
        builder: (isExtended) {
          return FloatingActionButton.extended(
            heroTag: null,
            icon: icon,
            onPressed: onPressed,
            isExtended: true,
            label: AnimatedSize(
              alignment: Alignment.centerLeft,
              duration: midDuration,
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                duration: midDuration,
                opacity: isExtended ? 1.0 : 0.4,
                curve: Curves.linear,
                child: isExtended
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(label, softWrap: false),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }
}
