import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'detail_tabs.dart';
import 'mitm_exchange_detail.dart';
import 'mitm_exchange_menu.dart';
import 'mitm_texts.dart';

/// The requests captured on a decrypted connection.
class MitmExchangesView extends ConsumerWidget {
  final TrackerInfo trackerInfo;

  const MitmExchangesView({super.key, required this.trackerInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final (list, loading, error) = ref.watch(
      mitmExchangesProvider(trackerInfo.id).select(
        (value) => (
          value.value,
          !value.hasValue && (value.isLoading || value.retrying),
          value.hasValue || value.retrying ? null : value.error,
        ),
      ),
    );
    final errorText = error == null
        ? null
        : userFacingErrorMessage(error, appLocalizations);
    final exchanges = list?.exchanges ?? const <MitmExchangeSummary>[];
    final since = list?.since;
    final missing = since != null && trackerInfo.start.isBefore(since);
    final waiting = errorText == null && list?.capturing != false && !missing;
    return NullStatusSwitcher(
      isLoading: loading,
      isEmpty: exchanges.isEmpty,
      nullStatus: NullStatus(
        label: errorText != null
            ? appLocalizations.httpRequestsReadFailed
            : list?.capturing == false
            ? appLocalizations.httpCaptureOff
            : missing
            ? appLocalizations.httpRequestsMissing
            : appLocalizations.noHttpRequests,
        description: waiting ? appLocalizations.noHttpRequestsHint : errorText,
        action: errorText == null
            ? null
            : TonalButton(
                size: TonalButtonSize.bar,
                glyph: AppGlyphs.copy,
                label: appLocalizations.copy,
                onPressed: () => dialogs.copy(errorText),
              ),
        illustration: NullStatusIllustration.requests,
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: detailTabPaddingOf(context),
            sliver: generateSliverSection(
              atTop: true,
              items: exchanges,
              itemBuilder: (exchange) => _MitmExchangeItem(
                exchange: exchange,
                host: trackerInfo.title,
              ),
              footer: missing ? appLocalizations.httpRequestsMissing : null,
              last: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _MitmExchangeItem extends ConsumerWidget {
  final MitmExchangeSummary exchange;
  final String host;

  const _MitmExchangeItem({required this.exchange, required this.host});

  void _open(BuildContext context) {
    final pane = DetailPane.maybeOf(context);
    if (pane == null) {
      showNestedSheet<void>(
        context,
        builder: (_) => MitmExchangeView(id: exchange.id),
      );
      return;
    }
    pane.push(
      back: host,
      builder: (_) => MitmExchangeView(id: exchange.id, inPane: true),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContextMenuRegion(
      menuItems: mitmExchangeMenuItems(
        context,
        ref,
        url: exchange.url,
        pending: exchange.pending,
        status: exchange.status,
        responseSize: exchange.responseSize,
        modules: watchLocalMitmModules(ref),
        load: () => ref.read(coreHandlerProvider).getMitmExchange(exchange.id),
      ),
      child: DecorationListItem(
        onPressed: () => _open(context),
        contentPadding: ListItem.chevronPaddingOf(context),
        title: Text(
          exchangePathOf(exchange.url),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: DefaultTextStyle.merge(
          style: context.listSubtitleStyle.toTabular,
          child: RecordLabelLine(
            underTitle: true,
            text: exchange.method,
            labels: outcomeLabels(
              context,
              status: exchange.status,
              error: exchange.error,
              pending: exchange.pending,
              finished: [
                exchange.responseSize.traffic.show,
                httpMillisText(exchange.duration),
                ?exchangeMark(context.appLocalizations, exchange),
              ],
            ),
          ),
        ),
        trailing: const GlyphIcon(AppGlyphs.chevronForward),
      ),
    );
  }
}
