import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class NullStatus extends StatelessWidget {
  final String label;
  final Widget illustration;

  const NullStatus({
    super.key,
    required this.label,
    this.illustration = const DataEmptyIllustration(),
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0.0, -0.25),
      child: Wrap(
        direction: Axis.vertical,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          illustration,
          SizedBox(height: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.toBold.toLight,
          ),
        ],
      ),
    );
  }
}

class LogEmptyIllustration extends StatelessWidget {
  const LogEmptyIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: context.colorScheme.primaryContainer,
        shape: StarBorder(
          points: 5,
          innerRadiusRatio: 0.8,
          pointRounding: 0.7,
          valleyRounding: 0.1,
          squash: 0.5,
        ),
      ),
      child: _ThemeAwareSvg('assets/images/empty/log.svg'),
    );
  }
}

class ProxyEmptyIllustration extends StatelessWidget {
  const ProxyEmptyIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: context.colorScheme.secondaryContainer,
        shape: StarBorder(
          points: 12,
          innerRadiusRatio: 0.8,
          pointRounding: 0.5,
          valleyRounding: 0.4,
          squash: 0.6,
        ),
      ),
      child: _ThemeAwareSvg('assets/images/empty/proxy.svg'),
    );
  }
}

class DataEmptyIllustration extends StatelessWidget {
  const DataEmptyIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: context.colorScheme.secondaryContainer,
        shape: StarBorder(
          points: 3,
          innerRadiusRatio: 1,
          pointRounding: 0.3,
          valleyRounding: 0.5,
          squash: 0.2,
        ),
      ),
      child: _ThemeAwareSvg('assets/images/empty/data.svg'),
    );
  }
}

class ProfileEmptyIllustration extends StatelessWidget {
  const ProfileEmptyIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: context.colorScheme.secondaryContainer,
        shape: StarBorder(
          points: 8,
          innerRadiusRatio: 0.6,
          pointRounding: 1,
          valleyRounding: 0,
          squash: 1,
        ),
      ),
      child: _ThemeAwareSvg('assets/images/empty/profile.svg'),
    );
  }
}

class ScriptEmptyIllustration extends StatelessWidget {
  const ScriptEmptyIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: context.colorScheme.secondaryContainer,
        shape: StarBorder(
          points: 3,
          innerRadiusRatio: 0.6,
          pointRounding: 0.6,
          valleyRounding: 0.2,
          squash: 0.1,
        ),
      ),
      child: _ThemeAwareSvg('assets/images/empty/script.svg'),
    );
  }
}

class RuleEmptyIllustration extends StatelessWidget {
  const RuleEmptyIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: context.colorScheme.secondaryContainer,
        shape: StarBorder(
          points: 7,
          innerRadiusRatio: 0.3,
          pointRounding: 0.9,
          valleyRounding: 0.1,
          squash: 0,
        ),
      ),
      child: _ThemeAwareSvg('assets/images/empty/rule.svg'),
    );
  }
}

class ConnectionEmptyIllustration extends StatelessWidget {
  const ConnectionEmptyIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: context.colorScheme.secondaryContainer,
        shape: StarBorder(
          points: 4,
          innerRadiusRatio: 0.1,
          pointRounding: 1,
          valleyRounding: 0,
          squash: 1,
          rotation: 45,
        ),
      ),
      child: _ThemeAwareSvg('assets/images/empty/connection.svg'),
    );
  }
}

class _ThemeAwareSvg extends StatelessWidget {
  final String assetPath;

  const _ThemeAwareSvg(this.assetPath);

  String _colorToHex(Color color) {
    return color.toARGB32().toRadixString(16).substring(2);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return FutureBuilder<String>(
      future: rootBundle.loadString(assetPath),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String svgString = snapshot.data!;
          svgString = svgString.replaceAll(
            '#E8DEF8',
            '#${_colorToHex(colorScheme.secondaryContainer)}',
          );
          // primary ??
          svgString = svgString.replaceAll(
            '#6750A4',
            '#${_colorToHex(colorScheme.primary)}',
          );
          // surface ??
          svgString = svgString.replaceAll(
            '#FDF7FF',
            '#${_colorToHex(colorScheme.surface)}',
          );
          svgString = svgString.replaceAll(
            '#C4C7C5',
            '#${_colorToHex(colorScheme.outlineVariant)}',
          );
          return SvgPicture.string(svgString, width: 200, height: 200);
        } else if (snapshot.hasError) {
          return const Icon(Icons.error);
        }
        return SizedBox(width: 200, height: 200);
      },
    );
  }
}
