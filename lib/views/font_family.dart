import 'dart:async';
import 'dart:collection';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

sealed class _FontChoice {
  const _FontChoice();
}

final class _DefaultFont extends _FontChoice {
  const _DefaultFont();
}

final class _InstalledFont extends _FontChoice {
  const _InstalledFont(this.family);

  final String family;

  @override
  bool operator ==(Object other) =>
      other is _InstalledFont && other.family == family;

  @override
  int get hashCode => family.hashCode;
}

class FontFamilyView extends ConsumerStatefulWidget {
  const FontFamilyView({super.key});

  @override
  ConsumerState<FontFamilyView> createState() => _FontFamilyViewState();
}

class _FontFamilyViewState extends ConsumerState<FontFamilyView> {
  List<_InstalledFont>? _installed;
  var _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadStarted) {
      return;
    }
    _loadStarted = true;
    unawaited(_load());
  }

  Future<void> _load() async {
    await whenRouteSettled(context);
    if (!mounted) {
      return;
    }
    final families = await loadSystemFontFamilies();
    if (mounted) {
      setState(() => _installed = families.map(_InstalledFont.new).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final installed = _installed ?? const <_InstalledFont>[];
    return SelectionSheet<_FontChoice>(
      title: appLocalizations.fontFamily,
      loadingStatus: _installed == null
          ? const NullStatus(illustration: NullStatusIllustration.fonts)
          : null,
      sections: [
        const SelectionSection(items: [_DefaultFont()]),
        if (installed.isNotEmpty)
          SelectionSection(
            label: appLocalizations.installedFonts,
            items: installed,
          ),
      ],
      labelBuilder: (choice) => switch (choice) {
        _DefaultFont() => appLocalizations.defaultText,
        _InstalledFont(:final family) => family,
      },
      titleBuilder: (choice, title) => switch (choice) {
        _DefaultFont() => title,
        _InstalledFont(:final family) => _FontLabel(
          family: family,
          child: title,
        ),
      },
      selectedOf: (ref) => switch (ref.watch(
        themeSettingProvider.select((state) => state.fontFamily),
      )) {
        final family? => _InstalledFont(family),
        null => const _DefaultFont(),
      },
      onSelected: (choice) {
        final String? family;
        switch (choice) {
          case _DefaultFont():
            family = null;
          case _InstalledFont():
            family = choice.family;
        }
        ref
            .read(themeSettingProvider.notifier)
            .update((state) => state.copyWith(fontFamily: family));
      },
    );
  }
}

/// Laying out a family for the first time loads it on the UI thread, a few
/// milliseconds each, so each name switches to its family on a frame of its
/// own.
class _FontLabel extends StatefulWidget {
  const _FontLabel({required this.family, required this.child});

  final String family;
  final Widget child;

  @override
  State<_FontLabel> createState() => _FontLabelState();
}

class _FontLabelState extends State<_FontLabel> {
  static final _shown = <String>{};
  static final _waiting = Queue<_FontLabelState>();
  static var _scheduled = false;

  bool get _isShown => _shown.contains(widget.family);

  @override
  void initState() {
    super.initState();
    _request();
  }

  @override
  void didUpdateWidget(_FontLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.family != widget.family) {
      _request();
    }
  }

  @override
  void dispose() {
    _waiting.remove(this);
    super.dispose();
  }

  void _request() {
    if (_isShown || _waiting.contains(this)) {
      return;
    }
    _waiting.add(this);
    _schedule();
  }

  static void _schedule() {
    if (_scheduled || _waiting.isEmpty) {
      return;
    }
    _scheduled = true;
    SchedulerBinding.instance
      ..addPostFrameCallback((_) {
        _scheduled = false;
        while (_waiting.isNotEmpty) {
          final next = _waiting.removeFirst();
          final family = next.widget.family;
          if (!next.mounted || next._isShown) {
            continue;
          }
          _shown.add(family);
          next.setState(() {});
          break;
        }
        _schedule();
      })
      ..ensureVisualUpdate();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isShown) {
      return widget.child;
    }
    return DefaultTextStyle.merge(
      style: TextStyle(fontFamily: widget.family),
      child: widget.child,
    );
  }
}
