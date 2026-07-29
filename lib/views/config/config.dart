import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/general.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ConfigView extends StatelessWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: AppBar(
        titleSpacing: 24,
        toolbarHeight: 86,
        centerTitle: false,
        title: const _ConfigTitleBar(),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: _AirportPattern())),
          generateListView(generalItems),
        ],
      ),
    );
  }
}

Widget buildConfigTitleBarForTesting() => const _ConfigTitleBar();

class _ConfigTitleBar extends StatelessWidget {
  const _ConfigTitleBar();

  Widget _buildLink(
    BuildContext context,
    String text,
    String url, {
    required Key key,
  }) {
    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(8),
      onTap: () => globalState.openUrl(url, confirm: false),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colorScheme.outlineVariant),
          color: context.colorScheme.surfaceContainerHighest.opacity80,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.appLocalizations.basicConfig,
                key: const Key('config_title_label'),
                style: context.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildLink(
                            context,
                            '优质机场',
                            'https://jichangtuijian.com/ssr-v2ray%E4%B8%93%E7%BA%BF%E6%9C%BA%E5%9C%BA%E6%8E%A8%E8%8D%90.html',
                            key: const Key('config_title_quality_airport_link'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildLink(
                            context,
                            '便宜机场',
                            'https://maomeng.cc/2021/06/11/ji-chang-tui-jian-chang-qi-geng-xin/',
                            key: const Key('config_title_budget_airport_link'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '不要轻易购买小于0.05元/G的机场',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.error,
                        fontSize: 13,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AirportPattern extends StatelessWidget {
  const _AirportPattern();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 64, right: 18),
        child: Opacity(
          opacity: 0.16,
          child: CustomPaint(
            size: const Size(220, 190),
            painter: _AirportPatternPainter(context.colorScheme),
          ),
        ),
      ),
    );
  }
}

class _AirportPatternPainter extends CustomPainter {
  final ColorScheme colorScheme;

  const _AirportPatternPainter(this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width * 0.24;
    final centers = [
      Offset(size.width * 0.42, size.height * 0.38),
      Offset(size.width * 0.58, size.height * 0.38),
      Offset(size.width * 0.50, size.height * 0.57),
    ];
    final colors = [Colors.green, colorScheme.primary, Colors.orange];
    final labels = ['便宜', '稳定', '高速'];
    for (var i = 0; i < centers.length; i++) {
      final paint = Paint()
        ..color = colors[i].withValues(alpha: 0.45)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(centers[i], radius, paint);
      _drawText(canvas, labels[i], centers[i], colorScheme.onSurface);
    }
    _drawText(
      canvas,
      '易跑路',
      Offset(size.width * 0.50, size.height * 0.45),
      colorScheme.error,
      bold: true,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    Color color, {
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: bold ? 14 : 13,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _AirportPatternPainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme;
  }
}
