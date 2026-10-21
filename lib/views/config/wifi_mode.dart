import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class WifiModeSection extends ConsumerWidget {
  const WifiModeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final settings = ref.watch(wifiModeSettingProvider);
    final ssid = ref.watch(currentSSIDProvider);
    return generateSection(
      title: l.wifiMode,
      items: [
        ConfigToggleItem(
          title: (l) => l.wifiMode,
          selector: wifiModeSettingProvider.select((state) => state.enabled),
          onChanged: (ref, value) {
            ref
                .read(wifiModeSettingProvider.notifier)
                .update((state) => state.copyWith(enabled: value));
            if (value) {
              unawaited(
                ref.read(locationPermissionsProvider.notifier).refresh(),
              );
            }
          },
        ),
        if (settings.enabled)
          ListItem(
            title: Text(l.currentSsid),
            subtitle: Text(ssid ?? l.ssidUnavailable),
          ),
        ConfigOptionsItem<Mode>(
          title: (l) => l.wifiModeFallback,
          options: Mode.values,
          textBuilder: (mode) => mode.label,
          selector: wifiModeSettingProvider.select((state) => state.fallback),
          onChanged: (ref, value) => ref
              .read(wifiModeSettingProvider.notifier)
              .update((state) => state.copyWith(fallback: value)),
        ),
        ListItem.open(
          title: Text(l.wifiModeRules),
          subtitle: Text(l.itemsCount(settings.rules.length)),
          widget: const _WifiModeRulesView(),
        ),
      ],
      footer: l.wifiModeDesc,
    );
  }
}

Future<void> editWifiModeRule(
  BuildContext context,
  WidgetRef ref, [
  MapEntry<String, Mode>? entry,
]) async {
  final settings = ref.read(wifiModeSettingProvider);
  final result = await showFormSheet<MapEntry<String, Mode>>(
    context: context,
    builder: (_) => _WifiModeForm(
      entry: entry,
      initialSsid: ref.read(currentSSIDProvider),
      reserved: settings.rules.keys.where((ssid) => ssid != entry?.key).toSet(),
    ),
  );
  if (result == null || !context.mounted) return;
  ref.read(wifiModeSettingProvider.notifier).update((state) {
    final rules = {...state.rules};
    if (entry != null) rules.remove(entry.key);
    rules[result.key] = result.value;
    return state.copyWith(rules: rules);
  });
}

class _WifiModeRulesView extends ConsumerWidget {
  const _WifiModeRulesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    return ListEditorPage<MapEntry<String, Mode>, String>(
      title: l.wifiModeRules,
      itemsOf: (ref) =>
          ref.watch(wifiModeSettingProvider).rules.entries.toList(),
      idOf: (entry) => entry.key,
      searchFieldsOf: (entry) => [entry.key],
      itemBuilder: (context, ref, entry, index, editing, selected, toggle) =>
          DecorationListItem(
            title: Text(entry.key),
            subtitle: Text(entry.value.label),
            isSelected: selected,
            onPressed: editing
                ? toggle
                : () => editWifiModeRule(context, ref, entry),
            trailing: CommonCheckBox(
              value: selected,
              isCircle: true,
              onChanged: (_) => toggle(),
            ),
          ),
      onAdd: () => editWifiModeRule(context, ref),
      onDelete: (ssids) => ref
          .read(wifiModeSettingProvider.notifier)
          .update(
            (state) => state.copyWith(
              rules: {
                for (final entry in state.rules.entries)
                  if (!ssids.contains(entry.key)) entry.key: entry.value,
              },
            ),
          ),
      onReorder: (oldIndex, newIndex) => ref
          .read(wifiModeSettingProvider.notifier)
          .update(
            (state) => state.copyWith(
              rules: Map.fromEntries(
                state.rules.entries.toList().copyAndReorder(oldIndex, newIndex),
              ),
            ),
          ),
      emptyLabel: l.ssidsEmpty,
    );
  }
}

class _WifiModeForm extends StatefulWidget {
  const _WifiModeForm({
    required this.entry,
    required this.initialSsid,
    required this.reserved,
  });

  final MapEntry<String, Mode>? entry;
  final String? initialSsid;
  final Set<String> reserved;

  @override
  State<_WifiModeForm> createState() => _WifiModeFormState();
}

class _WifiModeFormState extends State<_WifiModeForm> {
  late final _controller = TextEditingController(
    text: widget.entry?.key ?? widget.initialSsid ?? '',
  );
  late Mode _mode = widget.entry?.value ?? Mode.direct;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final l = context.appLocalizations;
    final ssid = _controller.text;
    final error = ssid.isEmpty
        ? l.emptyTip('SSID')
        : utf8.encode(ssid).length > 32
        ? l.ssidTooLong
        : widget.reserved.contains(ssid)
        ? l.existsTip('SSID')
        : null;
    setState(() => _error = error);
    if (error == null) Navigator.of(context).pop(MapEntry(ssid, _mode));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return FormPage(
      title: widget.entry == null ? l.addSsid : l.editSsid,
      onSave: _save,
      error: _error,
      children: [
        generateSection(
          items: [
            FormRow(
              title: 'SSID',
              invalid: _error != null,
              trailing: FormRowTextField(
                controller: _controller,
                autofocus: true,
                autocorrect: false,
                hintText: l.required,
                inputFormatters: TextInputLimits.limit(32),
                onFieldSubmitted: (_) => _save(),
              ),
            ),
            ListItem<Mode>.options(
              title: Text(l.outboundMode),
              options: Mode.values,
              value: _mode,
              textBuilder: (mode) => mode.label,
              onChanged: (value) => setState(() => _mode = value),
            ),
          ],
        ),
      ],
    );
  }
}
