import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _defaultValue = '';

List<String> _visibleUserAgents(List<String> saved, String? selected) =>
    {...saved, ?selected}.toList();

class UserAgentsView extends ConsumerStatefulWidget {
  const UserAgentsView({super.key});

  @override
  ConsumerState<UserAgentsView> createState() => _UserAgentsViewState();
}

class _UserAgentsViewState extends ConsumerState<UserAgentsView> {
  String? get _selected => ref.read(patchClashConfigProvider).globalUa;

  List<String> get _entries =>
      _visibleUserAgents(ref.read(appSettingProvider).userAgents, _selected);

  void _save(List<String> userAgents) {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(userAgents: userAgents));
  }

  void _select(String? userAgent) {
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(globalUa: userAgent));
  }

  Future<String?> _showInputDialog([String? userAgent]) async {
    final appLocalizations = context.appLocalizations;
    final entries = _entries;
    final res = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: userAgent == null ? appLocalizations.add : appLocalizations.edit,
        value: userAgent ?? '',
        labelText: appLocalizations.userAgent,
        inputFormatters: [
          FilteringTextInputFormatter.singleLineFormatter,
          ...TextInputLimits.limit(TextInputLimits.userAgent),
        ],
        validator: (value) {
          final next = value?.trim() ?? '';
          if (next.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.userAgent);
          }
          if (next != userAgent && entries.contains(next)) {
            return appLocalizations.existsTip(appLocalizations.userAgent);
          }
          return null;
        },
      ),
    );
    return res?.trim();
  }

  Future<void> _handleAdd() async {
    final userAgent = await _showInputDialog();
    if (!mounted || userAgent == null) {
      return;
    }
    _save([..._entries, userAgent]);
  }

  Future<void> _handleEdit(String userAgent) async {
    final next = await _showInputDialog(userAgent);
    if (!mounted || next == null || next == userAgent) {
      return;
    }
    _save([for (final item in _entries) item == userAgent ? next : item]);
    if (_selected == userAgent) {
      _select(next);
    }
  }

  Future<void> _handleDelete(String userAgent) async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.userAgent),
      ),
    );
    if (!mounted || res != true) {
      return;
    }
    _save([..._entries]..remove(userAgent));
    if (_selected == userAgent) {
      _select(null);
    }
  }

  Widget _buildRadioGroup(String? selected, Widget child) {
    return RadioGroup<String>(
      groupValue: selected ?? _defaultValue,
      onChanged: (value) {
        if (value == null) {
          return;
        }
        _select(value == _defaultValue ? null : value);
      },
      child: child,
    );
  }

  Widget _buildItem(List<String> entries, int index, String? selected) {
    final userAgent = entries[index];
    return ItemPositionProvider(
      position: ItemPosition.get(index + 1, entries.length + 1),
      child: _UserAgentItem(
        value: userAgent,
        label: userAgent,
        isSelected: userAgent == selected,
        onSelected: () {
          _select(userAgent);
        },
        trailing: _UserAgentItemMenu(
          onEdit: () {
            _handleEdit(userAgent);
          },
          onDelete: () {
            _handleDelete(userAgent);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final userAgents = ref.watch(
      appSettingProvider.select((state) => state.userAgents),
    );
    final selected = ref.watch(
      patchClashConfigProvider.select((state) => state.globalUa),
    );
    final entries = _visibleUserAgents(userAgents, selected);
    return BaseScaffold(
      title: appLocalizations.userAgent,
      actions: [
        FilledButton.tonal(
          onPressed: _handleAdd,
          child: Text(appLocalizations.add),
        ),
      ],
      body: _buildRadioGroup(
        selected,
        ReorderableListView.builder(
          padding: const EdgeInsets.all(
            16,
          ).copyWith(top: context.contentTopPadding),
          buildDefaultDragHandles: false,
          header: ItemPositionProvider(
            position: ItemPosition.get(0, entries.length + 1),
            child: _UserAgentItem(
              value: _defaultValue,
              label: appLocalizations.defaultText,
              isSelected: selected == null,
              onSelected: () {
                _select(null);
              },
            ),
          ),
          itemCount: entries.length,
          itemBuilder: (_, index) {
            return ReorderableDelayedDragStartListener(
              key: ValueKey(entries[index]),
              index: index,
              child: _buildItem(entries, index, selected),
            );
          },
          // The drag proxy is built in the navigator overlay, outside the
          // page's RadioGroup.
          proxyDecorator: (_, index, animation) {
            return commonProxyDecorator(
              _buildRadioGroup(selected, _buildItem(entries, index, selected)),
              index,
              animation,
            );
          },
          onReorderItem: (oldIndex, newIndex) {
            _save(entries.copyAndReorder(oldIndex, newIndex));
          },
        ),
      ),
    );
  }
}

class _UserAgentItem extends StatelessWidget {
  const _UserAgentItem({
    required this.value,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.trailing,
  });

  final String value;
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return DecorationListItem(
      isSelected: isSelected,
      horizontalTitleGap: 8,
      contentPadding: EdgeInsets.only(
        left: 14,
        right: trailing == null ? 16 : 6,
      ),
      leading: SizedBox.square(
        dimension: 24,
        child: ExcludeFocus(
          child: Radio<String>(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            value: value,
          ),
        ),
      ),
      title: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: trailing,
      onPressed: onSelected,
    );
  }
}

class _UserAgentItemMenu extends StatelessWidget {
  const _UserAgentItemMenu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonPopupBox(
      popupBuilder: (_) => CommonPopupMenu(
        items: [
          CommonPopupMenuItem(
            glyph: AppGlyphs.edit,
            label: appLocalizations.edit,
            onPressed: onEdit,
          ),
          CommonPopupMenuItem(
            danger: true,
            glyph: AppGlyphs.delete,
            label: appLocalizations.delete,
            onPressed: onDelete,
          ),
        ],
      ),
      targetBuilder: (open) {
        return IconButton(
          style: IconButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.standard,
          ),
          tooltip: appLocalizations.more,
          onPressed: () {
            open();
          },
          icon: const GlyphIcon(AppGlyphs.more),
        );
      },
    );
  }
}
