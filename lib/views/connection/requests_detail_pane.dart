import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum RequestsSegment { connections, http, dns }

const _detailMinWidth = 480.0;
const _detailMargin = EdgeInsetsDirectional.fromSTEB(4, 0, 12, 12);
const _detailTopInset = 20.0;

/// Beside the list on a wide page: the selection of [segment] in a raised
/// card, or what to select when there is none.
class RequestsDetailPane extends StatelessWidget {
  static final minWidth =
      _detailMinWidth + _detailMargin.start + _detailMargin.end;

  final RequestsSegment segment;
  final ValueListenable<int?> selected;
  final ConnectionRows rows;
  final ValueListenable<DnsQuery?> dnsSelected;
  final ValueListenable<int?> httpSelected;
  final String detailTitle;
  final double top;
  final ValueChanged<TrackerInfo> onOpenConnection;

  const RequestsDetailPane({
    super.key,
    required this.segment,
    required this.selected,
    required this.rows,
    required this.dnsSelected,
    required this.httpSelected,
    required this.detailTitle,
    required this.top,
    required this.onOpenConnection,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([selected, dnsSelected, httpSelected]),
      builder: (context, _) {
        final appLocalizations = context.appLocalizations;
        final dnsQuery = dnsSelected.value;
        final httpId = httpSelected.value;
        final detail = switch (segment) {
          RequestsSegment.connections when selected.value != null =>
            TrackerSelectedDetail(
              selected: selected,
              rows: rows,
              title: detailTitle,
            ),
          RequestsSegment.connections => NullStatus(
            key: const ValueKey(RequestsSegment.connections),
            illustration: NullStatusIllustration.connections,
            label: appLocalizations.selectConnection,
            description: appLocalizations.selectConnectionHint,
          ),
          RequestsSegment.http when httpId != null => MitmExchangeView(
            key: ValueKey(httpId),
            id: httpId,
            inPane: true,
            showsConnection: true,
            onOpenConnection: onOpenConnection,
          ),
          RequestsSegment.http => NullStatus(
            key: const ValueKey(RequestsSegment.http),
            illustration: NullStatusIllustration.requests,
            label: appLocalizations.selectHttpRequest,
            description: appLocalizations.selectHttpRequestHint,
          ),
          RequestsSegment.dns when dnsQuery != null => DnsQueryDetailView(
            key: ObjectKey(dnsQuery),
            dnsQuery: dnsQuery,
            onOpenConnection: onOpenConnection,
          ),
          RequestsSegment.dns => NullStatus(
            key: const ValueKey(RequestsSegment.dns),
            illustration: NullStatusIllustration.dns,
            label: appLocalizations.selectDnsQuery,
            description: appLocalizations.selectDnsQueryHint,
          ),
        };
        return Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + top,
            bottom: context.bottomInset,
          ),
          child: Padding(padding: _detailMargin, child: _DetailCard(detail)),
        );
      },
    );
  }
}

class _DetailCard extends StatelessWidget {
  final Widget detail;

  const _DetailCard(this.detail);

  @override
  Widget build(BuildContext context) {
    final level = context.raisedSurfaceLevel;
    return ClipRSuperellipse(
      borderRadius: AppRadius.all(AppCorner.xxl),
      child: ColoredBox(
        color: level.colorOf(context.colorScheme),
        child: SurfaceScope(
          level: level,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: BottomInsetScope(
              inset: 0,
              child: TopInsetScope(inset: _detailTopInset, child: detail),
            ),
          ),
        ),
      ),
    );
  }
}
