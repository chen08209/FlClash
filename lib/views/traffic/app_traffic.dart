import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppTrafficRange { today, sevenDays, all }

class AppTrafficView extends ConsumerStatefulWidget {
  final AppTrafficDao? trafficDao;

  const AppTrafficView({super.key, this.trafficDao});

  @override
  ConsumerState<AppTrafficView> createState() => _AppTrafficViewState();
}

class _AppTrafficViewState extends ConsumerState<AppTrafficView> {
  static const _allProfiles = -1;
  late int _profileId;
  AppTrafficRange _range = AppTrafficRange.today;
  late Stream<List<AppTrafficUsage>> _usage;

  AppTrafficDao get _dao => widget.trafficDao ?? database.appTrafficDao;

  @override
  void initState() {
    super.initState();
    _profileId = ref.read(currentProfileIdProvider) ?? _allProfiles;
    _subscribe();
  }

  void _subscribe() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final since = switch (_range) {
      AppTrafficRange.today => today,
      AppTrafficRange.sevenDays => DateTime(now.year, now.month, now.day - 6),
      AppTrafficRange.all => null,
    };
    _usage = _dao
        .queryUsage(
          profileId: _profileId == _allProfiles ? null : _profileId,
          since: since,
        )
        .watch();
  }

  Future<void> _clear() async {
    final l10n = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      title: l10n.clearTrafficStatistics,
      message: TextSpan(text: l10n.clearTrafficStatisticsConfirm),
    );
    if (confirmed == true && mounted) {
      await _dao.clear(
        profileId: _profileId == _allProfiles ? null : _profileId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final profiles = ref.watch(profilesProvider);
    return Scaffold(
      title: l10n.appTraffic,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.broom,
          tooltip: l10n.clearTrafficStatistics,
          onPressed: _clear,
        ),
      ],
      body: Builder(
        builder: (context) => StreamBuilder<List<AppTrafficUsage>>(
          stream: _usage,
          builder: (context, snapshot) {
            final usages = snapshot.data ?? const <AppTrafficUsage>[];
            final total = usages.fold<int>(
              0,
              (sum, usage) => sum + usage.total,
            );
            final upload = usages.fold<int>(
              0,
              (sum, usage) => sum + usage.upload,
            );
            final header = Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  ListItem<int>.options(
                    title: Text(l10n.profiles),
                    leading: const GlyphIcon(AppGlyphs.profiles),
                    options: [
                      _allProfiles,
                      ...profiles.map((profile) => profile.id),
                    ],
                    value: _profileId,
                    textBuilder: (id) => id == _allProfiles
                        ? l10n.allSubscriptions
                        : profiles
                              .firstWhere((profile) => profile.id == id)
                              .label,
                    onChanged: (id) => setState(() {
                      _profileId = id;
                      _subscribe();
                    }),
                  ),
                  SegmentedControl<AppTrafficRange>(
                    segments: [
                      (AppTrafficRange.today, l10n.today),
                      (AppTrafficRange.sevenDays, l10n.lastSevenDays),
                      (AppTrafficRange.all, l10n.allTime),
                    ],
                    value: _range,
                    onChanged: (range) => setState(() {
                      _range = range;
                      _subscribe();
                    }),
                  ),
                  Card(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TrafficValue(
                            label: l10n.totalTraffic,
                            value: total,
                          ),
                        ),
                        Expanded(
                          child: _TrafficValue(
                            label: l10n.upload,
                            value: upload,
                          ),
                        ),
                        Expanded(
                          child: _TrafficValue(
                            label: l10n.download,
                            value: total - upload,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    l10n.appTrafficScope,
                    style: AppTextStyle.footnote
                        .of(context)
                        .copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top,
                  ),
                  sliver: SliverToBoxAdapter(child: header),
                ),
                if (snapshot.hasError)
                  SliverToBoxAdapter(child: Text(snapshot.error.toString()))
                else if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: LinearProgressIndicator(),
                    ),
                  )
                else if (usages.isEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 240,
                      child: NullStatus(
                        label: l10n.noAppTraffic,
                        illustration: NullStatusIllustration.apps,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverPrismList(
                      itemCount: usages.length,
                      estimatedItemExtent: 130,
                      gap: 8,
                      itemBuilder: (_, index) => _AppTrafficItem(
                        usage: usages[index],
                        maxTraffic: usages.first.total,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: SizedBox(height: context.bottomInset + 32),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TrafficValue extends StatelessWidget {
  final String label;
  final int value;

  const _TrafficValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 6,
    children: [
      Text(label, style: AppTextStyle.caption1.of(context)),
      Text(value.traffic.show, style: AppTextStyle.title2.of(context)),
    ],
  );
}

class _AppTrafficItem extends StatelessWidget {
  final AppTrafficUsage usage;
  final int maxTraffic;

  const _AppTrafficItem({required this.usage, required this.maxTraffic});

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    final label = usage.applicationLabel.isEmpty
        ? l10n.unknownApplication
        : usage.applicationLabel;
    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: AppTextStyle.headline.of(context)),
              ),
              Text(
                usage.total.traffic.show,
                style: AppTextStyle.headline.of(context),
              ),
            ],
          ),
          LinearProgressIndicator(
            value: maxTraffic == 0 ? 0 : usage.total / maxTraffic,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n.upload} ${usage.upload.traffic.show}',
                style: AppTextStyle.footnote.of(context),
              ),
              Text(
                '${l10n.download} ${usage.download.traffic.show}',
                style: AppTextStyle.footnote.of(context),
              ),
            ],
          ),
          Text(
            {...usage.providers, ...usage.proxies}.take(4).join(' · '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.caption1
                .of(context)
                .copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
