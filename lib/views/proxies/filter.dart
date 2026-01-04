import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProxiesFilterButton extends ConsumerWidget {
  const ProxiesFilterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(proxyViewModeStateProvider);
    return CommonPopupBox(
      targetBuilder: (open) {
        return IconButton(
          onPressed: () {
            final isMobile = ref.read(isMobileViewProvider);
            open(offset: Offset(0, isMobile ? 0 : 20));
          },
          icon: Icon(
            switch (viewMode) {
              ProxyViewMode.active => Icons.filter_alt_off_outlined,
              ProxyViewMode.archived => Icons.archive_outlined,
              ProxyViewMode.all => Icons.filter_alt_outlined,
            },
            weight: 1,
          ),
        );
      },
      popup: CommonPopupMenu(
        items: [
          PopupMenuItemData(
            label: appLocalizations.activeProxies,
            icon: Icons.filter_alt_off_outlined,
            onPressed: () {
              ref
                  .read(proxyViewModeStateProvider.notifier)
                  .update((state) => ProxyViewMode.active);
            },
          ),
          PopupMenuItemData(
            label: appLocalizations.allProxies,
            icon: Icons.filter_alt_outlined,
            onPressed: () {
              ref
                  .read(proxyViewModeStateProvider.notifier)
                  .update((state) => ProxyViewMode.all);
            },
          ),
          PopupMenuItemData(
            label: appLocalizations.archivedProxies,
            icon: Icons.archive_outlined,
            onPressed: () {
              ref
                  .read(proxyViewModeStateProvider.notifier)
                  .update((state) => ProxyViewMode.archived);
            },
          ),
        ],
      ),
    );
  }
}
