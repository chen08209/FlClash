import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'related_connections.dart';
import 'tracker_clock.dart';

void showDnsQueryDetail(BuildContext context, DnsQuery dnsQuery) {
  showNestedSheet<void>(
    context,
    builder: (_) => DnsQueryDetailSheet(dnsQuery: dnsQuery),
  );
}

class DnsQueryDetailSheet extends StatelessWidget {
  final DnsQuery dnsQuery;

  const DnsQueryDetailSheet({super.key, required this.dnsQuery});

  @override
  Widget build(BuildContext context) => DetailSheet(
    title: context.appLocalizations.details('DNS'),
    menu: Builder(
      builder: (context) =>
          DetailMenuButton(items: () => dnsQueryMenuItems(context, dnsQuery)),
    ),
    child: TrackerClock(
      child: DnsQueryDetailView(dnsQuery: dnsQuery, showsMenu: false),
    ),
  );
}

String _failureTitle(AppLocalizations appLocalizations, DnsQuery dnsQuery) {
  final error = dnsQuery.error;
  // A rule answers through mihomo's rcode:// upstream; the rest is Go's wording.
  if (dnsQuery.upstream.startsWith('rcode://')) {
    return appLocalizations.dnsBlockedByRule;
  }
  if (error.contains('i/o timeout') || error.contains('deadline exceeded')) {
    return appLocalizations.dnsTimedOut;
  }
  return switch (dnsQuery.rcode) {
    'NXDOMAIN' => appLocalizations.dnsNoSuchDomain,
    'SERVFAIL' => appLocalizations.dnsServerFailure,
    'REFUSED' => appLocalizations.dnsRefused,
    _ => appLocalizations.failureDns,
  };
}

/// The query has no tabs, which would stand between its head and its
/// first section.
const _headerGap = 24.0;

class DnsQueryDetailView extends ConsumerWidget {
  final DnsQuery dnsQuery;

  /// Where a page shows a connection beside its list; elsewhere a related
  /// connection opens a sheet of its own.
  final ValueChanged<TrackerInfo>? onOpenConnection;

  /// Off where a sheet's bar holds the menu.
  final bool showsMenu;

  const DnsQueryDetailView({
    super.key,
    required this.dnsQuery,
    this.onOpenConnection,
    this.showsMenu = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final id = dnsQuery.id;
    final related = id == null
        ? const <int>[]
        : ref.watch(requestsProvider.select((log) => log.resolvedBy(id)));
    final failed = dnsQuery.isFailed;
    final answers = dnsQuery.answers;
    final fields = [
      DetailRow.text(title: appLocalizations.recordType, value: dnsQuery.type),
      if (dnsQuery.initiator case final initiator?)
        DetailRow.text(
          title: appLocalizations.initiator,
          value: initiator.label,
        ),
      if (dnsQuery.upstream.isNotEmpty)
        DetailRow.text(
          title: appLocalizations.upstream,
          value: dnsQuery.upstream,
          copyable: true,
        ),
      DetailRow.text(
        title: appLocalizations.cache,
        value: dnsQuery.cached ? appLocalizations.yes : appLocalizations.no,
      ),
      if (dnsQuery.rcode.isNotEmpty)
        DetailRow(
          title: appLocalizations.responseCode,
          copyText: dnsQuery.rcode,
          value: Text(
            dnsQuery.rcode,
            style: dnsQuery.hasFailureRcode
                ? TextStyle(color: context.colorScheme.error)
                : null,
          ),
        ),
    ];
    final margin = context.listInsets.margin;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            margin,
            context.contentTopPadding,
            margin,
            margin + context.bottomInset,
          ),
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: _headerGap),
                  child: _DnsQueryHeader(
                    dnsQuery: dnsQuery,
                    showsMenu: showsMenu,
                  ),
                ),
              ),
              if (failed)
                SliverToBoxAdapter(
                  child: generateSection(
                    title: appLocalizations.error,
                    atTop: true,
                    items: [
                      DetailRow.stacked(
                        leading: GlyphIcon(
                          AppGlyphs.error,
                          color: context.colorScheme.error,
                        ),
                        title: _failureTitle(appLocalizations, dnsQuery),
                        value: dnsQuery.error.isNotEmpty
                            ? dnsQuery.error
                            : dnsQuery.rcode,
                        copyable: true,
                      ),
                    ],
                  ),
                ),
              SliverToBoxAdapter(
                child: generateSection(
                  title: '${appLocalizations.answers} ${answers.length}',
                  atTop: !failed,
                  items: [
                    for (final answer in answers) _AnswerRow(answer: answer),
                  ],
                ),
              ),
              if (related.isNotEmpty)
                SliverRelatedConnections(
                  title:
                      '${appLocalizations.relatedConnections} ${related.length}',
                  ids: related,
                  atTop: !failed && answers.isEmpty,
                  onOpenConnection: onOpenConnection,
                ),
              SliverToBoxAdapter(
                child: generateSection(
                  title: appLocalizations.dnsQueryFields,
                  atTop: !failed && answers.isEmpty && related.isEmpty,
                  items: fields,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

List<PopupMenuItem> dnsQueryMenuItems(
  BuildContext context,
  DnsQuery dnsQuery, {
  ValueChanged<String>? onOnlyDomain,
}) {
  final appLocalizations = context.appLocalizations;
  final domain = dnsQuery.domain;
  return [
    copyMenuItem(appLocalizations.copyDomain, domain),
    if (dnsQuery.answers.isNotEmpty)
      copyMenuItem(appLocalizations.copyAnswers, dnsQuery.answers.join('\n')),
    if (onOnlyDomain != null)
      PopupMenuItem(
        glyph: AppGlyphs.filter,
        label: appLocalizations.onlyThisDomain,
        section: const PopupMenuSection(),
        onPressed: () => onOnlyDomain(domain),
      ),
  ];
}

class _DnsQueryHeader extends StatelessWidget {
  final DnsQuery dnsQuery;
  final bool showsMenu;

  const _DnsQueryHeader({required this.dnsQuery, required this.showsMenu});

  @override
  Widget build(BuildContext context) {
    final initiator = dnsQuery.initiator;
    final subtitle = [
      if (initiator != null)
        context.appLocalizations.dnsQueryAskedBy(initiator.label),
      dnsQuery.time.showTime,
      '${dnsQuery.delay} ms',
    ].join(' · ');
    return DetailHeader(
      well: (size) => LabelWell(label: dnsQuery.type, size: size),
      title: dnsQuery.domain,
      subtitle: Text(subtitle),
      actions: [
        if (showsMenu)
          DetailMenuButton(items: () => dnsQueryMenuItems(context, dnsQuery)),
      ],
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final String answer;

  const _AnswerRow({required this.answer});

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      onPressed: () => dialogs.copy(answer),
      title: Text(
        answer,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.body.of(context).toTabular,
      ),
    );
  }
}
