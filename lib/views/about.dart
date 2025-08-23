import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/tech_theme.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/list.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Contributor {
  final String avatar;
  final String name;
  final String link;

  const Contributor({
    required this.avatar,
    required this.name,
    required this.link,
  });
}

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  _checkUpdate(BuildContext context) async {
    final commonScaffoldState = context.commonScaffoldState;
    if (commonScaffoldState?.mounted != true) return;
    final data = await commonScaffoldState?.loadingRun<Map<String, dynamic>?>(
      request.checkForUpdate,
      title: appLocalizations.checkUpdate,
    );
    globalState.appController.checkUpdateResultHandle(
      data: data,
      handleError: true,
    );
  }

  List<Widget> _buildMoreSection(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          appLocalizations.more,
          style: TechTheme.techTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: TechTheme.primaryCyan,
          ),
        ),
      ),
      TechSettingItem(
        icon: Icons.system_update,
        title: appLocalizations.checkUpdate,
        onTap: () => _checkUpdate(context),
        accentColor: TechTheme.neonGreen,
      ),
      TechSettingItem(
        icon: Icons.telegram,
        title: "Telegram",
        onTap: () => globalState.openUrl("https://t.me/FlClash"),
        accentColor: TechTheme.primaryBlue,
      ),
      TechSettingItem(
        icon: Icons.code,
        title: appLocalizations.project,
        onTap: () => globalState.openUrl("https://github.com/$repository"),
        accentColor: TechTheme.primaryPurple,
      ),
      TechSettingItem(
        icon: Icons.memory,
        title: appLocalizations.core,
        onTap: () => globalState.openUrl("https://github.com/chen08209/Clash.Meta/tree/FlClash"),
        accentColor: TechTheme.neonOrange,
      ),
    ];
  }

  List<Widget> _buildContributorsSection() {
    const contributors = [
      Contributor(
        avatar: "assets/images/avatars/june2.jpg",
        name: "June2",
        link: "https://t.me/Jibadong",
      ),
      Contributor(
        avatar: "assets/images/avatars/arue.jpg",
        name: "Arue",
        link: "https://t.me/xrcm6868",
      ),
    ];
    return [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          appLocalizations.otherContributors,
          style: TechTheme.techTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: TechTheme.primaryCyan,
          ),
        ),
      ),
      TechTheme.techCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final contributor in contributors) ...[
                Avatar(contributor: contributor),
                if (contributor != contributors.last) 
                  const SizedBox(width: 24),
              ],
            ],
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return TechPageWrapper(
      showAppBar: false,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 应用信息卡片
            TechTheme.techCard(
              animated: true,
              accentColor: TechTheme.primaryCyan,
              child: Consumer(builder: (_, ref, ___) {
                return _DeveloperModeDetector(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: TechTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image.asset(
                              'assets/images/icon.png',
                              width: 48,
                              height: 48,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appName,
                                  style: TechTheme.techTextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    glowing: true,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  globalState.packageInfo.version,
                                  style: TechTheme.techTextStyle(
                                    fontSize: 14,
                                    color: TechTheme.primaryCyan,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        appLocalizations.desc,
                        style: TechTheme.techTextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  onEnterDeveloperMode: () {
                    ref.read(appSettingProvider.notifier).updateState(
                          (state) => state.copyWith(developerMode: true),
                        );
                    context.showNotifier(appLocalizations.developerModeEnableTip);
                  },
                );
              }),
            ),
            
            const SizedBox(height: 24),
            
            // 贡献者部分
            ..._buildContributorsSection(),
            
            const SizedBox(height: 24),
            
            // 更多部分
            ..._buildMoreSection(context),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final Contributor contributor;

  const Avatar({
    super.key,
    required this.contributor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: TechTheme.primaryCyan.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: TechTheme.primaryCyan.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              foregroundImage: AssetImage(
                contributor.avatar,
              ),
              backgroundColor: TechTheme.cardBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            contributor.name,
            style: TechTheme.techTextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
      onTap: () {
        globalState.openUrl(contributor.link);
      },
    );
  }
}

class _DeveloperModeDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onEnterDeveloperMode;

  const _DeveloperModeDetector({
    required this.child,
    required this.onEnterDeveloperMode,
  });

  @override
  State<_DeveloperModeDetector> createState() => _DeveloperModeDetectorState();
}

class _DeveloperModeDetectorState extends State<_DeveloperModeDetector> {
  int _counter = 0;
  Timer? _timer;

  void _handleTap() {
    _counter++;
    if (_counter >= 5) {
      widget.onEnterDeveloperMode();
      _resetCounter();
    } else {
      _timer?.cancel();
      _timer = Timer(Duration(seconds: 1), _resetCounter);
    }
  }

  void _resetCounter() {
    _counter = 0;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: widget.child,
    );
  }
}

