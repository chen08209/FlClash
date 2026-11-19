import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/mitm_body.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_session_builder.dart';
import 'detail_tabs.dart';
import 'mitm_body.dart';
import 'mitm_exchange_menu.dart';
import 'mitm_texts.dart';
import 'mitm_timing.dart';
import 'related_connections.dart';
import 'tracker_clock.dart';

class MitmExchangeView extends StatelessWidget {
  final int id;

  /// Pushed over a connection beside the list rather than opened in a sheet,
  /// so its head holds the menu a sheet's bar would.
  final bool inPane;

  /// Opened from every connection's requests rather than from its own.
  final bool showsConnection;
  final ValueChanged<TrackerInfo>? onOpenConnection;

  const MitmExchangeView({
    super.key,
    required this.id,
    this.inPane = false,
    this.showsConnection = false,
    this.onOpenConnection,
  });

  @override
  Widget build(BuildContext context) => CoreSessionBuilder(builder: _build);

  Widget _build(BuildContext context, WidgetRef ref, bool ended) {
    final appLocalizations = context.appLocalizations;
    final value = ended ? null : ref.watch(mitmExchangeProvider(id));
    final exchange = value?.value;
    final modules = watchLocalMitmModules(ref);
    final menu = exchange == null
        ? null
        : DetailMenuButton(
            items: () => mitmExchangeMenuItems(
              context,
              ref,
              url: exchange.url,
              pending: exchange.pending,
              status: exchange.status,
              responseSize: exchange.responseSize,
              modules: modules,
              load: () async => exchange,
            ),
          );
    final content = NullStatusSwitcher(
      isLoading: value != null && value.isLoading && !value.hasValue,
      isEmpty: exchange == null,
      nullStatus: NullStatus(
        label: appLocalizations.httpRequestCleared,
        illustration: NullStatusIllustration.requests,
      ),
      child: exchange == null
          ? const SizedBox.shrink()
          : _BodyHold(
              child: _MitmExchangeDetail(
                exchange: exchange,
                menu: inPane ? menu : null,
                showsConnection: showsConnection,
                onOpenConnection: onOpenConnection,
              ),
            ),
    );
    if (inPane) {
      return content;
    }
    return DetailSheet(
      title: appLocalizations.details(appLocalizations.request),
      menu: menu,
      child: TrackerClock(child: content),
    );
  }
}

/// Keeps each body a tab has read until the request's detail closes, so that
/// turning back to its tab neither reads nor decodes it again.
class _BodyHold extends ConsumerStatefulWidget {
  final Widget child;

  const _BodyHold({required this.child});

  static void hold(BuildContext context, ProviderListenable<Object?> body) =>
      context.findAncestorStateOfType<_BodyHoldState>()?._hold(body);

  @override
  ConsumerState<_BodyHold> createState() => _BodyHoldState();
}

class _BodyHoldState extends ConsumerState<_BodyHold> {
  final _held = <ProviderListenable<Object?>>{};

  void _hold(ProviderListenable<Object?> body) {
    if (_held.add(body)) {
      ref.listenManual(body, (_, _) {});
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _MitmExchangeDetail extends StatelessWidget {
  final MitmExchange exchange;
  final Widget? menu;
  final bool showsConnection;
  final ValueChanged<TrackerInfo>? onOpenConnection;

  const _MitmExchangeDetail({
    required this.exchange,
    this.menu,
    this.showsConnection = false,
    this.onOpenConnection,
  });

  Widget _buildOverview(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final status = exchange.status;
    final originalUrl = exchange.originalUrl;
    final timed = status != 0 && !exchange.pending;
    return ListView(
      padding: detailTabPaddingOf(context),
      children: [
        generateSection(
          title: appLocalizations.basicInfo,
          atTop: true,
          items: [
            DetailRow.stacked(
              title: appLocalizations.url,
              value: exchange.url,
              copyable: true,
            ),
            if (originalUrl.isNotEmpty && originalUrl != exchange.url)
              DetailRow.stacked(
                title: appLocalizations.originalUrl,
                value: originalUrl,
                copyable: true,
              ),
            DetailRow.text(
              title: appLocalizations.method,
              value: exchange.method,
            ),
            if (exchange.proto.isNotEmpty)
              DetailRow.text(
                title: appLocalizations.protocol,
                value: exchange.proto,
              ),
            if (status != 0 || exchange.pending)
              DetailRow(
                title: appLocalizations.status,
                value: Text(
                  status != 0
                      ? httpStatusText(status, exchange.reason)
                      : appLocalizations.inProgress,
                  style: TextStyle(
                    color: httpStatusColor(context.colorScheme, status),
                  ),
                ),
              ),
            if (exchange.error.isNotEmpty)
              DetailRow.stacked(
                title: appLocalizations.error,
                value: exchange.error,
                copyable: true,
              ),
            if (exchange.route case final route?) ...[
              if (route.rule.isNotEmpty)
                DetailRow.text(
                  title: appLocalizations.rule,
                  value: route.rulePayload.isEmpty
                      ? route.rule
                      : '${route.rule}(${route.rulePayload})',
                ),
              if (route.chains.isNotEmpty)
                DetailRow.text(
                  title: appLocalizations.proxyChains,
                  value: route.chains.reversed.join(' → '),
                ),
            ],
            DetailRow.text(
              title: appLocalizations.creationTime,
              value: exchange.start.showFull,
            ),
            if (exchange.requestSize > 0)
              DetailRow.text(
                title: appLocalizations.requestBody,
                value: exchange.requestSize.traffic.show,
              ),
            if (!exchange.pending)
              DetailRow.text(
                title: appLocalizations.responseBody,
                value: exchange.responseSize.traffic.show,
              ),
          ],
        ),
        if (timed) ...[
          ListHeader(title: appLocalizations.httpTiming),
          TimingCard(
            waiting: exchange.ttfb.clamp(0, exchange.duration),
            total: exchange.duration,
          ),
        ],
        if (exchange.actions.isNotEmpty)
          generateSection(
            title: appLocalizations.matchedRules,
            items: [
              for (final action in exchange.actions)
                DetailRow.stacked(
                  title: mitmActionLabel(appLocalizations, action.kind),
                  value: [
                    if (action.phase.isNotEmpty)
                      _phaseLabel(appLocalizations, action.phase),
                    mitmActionDetail(appLocalizations, action),
                    if (action.module.isNotEmpty)
                      appLocalizations.mitmActionModule(action.module),
                  ].where((part) => part.isNotEmpty).join(' · '),
                ),
            ],
          ),
        if (exchange.connectionId case final id? when showsConnection)
          Consumer(
            builder: (context, ref, _) {
              final kept = ref.watch(
                requestsProvider.select((log) => log[id] != null),
              );
              return kept
                  ? RelatedConnections(
                      title: appLocalizations.owningConnection,
                      ids: [id],
                      atTop: false,
                      onOpenConnection: onOpenConnection,
                    )
                  : const SizedBox.shrink();
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return DetailTabs(
      header: _MitmExchangeHeader(exchange: exchange, menu: menu),
      tabs: [
        (appLocalizations.overview, _buildOverview),
        (
          appLocalizations.request,
          (_) => _MitmSideView(exchange: exchange, response: false),
        ),
        (
          appLocalizations.response,
          (_) => _MitmSideView(exchange: exchange, response: true),
        ),
      ],
    );
  }
}

/// One side of a request: its headers, then its body once the request ends.
class _MitmSideView extends ConsumerWidget {
  final MitmExchange exchange;
  final bool response;

  const _MitmSideView({required this.exchange, required this.response});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final header = response ? exchange.responseHeader : exchange.requestHeader;
    final size = response ? exchange.responseSize : exchange.requestSize;
    final bodyTitle = response
        ? appLocalizations.responseBody
        : appLocalizations.requestBody;
    final sending = size > 0 && exchange.pending;
    final bodyProvider = size > 0 && !exchange.pending
        ? mitmBodyProvider(
            exchange.id,
            response: response,
            contentType: mitmHeaderValue(header, 'Content-Type'),
          )
        : null;
    if (bodyProvider != null) {
      _BodyHold.hold(context, bodyProvider);
    }
    final body = bodyProvider == null ? null : ref.watch(bodyProvider);
    final content = body?.value;
    final kept =
        content != null && (content.bytes.isNotEmpty || content.truncated);
    final bodyError = body != null && !body.hasValue && !body.retrying
        ? body.error
        : null;
    final names = header.keys.toList()..sort();
    return NullStatusSwitcher(
      isLoading:
          body != null && !body.hasValue && (body.isLoading || body.retrying),
      isEmpty: header.isEmpty && !sending && !kept && bodyError == null,
      nullStatus: NullStatus(
        label: exchange.pending
            ? appLocalizations.inProgress
            : appLocalizations.nullTip(
                response ? appLocalizations.response : appLocalizations.request,
              ),
        illustration: NullStatusIllustration.requests,
      ),
      child: ListView(
        padding: detailTabPaddingOf(context),
        children: [
          generateSection(
            title: response
                ? appLocalizations.responseHeaders
                : appLocalizations.requestHeaders,
            atTop: true,
            items: [
              for (final name in names)
                for (final value in header[name]!)
                  DetailRow.stacked(title: name, value: value, copyable: true),
            ],
          ),
          if (sending)
            generateSection(
              title: bodyTitle,
              atTop: names.isEmpty,
              items: [ListItem(title: Text(appLocalizations.inProgress))],
            ),
          if (kept)
            MitmBodySection(
              title: bodyTitle,
              content: content,
              size: size,
              contentType: mitmHeaderValue(header, 'Content-Type'),
              atTop: names.isEmpty,
              last: true,
            ),
          if (bodyError != null)
            generateSection(
              title: bodyTitle,
              atTop: names.isEmpty,
              items: [
                DetailRow.stacked(
                  title: response
                      ? appLocalizations.responseBodyReadFailed
                      : appLocalizations.requestBodyReadFailed,
                  value: userFacingErrorMessage(bodyError, appLocalizations),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MitmExchangeHeader extends StatelessWidget {
  final MitmExchange exchange;
  final Widget? menu;

  const _MitmExchangeHeader({required this.exchange, this.menu});

  @override
  Widget build(BuildContext context) {
    return DetailHeader(
      well: (size) => LabelWell(label: exchange.method, size: size),
      actions: [?menu],
      title: exchangePathOf(exchange.url),
      subtitle: Text.rich(
        joinedSpan(
          outcomeParts(
            context,
            status: exchange.status,
            reason: exchange.reason,
            error: exchange.error,
            pending: exchange.pending,
            finished: [
              httpMillisText(exchange.duration),
              exchange.responseSize.traffic.show,
            ],
          ),
        ),
      ),
    );
  }
}

String _phaseLabel(AppLocalizations appLocalizations, String phase) {
  return switch (phase) {
    'request' => appLocalizations.request,
    'response' => appLocalizations.response,
    _ => phase,
  };
}
