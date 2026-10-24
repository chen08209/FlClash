import 'dart:async';
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
  final Set<String> _shownFonts = {};

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
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
          shownFonts: _shownFonts,
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
///
/// Scrolling holds the queue as well: a load that competes with the frames of
/// a fling drops them, and rows that scroll past leave the queue without ever
/// loading their font.
class _FontLabel extends StatefulWidget {
  const _FontLabel({
    required this.family,
    required this.shownFonts,
    required this.child,
  });

  final String family;
  final Set<String> shownFonts;
  final Widget child;

  @override
  State<_FontLabel> createState() => _FontLabelState();
}

class _FontLabelState extends State<_FontLabel> {
  static final _waiting = <_FontLabelState>{};
  static var _scheduled = false;
  static ValueNotifier<bool>? _scrolling;

  bool get _isShown => widget.shownFonts.contains(widget.family);

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
    if (_waiting.isEmpty) {
      _stopListeningForScroll();
      _scheduled = false;
    }
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
      ..addPostFrameCallback(_showNext)
      ..ensureVisualUpdate();
  }

  static void _showNext(Duration _) {
    final next = _waiting.firstOrNull;
    if (next != null && next.mounted && _holdsQueue(next.context)) {
      // The frames of the motion carry the queue until it stops.
      SchedulerBinding.instance.addPostFrameCallback(_showNext);
      return;
    }
    _scheduled = false;
    while (_waiting.isNotEmpty) {
      final label = _waiting.first;
      _waiting.remove(label);
      if (!label.mounted || label._isShown) {
        continue;
      }
      label.widget.shownFonts.add(label.widget.family);
      label.setState(() {});
      break;
    }
    if (_waiting.isEmpty) {
      _stopListeningForScroll();
    }
    _schedule();
  }

  /// Route motion and scrolling both hold the queue. Their frames are already
  /// spoken for, so a synchronous font load on top of them drops frames.
  static bool _holdsQueue(BuildContext context) {
    if (isRouteMoving(context)) {
      return true;
    }
    final scrolling = Scrollable.maybeOf(context)?.position.isScrollingNotifier;
    if (scrolling == null || !scrolling.value) {
      return false;
    }
    if (!identical(_scrolling, scrolling)) {
      _stopListeningForScroll();
      _scrolling = scrolling;
      scrolling.addListener(_handleScrollStopped);
    }
    return true;
  }

  /// The end of a drag can fall between frames, unlike the end of a fling or
  /// a route animation, so the notifier asks for the frame that drains the
  /// queue.
  static void _handleScrollStopped() {
    if (_scrolling?.value ?? false) {
      return;
    }
    _stopListeningForScroll();
    if (_scheduled) {
      SchedulerBinding.instance.ensureVisualUpdate();
    } else {
      _schedule();
    }
  }

  static void _stopListeningForScroll() {
    _scrolling?.removeListener(_handleScrollStopped);
    _scrolling = null;
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
