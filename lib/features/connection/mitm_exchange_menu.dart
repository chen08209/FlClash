import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/mitm_body.dart';
import 'package:fl_clash/common/mitm_export.dart';
import 'package:fl_clash/common/mitm_module.dart';
import 'package:fl_clash/features/mitm/module_editor.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show join;

/// The modules the user wrote, which a rule can be added to.
List<MitmModule> watchLocalMitmModules(WidgetRef ref) => ref.watch(
  mitmModulesProvider.select(
    (state) => [
      for (final module in state.value ?? const <MitmModule>[])
        if (!module.isRemote) module,
    ],
  ),
);

/// Copies a request, exports it, or writes a rule for it into one of the
/// [modules] the user wrote, or a new one. A list knows only a summary of each
/// request, so [load] reads the rest when an item is picked.
List<PopupMenuItem> mitmExchangeMenuItems(
  BuildContext context,
  WidgetRef ref, {
  required String url,
  required bool pending,
  required int status,
  required int responseSize,
  required List<MitmModule> modules,
  required Future<MitmExchange?> Function() load,
}) {
  final appLocalizations = context.appLocalizations;
  Future<void> withExchange(
    Future<void> Function(MitmExchange exchange) action,
  ) async {
    final exchange = await globalState.safeRun(load);
    if (exchange == null) {
      dialogs.showBanner(currentAppLocalizations.httpRequestCleared);
      return;
    }
    await action(exchange);
  }

  List<PopupMenuItem> targets(
    Future<void> Function(MitmModule? module) addTo,
  ) => [
    PopupMenuItem(
      glyph: AppGlyphs.add,
      label: appLocalizations.mitmNewModule,
      onPressed: () => addTo(null),
    ),
    for (final module in modules)
      PopupMenuItem(label: module.name, onPressed: () => addTo(module)),
  ];

  return [
    PopupMenuItem(
      glyph: AppGlyphs.link,
      label: appLocalizations.copyLink,
      onPressed: () => _copy(url),
    ),
    PopupMenuItem(
      glyph: AppGlyphs.code,
      label: appLocalizations.copyAsCurl,
      onPressed: () => withExchange((exchange) => _copyCurl(ref, exchange)),
    ),
    PopupMenuItem(
      glyph: AppGlyphs.copy,
      label: appLocalizations.copyRequest,
      onPressed: () => withExchange(
        (exchange) => _copyRaw(
          ref,
          exchange,
          appLocalizations.copyRequest,
          response: false,
          format: mitmRawRequest,
        ),
      ),
    ),
    if (status != 0)
      PopupMenuItem(
        glyph: AppGlyphs.copy,
        label: appLocalizations.copyResponse,
        onPressed: () => withExchange(
          (exchange) => _copyRaw(
            ref,
            exchange,
            appLocalizations.copyResponse,
            response: true,
            format: mitmRawResponse,
          ),
        ),
      ),
    if (!pending && responseSize > 0)
      PopupMenuItem(
        glyph: AppGlyphs.copy,
        label: appLocalizations.copyResponseBody,
        onPressed: () =>
            withExchange((exchange) => _copyResponseBody(ref, exchange)),
      ),
    PopupMenuItem(
      glyph: AppGlyphs.export,
      label: appLocalizations.exportHar,
      onPressed: () => withExchange((exchange) => _exportHar(ref, exchange)),
    ),
    PopupMenuItem(
      glyph: AppGlyphs.block,
      label: appLocalizations.mitmAddRejectRule,
      section: const PopupMenuSection(),
      subItems: targets(
        (module) => withExchange(
          (exchange) => _addRule(
            context,
            ref,
            module,
            mitmUrlRewriteSection,
            mitmRejectLine(
              exchange.originalUrl.isEmpty
                  ? exchange.url
                  : exchange.originalUrl,
            ),
          ),
        ),
      ),
    ),
    if (!pending && status != 0)
      PopupMenuItem(
        glyph: AppGlyphs.swap,
        label: appLocalizations.mitmAddMapLocalRule,
        subItems: targets(
          (module) => withExchange(
            (exchange) => _addMapLocal(context, ref, exchange, module),
          ),
        ),
      ),
  ];
}

Future<void> _copy(String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  dialogs.showBanner(currentAppLocalizations.copySuccess);
}

Future<bool> _warned(WidgetRef ref, String action) async {
  if (ref.read(mitmExportWarnedProvider)) {
    return true;
  }
  final appLocalizations = currentAppLocalizations;
  final accepted = await dialogs.showMessage(
    title: appLocalizations.httpExportPrivateTitle,
    message: TextSpan(text: appLocalizations.httpExportPrivate),
    confirmText: action,
  );
  if (accepted != true) {
    return false;
  }
  ref.read(mitmExportWarnedProvider.notifier).accept();
  return true;
}

Future<MitmBody?> _body(WidgetRef ref, MitmExchange exchange, bool response) {
  final size = response ? exchange.responseSize : exchange.requestSize;
  if (size == 0 || exchange.pending) {
    return Future.value();
  }
  return ref
      .read(coreHandlerProvider)
      .getMitmBody(exchange.id, response: response);
}

Future<void> _copyCurl(WidgetRef ref, MitmExchange exchange) async {
  if (!await _warned(ref, currentAppLocalizations.copyAsCurl)) {
    return;
  }
  await globalState.safeRun(() async {
    final body = await _body(ref, exchange, false);
    await _copy(await compute(_curl, (exchange, body)));
  }, title: currentAppLocalizations.copyAsCurl);
}

String _curl((MitmExchange, MitmBody?) input) => mitmCurl(input.$1, input.$2);

Future<void> _copyRaw(
  WidgetRef ref,
  MitmExchange exchange,
  String title, {
  required bool response,
  required String Function((MitmExchange, MitmBody?)) format,
}) async {
  if (!await _warned(ref, title)) {
    return;
  }
  await globalState.safeRun(() async {
    final body = await _body(ref, exchange, response);
    await _copy(await compute(format, (exchange, body)));
  }, title: title);
}

Future<void> _copyResponseBody(WidgetRef ref, MitmExchange exchange) async {
  final title = currentAppLocalizations.copyResponseBody;
  if (!await _warned(ref, title)) {
    return;
  }
  await globalState.safeRun(() async {
    final body = await _body(ref, exchange, true);
    if (body == null) {
      return;
    }
    await _copy(await compute(mitmBodyCopyText, body));
  }, title: title);
}

Future<void> _exportHar(WidgetRef ref, MitmExchange exchange) async {
  final appLocalizations = currentAppLocalizations;
  if (!await _warned(ref, appLocalizations.exportHar)) {
    return;
  }
  await globalState.safeRun(() async {
    final (request, response) = await (
      _body(ref, exchange, false),
      _body(ref, exchange, true),
    ).wait;
    final har = await compute(mitmHar, (
      exchange,
      request,
      response,
      globalState.packageInfo.version,
    ));
    final host = Uri.tryParse(exchange.url)?.host ?? '';
    final saved = await picker.saveFile(
      '${host.isEmpty ? appName : host}-${exchange.id}.har',
      utf8.encode(har),
    );
    if (saved != null) {
      dialogs.showBanner(appLocalizations.exportSuccess);
    }
  }, title: appLocalizations.exportHar);
}

Future<void> _addMapLocal(
  BuildContext context,
  WidgetRef ref,
  MitmExchange exchange,
  MitmModule? module,
) async {
  final body = await globalState.safeRun(
    () => _body(ref, exchange, true),
    title: currentAppLocalizations.mitmAddMapLocalRule,
  );
  final bytes = body == null || body.truncated || body.encoding.isNotEmpty
      ? const <int>[]
      : base64Decode(body.data);
  final file = bytes.isEmpty
      ? null
      : mitmAttachmentName(
          exchange.url,
          module == null ? const [] : mitmAttachments(module).keys,
        );
  if (!context.mounted) {
    return;
  }
  await _addRule(
    context,
    ref,
    module,
    mitmMapLocalSection,
    mitmMapLocalLine(
      exchange.url,
      file: file,
      status: exchange.status,
      contentType: mitmHeaderValue(exchange.responseHeader, 'Content-Type'),
    ),
    attachments: {?file: bytes},
  );
}

Future<void> _addRule(
  BuildContext context,
  WidgetRef ref,
  MitmModule? module,
  String section,
  String line, {
  Map<String, List<int>> attachments = const {},
}) async {
  if (module != null) {
    final text = await globalState.safeRun(
      () async => File(
        join(await appPath.mitmModulesDirPath, module.fileName),
      ).readAsString(),
    );
    if (text == null) {
      return;
    }
    if (mitmAddLine(text, section, line) == null) {
      await Clipboard.setData(ClipboardData(text: line));
      dialogs.showBanner(currentAppLocalizations.mitmRuleCopiedForStash);
      return;
    }
  }
  if (!context.mounted) {
    return;
  }
  await openMitmModuleEditor(
    context,
    ref,
    module: module,
    edit: (text) => mitmAddLine(text, section, line) ?? text,
    attachments: attachments,
  );
}
