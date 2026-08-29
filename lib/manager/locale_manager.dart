import 'package:fl_clash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleManager extends ConsumerStatefulWidget {
  final Widget child;

  const LocaleManager({super.key, required this.child});

  @override
  ConsumerState<LocaleManager> createState() => _LocaleManagerState();
}

class _LocaleManagerState extends ConsumerState<LocaleManager> {
  Locale? _locale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.maybeLocaleOf(context);
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _locale != locale) {
        return;
      }
      ref.read(loadedLocaleProvider.notifier).value = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
