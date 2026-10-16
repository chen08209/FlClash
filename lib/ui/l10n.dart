import 'package:flutter/widgets.dart';

/// The text the components in `lib/ui` show of their own. The app loads it
/// from its ARB strings through a delegate it registers on the app.
abstract class UiLocalizations {
  static UiLocalizations of(BuildContext context) {
    final localizations = Localizations.of<UiLocalizations>(
      context,
      UiLocalizations,
    );
    assert(
      localizations != null,
      'No UiLocalizations found. Add the app delegate to localizationsDelegates.',
    );
    return localizations!;
  }

  String get back;

  String get cancel;

  String get clearSearch;

  String get close;

  String get hidePassword;

  String get more;

  String get noSearchResults;

  String get reset;

  String get search;

  String get showLess;

  String get showMore;

  String get showPassword;

  String get sort;

  String get submit;
}
