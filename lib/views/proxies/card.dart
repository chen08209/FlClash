import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/tech_theme.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProxyCard extends StatelessWidget {
  final String groupName;
  final Proxy proxy;
  final GroupType groupType;
  final ProxyCardType type;
  final String? testUrl;

  const ProxyCard({
    super.key,
    required this.groupName,
    required this.testUrl,
    required this.proxy,
    required this.groupType,
    required this.type,
  });

  Measure get measure => globalState.measure;

  _handleTestCurrentDelay() {
    proxyDelayTest(
      proxy,
      testUrl,
    );
  }

  Widget _buildDelayText() {
    return Consumer(
      builder: (context, ref, __) {
        final delay = ref.watch(getDelayProvider(
          proxyName: proxy.name,
          testUrl: testUrl,
        ));
        return delay == 0 || delay == null
            ? SizedBox(
                height: 16,
                width: 16,
                child: delay == 0
                    ? CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(TechTheme.primaryCyan),
                      )
                    : GestureDetector(
                        onTap: _handleTestCurrentDelay,
                        child: Icon(
                          Icons.bolt,
                          color: TechTheme.neonOrange,
                          size: 12,
                        ),
                      ),
              )
            : GestureDetector(
                onTap: _handleTestCurrentDelay,
                child: Text(
                  delay > 0 ? '${delay}ms' : "Timeout",
                  style: TechTheme.techTextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: utils.getDelayColor(delay) ?? TechTheme.neonOrange,
                  ),
                ),
              );
      },
    );
  }

  Widget _buildProxyNameText(BuildContext context) {
    return Flexible(
      child: EmojiText(
        proxy.name,
        maxLines: 1, // 强制所有卡片都只显示一行
        overflow: TextOverflow.ellipsis,
        style: TechTheme.techTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  _changeProxy(WidgetRef ref) async {
    final isComputedSelected = groupType.isComputedSelected;
    final isSelector = groupType == GroupType.Selector;
    if (isComputedSelected || isSelector) {
      final currentProxyName = ref.read(getProxyNameProvider(groupName));
      final nextProxyName = switch (isComputedSelected) {
        true => currentProxyName == proxy.name ? "" : proxy.name,
        false => proxy.name,
      };
      final appController = globalState.appController;
      appController.updateCurrentSelectedMap(
        groupName,
        nextProxyName,
      );
      await appController.changeProxyDebounce(groupName, nextProxyName);
      return;
    }
    globalState.showNotifier(
      appLocalizations.notSelectedTip,
    );
  }

  @override
  Widget build(BuildContext context) {
    final measure = globalState.measure;
    final delayText = _buildDelayText();
    final proxyNameText = _buildProxyNameText(context);
    return Stack(
      children: [
        Consumer(
          builder: (_, ref, child) {
            final selectedProxyName =
                ref.watch(getSelectedProxyNameProvider(groupName));
            final isSelected = selectedProxyName == proxy.name;
            return TechTheme.techCard(
              animated: true,
              accentColor: isSelected ? TechTheme.primaryCyan : TechTheme.primaryPurple.withOpacity(0.6),
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _changeProxy(ref),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 代理类型图标
                          Icon(
                            _getProxyTypeIcon(proxy.type),
                            size: 12,
                            color: isSelected ? TechTheme.primaryCyan : TechTheme.primaryPurple,
                          ),
                          const SizedBox(width: 6),
                          proxyNameText,
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                color: TechTheme.primaryCyan.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: TechTheme.primaryCyan, width: 0.5),
                              ),
                              child: Text(
                                '✓',
                                style: TechTheme.techTextStyle(
                                  fontSize: 8,
                                  color: TechTheme.primaryCyan,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      if (type == ProxyCardType.expand) ...[
                        _ProxyDesc(proxy: proxy),
                        const SizedBox(height: 2),
                        delayText,
                      ] else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              proxy.type,
                              style: TechTheme.techTextStyle(
                                fontSize: 8,
                                color: TechTheme.neonGreen,
                              ),
                            ),
                            delayText,
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getProxyTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'ss':
      case 'shadowsocks':
        return Icons.security;
      case 'vmess':
      case 'vless':
        return Icons.vpn_lock;
      case 'trojan':
        return Icons.shield;
      case 'hysteria':
      case 'hysteria2':
        return Icons.flash_on;
      case 'direct':
        return Icons.call_made;
      case 'reject':
        return Icons.block;
      default:
        return Icons.router;
    }
  }
}

class _ProxyDesc extends ConsumerWidget {
  final Proxy proxy;

  const _ProxyDesc({
    required this.proxy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final desc = ref.watch(
      getProxyDescProvider(proxy),
    );
    return EmojiText(
      desc,
      overflow: TextOverflow.ellipsis,
      style: TechTheme.techTextStyle(
        fontSize: 12,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }
}

class _ProxyComputedMark extends ConsumerWidget {
  final String groupName;
  final Proxy proxy;

  const _ProxyComputedMark({
    required this.groupName,
    required this.proxy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxyName = ref.watch(
      getProxyNameProvider(groupName),
    );
    if (proxyName != proxy.name) {
      return SizedBox();
    }
    return Container(
      alignment: Alignment.topRight,
      margin: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: TechTheme.primaryCyan.withOpacity(0.2),
          border: Border.all(
            color: TechTheme.primaryCyan,
            width: 2,
          ),
        ),
        child: Icon(
          Icons.check,
          size: 12,
          color: TechTheme.primaryCyan,
        ),
      ),
    );
  }
}
