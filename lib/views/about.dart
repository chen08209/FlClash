import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/list.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:material_ui/material_ui.dart';
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

class AboutView extends ConsumerWidget {
  const AboutView({super.key});

  Future<void> _checkUpdate(BuildContext context, WidgetRef ref) async {
    if (ref.read(loadingProvider(LoadingTag.checkUpdate))) return;
    final commonAction = ref.read(commonActionProvider.notifier);
    final data = await globalState.loadingRun<Map<String, dynamic>?>(
      request.checkForUpdate,
      title: context.appLocalizations.checkUpdate,
      tag: LoadingTag.checkUpdate,
    );
    unawaited(commonAction.checkUpdateResultHandle(data: data, isUser: true));
  }

  List<Widget> _buildMoreSection(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      separated: false,
      title: appLocalizations.more,
      items: [
        ListItem(
          title: Text(appLocalizations.checkUpdate),
          onTap: () {
            _checkUpdate(context, ref);
          },
        ),
        ListItem(
          title: const Text('Telegram'),
          onTap: () {
            dialogs.openUrl('https://t.me/FlClash');
          },
          trailing: const GlyphIcon(AppGlyphs.openExternal),
        ),
        ListItem(
          title: Text(appLocalizations.project),
          onTap: () {
            dialogs.openUrl('https://github.com/$repository');
          },
          trailing: const GlyphIcon(AppGlyphs.openExternal),
        ),
        ListItem(
          title: Text(appLocalizations.core),
          onTap: () {
            dialogs.openUrl(
              'https://github.com/chen08209/Clash.Meta/tree/FlClash',
            );
          },
          trailing: const GlyphIcon(AppGlyphs.openExternal),
        ),
      ],
    );
  }

  List<Widget> _buildContributorsSection(AppLocalizations appLocalizations) {
    const contributors = [
      Contributor(
        avatar: 'assets/images/avatar/june2.jpg',
        name: 'June2',
        link: 'https://t.me/Jibadong',
      ),
      Contributor(
        avatar: 'assets/images/avatar/arue.jpg',
        name: 'Arue',
        link: 'https://t.me/xrcm6868',
      ),
    ];
    return generateSection(
      separated: false,
      title: appLocalizations.otherContributors,
      items: [
        ListItem(
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 24,
              children: [
                for (final contributor in contributors)
                  Avatar(contributor: contributor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final items = [
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer(
              builder: (_, ref, _) {
                return _DeveloperModeDetector(
                  child: Wrap(
                    spacing: 16,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Image.asset(
                          'assets/images/icon.png',
                          width: 64,
                          height: 64,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            globalState.packageInfo.version,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                  onEnterDeveloperMode: () {
                    ref
                        .read(appSettingProvider.notifier)
                        .update((state) => state.copyWith(developerMode: true));
                    context.showNotifier(
                      appLocalizations.developerModeEnableTip,
                      level: MessageLevel.success,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              appLocalizations.desc,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ..._buildContributorsSection(appLocalizations),
      ..._buildMoreSection(context, ref),
    ];
    return CommonScaffold(
      isLoading: ref.watch(loadingProvider(LoadingTag.checkUpdate)),
      title: appLocalizations.about,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: generateListView(items, topPadding: context.contentTopPadding),
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final Contributor contributor;

  const Avatar({super.key, required this.contributor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircleAvatar(
              foregroundImage: AssetImage(contributor.avatar),
            ),
          ),
          const SizedBox(height: 4),
          Text(contributor.name, style: context.textTheme.bodySmall),
        ],
      ),
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
      _timer = Timer(const Duration(seconds: 1), _resetCounter);
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
    return GestureDetector(onTap: _handleTap, child: widget.child);
  }
}
