import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

extension AppContextExtension on BuildContext {
  AppLocalizations get appLocalizations => AppLocalizations.of(this);
}
