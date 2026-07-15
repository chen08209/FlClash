import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProxyBypass extends ConsumerWidget {
  const ProxyBypass({super.key});

  void _showOptions(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    showSheet(
      context: context,
      builder: (_) {
        return AdaptiveSheetScaffold(
          title: appLocalizations.bypassDomain,
          body: const _ProxyBypassList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final bypassDomain = ref.watch(
      networkSettingProvider.select((state) => state.bypassDomain),
    );
    final systemProxy = system.isAndroid
        ? ref.watch(vpnSettingProvider.select((state) => state.systemProxy))
        : ref.watch(
            networkSettingProvider.select((state) => state.systemProxy),
          );
    return SizedBox(
      height: getWidgetHeight(1),
      child: CommonCard(
        onPressed: () {
          _showOptions(context);
        },
        info: Info(
          label: appLocalizations.bypassDomain,
          iconData: Icons.alt_route,
        ),
        child: Container(
          padding: baseInfoEdgeInsets.copyWith(top: 4, bottom: 8, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 1,
                child: TooltipText(
                  text: Text(
                    '${bypassDomain.length}${appLocalizations.entries}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.toLight.adjustSize(1),
                  ),
                ),
              ),
              Switch(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: systemProxy,
                onChanged: (value) {
                  if (system.isAndroid) {
                    ref
                        .read(vpnSettingProvider.notifier)
                        .update((state) => state.copyWith(systemProxy: value));
                    return;
                  }
                  ref
                      .read(networkSettingProvider.notifier)
                      .update((state) => state.copyWith(systemProxy: value));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProxyBypassList extends ConsumerStatefulWidget {
  const _ProxyBypassList();

  @override
  ConsumerState<_ProxyBypassList> createState() => _ProxyBypassListState();
}

class _ProxyBypassListState extends ConsumerState<_ProxyBypassList> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateItems(List<String> items) {
    ref
        .read(networkSettingProvider.notifier)
        .update((state) => state.copyWith(bypassDomain: items));
  }

  String? _validate(String? value, List<String> items) {
    final appLocalizations = context.appLocalizations;
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return appLocalizations.nullTip(appLocalizations.value);
    }
    if (items.contains(text)) {
      return appLocalizations.existsTip(appLocalizations.value);
    }
    return null;
  }

  void _handleAdd(List<String> items) {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    final value = _controller.text.trim();
    _updateItems([...items, value]);
    _controller.clear();
    _formKey.currentState?.reset();
  }

  void _handleDelete(List<String> items, String item) {
    final nextItems = List<String>.from(items)..remove(item);
    _updateItems(nextItems);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final items = ref.watch(
      networkSettingProvider.select((state) => state.bypassDomain),
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    inputFormatters: TextInputLimits.limit(
                      TextInputLimits.domain,
                    ),
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: appLocalizations.value,
                    ),
                    validator: (value) => _validate(value, items),
                    onFieldSubmitted: (_) {
                      _handleAdd(items);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: appLocalizations.add,
                  onPressed: () {
                    _handleAdd(items);
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? NullStatus(label: appLocalizations.noData)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.only(left: 12, right: 4),
                      title: TooltipText(
                        text: Text(
                          item,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: IconButton(
                        tooltip: appLocalizations.delete,
                        onPressed: () {
                          _handleDelete(items, item);
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
