import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteProxies extends ConsumerWidget {
  const FavoriteProxies({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteProxiesProvider);
    final groups = ref.watch(groupsProvider);
    return CommonCard(
      info: Info(
        label: context.appLocalizations.favoriteProxies,
        iconData: Icons.star,
      ),
      child: Padding(
        padding: baseInfoEdgeInsets.copyWith(top: 8),
        child: favorites.isEmpty
            ? _FavoriteProxiesEmpty(
                label: context.appLocalizations.favoriteProxiesEmpty,
              )
            : LayoutBuilder(
                builder: (_, constraints) {
                  final columns = constraints.maxWidth < 480 ? 2 : 4;
                  return Grid.baseGap(
                    crossAxisCount: columns,
                    children: favorites.map((favorite) {
                      final group = groups.getGroup(favorite.groupName)!;
                      final proxy = group.all.firstWhere(
                        (proxy) => proxy.name == favorite.proxyName,
                      );
                      return _FavoriteProxyItem(
                        favorite: favorite,
                        proxy: proxy,
                        testUrl: group.testUrl,
                      );
                    }).toList(),
                  );
                },
              ),
      ),
    );
  }
}

class _FavoriteProxiesEmpty extends StatelessWidget {
  final String label;

  const _FavoriteProxiesEmpty({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(1) - 56,
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _FavoriteProxyItem extends ConsumerWidget {
  final FavoriteProxy favorite;
  final Proxy proxy;
  final String? testUrl;

  const _FavoriteProxyItem({
    required this.favorite,
    required this.proxy,
    required this.testUrl,
  });

  void _handleChangeProxy() {
    final ref = globalState.container;
    ref
        .read(profilesActionProvider.notifier)
        .updateCurrentSelectedMap(favorite.groupName, favorite.proxyName);
    ref
        .read(proxiesActionProvider.notifier)
        .changeProxyDebounce(favorite.groupName, favorite.proxyName);
  }

  void _handleDelayTest() {
    proxyDelayTest(proxy, testUrl);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProxyName = ref.watch(
      selectedProxyNameProvider(favorite.groupName),
    );
    final delay = ref.watch(
      delayProvider(proxyName: favorite.proxyName, testUrl: testUrl),
    );
    return CommonCard(
      type: CommonCardType.filled,
      isSelected: selectedProxyName == favorite.proxyName,
      onPressed: _handleChangeProxy,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              favorite.groupName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            EmojiText(
              favorite.proxyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.toSoftBold,
            ),
            const SizedBox(height: 6),
            _FavoriteProxyDelay(delay: delay, onPressed: _handleDelayTest),
          ],
        ),
      ),
    );
  }
}

class _FavoriteProxyDelay extends StatelessWidget {
  final int? delay;
  final VoidCallback onPressed;

  const _FavoriteProxyDelay({required this.delay, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (delay == 0) {
      return SizedBox.square(
        dimension: globalState.measure.labelSmallHeight,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return InkWell(
      onTap: onPressed,
      child: delay == null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 16),
                const SizedBox(width: 2),
                Text(
                  context.appLocalizations.delay,
                  style: context.textTheme.labelSmall,
                ),
              ],
            )
          : Text(
              delay! > 0 ? '${delay!} ms' : context.appLocalizations.timeout,
              style: context.textTheme.labelSmall?.copyWith(
                color: utils.getDelayColor(delay!),
              ),
            ),
    );
  }
}
