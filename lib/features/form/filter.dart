import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What mihomo's regexp2, asked through the core, rejects in each filter, ''
/// where it accepts one, or null when the core cannot be asked.
Future<List<String>?> checkFilters(WidgetRef ref, List<String> filters) async {
  if (filters.every((filter) => filter.isEmpty)) {
    return [for (final _ in filters) ''];
  }
  try {
    return await ref.read(coreHandlerProvider).validateFilters(filters);
  } catch (_) {
    return null;
  }
}

// mihomo splits `filter` and `exclude-filter` on backticks and matches each
// part as its own regex, so a filter is applied by adding its parts.
const _filterSeparator = '`';

List<String> filterParts(String? value) => [
  for (final part in (value ?? '').split(_filterSeparator))
    if (part.isNotEmpty) part,
];

String? joinFilterParts(List<String> parts) =>
    parts.isEmpty ? null : parts.join(_filterSeparator);

extension FilterExt on Filter {
  bool isAppliedTo(String? value) {
    final parts = filterParts(value);
    final own = filterParts(regex);
    return own.isNotEmpty && own.every(parts.contains);
  }
}

class FilterRegexText extends StatelessWidget {
  final String regex;

  const FilterRegexText(this.regex, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      regex,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.bodySmall?.toJetBrainsMono.copyWith(
        color: context.colorScheme.tertiary,
      ),
    );
  }
}
