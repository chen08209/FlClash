import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef OverrideState<K extends OverrideKey, M> = ({M model, Set<K> keys});

abstract interface class OverrideModel<M> {
  ProviderListenable<T> selectModel<T>(T Function(M model) select);

  ConfigWriter<T> modelWriter<T>(M Function(M model, T value) update);
}

/// Where an override page keeps its model and the keys picked from it.
abstract class OverrideTarget<K extends OverrideKey, M>
    implements OverrideModel<M> {
  const OverrideTarget();

  ConfigLabel get description;

  ConfigLabel get entries;

  ConfigLabel get addEntry;

  ProviderListenable<List<CustomIssue>>? get issues => null;

  ProviderListenable<T> select<T>(T Function(OverrideState<K, M> state) select);

  OverrideState<K, M> read(WidgetRef ref);

  void update(
    WidgetRef ref,
    OverrideState<K, M> Function(OverrideState<K, M> state) update,
  );

  @override
  ProviderListenable<T> selectModel<T>(T Function(M model) select) =>
      this.select((state) => select(state.model));

  @override
  ConfigWriter<T> modelWriter<T>(M Function(M model, T value) update) =>
      (ref, value) => this.update(
        ref,
        (state) => (model: update(state.model, value), keys: state.keys),
      );
}

class PatchOverrideTarget<K extends OverrideKey, M>
    extends OverrideTarget<K, M> {
  const PatchOverrideTarget({
    required this.get,
    required this.set,
    required this.description,
  });

  final OverrideState<K, M> Function(PatchClashConfig config) get;
  final PatchClashConfig Function(
    PatchClashConfig config,
    OverrideState<K, M> state,
  )
  set;

  @override
  final ConfigLabel description;

  @override
  ConfigLabel get entries =>
      (l) => l.overrideEntries;

  @override
  ConfigLabel get addEntry =>
      (l) => l.addOverrideEntry;

  @override
  ProviderListenable<T> select<T>(
    T Function(OverrideState<K, M> state) select,
  ) => patchClashConfigProvider.select((config) => select(get(config)));

  @override
  OverrideState<K, M> read(WidgetRef ref) =>
      get(ref.read(patchClashConfigProvider));

  @override
  void update(
    WidgetRef ref,
    OverrideState<K, M> Function(OverrideState<K, M> state) update,
  ) {
    ref
        .read(patchClashConfigProvider.notifier)
        .update((config) => set(config, update(get(config))));
  }
}

class ProfileOverrideTarget<K extends OverrideKey, M>
    extends OverrideTarget<K, M> {
  const ProfileOverrideTarget(
    this.profileId, {
    required this.get,
    required this.set,
    this.issues,
  });

  final int profileId;

  @override
  final ProviderListenable<List<CustomIssue>>? issues;
  final OverrideState<K, M> Function(ProfileOverrides overrides) get;
  final ProfileOverrides Function(
    ProfileOverrides overrides,
    OverrideState<K, M> state,
  )
  set;

  @override
  ConfigLabel get description =>
      (l) => l.profileSettingsDesc;

  @override
  ConfigLabel get entries =>
      (l) => l.settingEntries;

  @override
  ConfigLabel get addEntry =>
      (l) => l.addSettingEntry;

  ProfileOverrides _of(Profile? profile) =>
      profile?.overrides ?? const ProfileOverrides();

  @override
  ProviderListenable<T> select<T>(
    T Function(OverrideState<K, M> state) select,
  ) =>
      profileProvider(profileId).select((profile) => select(get(_of(profile))));

  @override
  OverrideState<K, M> read(WidgetRef ref) =>
      get(_of(ref.read(profileProvider(profileId))));

  @override
  void update(
    WidgetRef ref,
    OverrideState<K, M> Function(OverrideState<K, M> state) update,
  ) {
    ref
        .read(profilesProvider.notifier)
        .updateProfile(
          profileId,
          (profile) => profile.copyWith(
            overrides: set(profile.overrides, update(get(profile.overrides))),
          ),
        );
  }
}

abstract class OverrideField<M> {
  const OverrideField();

  Widget build(
    OverrideModel<M> model, {
    required ConfigLabel title,
    required Widget leading,
  });

  M reset(M model, M defaults);
}

abstract class ValueOverrideField<M, T> extends OverrideField<M> {
  const ValueOverrideField(this.select, this.update);

  final T Function(M model) select;
  final M Function(M model, T value) update;

  @override
  M reset(M model, M defaults) => update(model, select(defaults));
}

class ToggleOverrideField<M> extends ValueOverrideField<M, bool> {
  const ToggleOverrideField(super.select, super.update);

  @override
  Widget build(
    OverrideModel<M> model, {
    required ConfigLabel title,
    required Widget leading,
  }) {
    return ConfigToggleItem(
      leading: leading,
      title: title,
      selector: model.selectModel(select),
      onChanged: model.modelWriter(update),
    );
  }
}

class OptionsOverrideField<M, T extends Enum> extends ValueOverrideField<M, T> {
  const OptionsOverrideField(
    this.options,
    super.select,
    super.update, {
    this.labelOf = _enumName,
  });

  final List<T> options;
  final String Function(T value) labelOf;

  static String _enumName(Enum value) => value.name;

  @override
  Widget build(
    OverrideModel<M> model, {
    required ConfigLabel title,
    required Widget leading,
  }) {
    return ConfigOptionsItem<T>(
      leading: leading,
      title: title,
      options: options,
      textBuilder: labelOf,
      selector: model.selectModel(select),
      onChanged: model.modelWriter(update),
    );
  }
}

class NumberOverrideField<M> extends ValueOverrideField<M, int> {
  const NumberOverrideField(
    super.select,
    super.update, {
    this.min = 0,
    this.max = 0x7fffffff,
    this.maxLength = TextInputLimits.number,
  });

  final int min;
  final int max;
  final int maxLength;

  String? _validate(String? value, ConfigLabel title) {
    final number = int.tryParse(value?.trim() ?? '');
    return number == null || number < min || number > max
        ? currentAppLocalizations.numberTip(title(currentAppLocalizations))
        : null;
  }

  @override
  Widget build(
    OverrideModel<M> model, {
    required ConfigLabel title,
    required Widget leading,
  }) {
    return ConfigTextItem(
      leading: leading,
      title: title,
      selector: model.selectModel((model) => '${select(model)}'),
      onChanged: model.modelWriter<String>(
        (model, value) => update(model, int.parse(value)),
      ),
      maxLength: maxLength,
      keyboardType: TextInputType.number,
      normalize: (value) => value.trim(),
      validator: (value, _) => _validate(value, title),
    );
  }
}

class TextOverrideField<M> extends ValueOverrideField<M, String> {
  const TextOverrideField(
    super.select,
    super.update, {
    required this.maxLength,
    this.validator,
  });

  final int maxLength;
  final ConfigValidator? validator;

  @override
  Widget build(
    OverrideModel<M> model, {
    required ConfigLabel title,
    required Widget leading,
  }) {
    return ConfigTextItem(
      leading: leading,
      title: title,
      selector: model.selectModel(select),
      onChanged: model.modelWriter(update),
      maxLength: maxLength,
      normalize: (value) => value.trim(),
      validator: validator,
    );
  }
}

class ListOverrideField<M> extends ValueOverrideField<M, List<String>> {
  const ListOverrideField(
    super.select,
    super.update, {
    required this.itemMaxLength,
    this.itemValidator,
  });

  final int itemMaxLength;
  final ConfigValidator? itemValidator;

  @override
  Widget build(
    OverrideModel<M> model, {
    required ConfigLabel title,
    required Widget leading,
  }) {
    return ConfigListEditItem(
      leading: leading,
      title: title,
      selector: model.selectModel(select),
      onChanged: model.modelWriter(update),
      itemMaxLength: itemMaxLength,
      itemValidator: itemValidator,
    );
  }
}

abstract class OverrideSpec<K extends OverrideKey, M> {
  const OverrideSpec();

  OverrideTarget<K, M> get target;

  String title(AppLocalizations l);

  List<K> get values;

  NullStatusIllustration get illustration;

  /// What a newly added key starts from.
  M get defaults;

  String sectionOf(K key, AppLocalizations l) => l.options;

  String label(K key, AppLocalizations l);

  ConfigLabel? description(K key);

  OverrideField<M> fieldOf(K key);

  void updateKeys(WidgetRef ref, Set<K> Function(Set<K> keys) update) {
    target.update(
      ref,
      (state) => (model: state.model, keys: update(state.keys)),
    );
  }

  List<(String, List<K>)> sectionsOf(AppLocalizations l, Iterable<K> keys) {
    final sections = <String, List<K>>{};
    for (final key in keys) {
      sections.putIfAbsent(sectionOf(key, l), () => []).add(key);
    }
    return [
      for (final MapEntry(:key, :value) in sections.entries) (key, value),
    ];
  }
}

mixin OverrideQuickEdit<K extends OverrideKey, M> on OverrideSpec<K, M> {
  String overrideYaml(M model, Set<K> keys);

  /// Throws when [content] names a key outside [values] or a value the model
  /// cannot hold.
  OverrideState<K, M> applyOverrideYaml(M model, String content);

  EditorSchema get schema;
}

class OverrideView<K extends OverrideKey, M> extends ConsumerWidget {
  const OverrideView({super.key, required this.spec});

  final OverrideSpec<K, M> spec;

  void _handleAdd(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final added = spec.target.read(ref).keys;
    final remaining = spec.values.where((key) => !added.contains(key));
    showSheet<void>(
      context: context,
      builder: (_) => SelectionSheet<K>(
        title: spec.target.addEntry(appLocalizations),
        sections: [
          for (final (label, keys) in spec.sectionsOf(
            appLocalizations,
            remaining,
          ))
            SelectionSection(
              label: label,
              items: keys,
              subtitleBuilder: (context, key) =>
                  spec.description(key)?.call(context.appLocalizations),
            ),
        ],
        labelBuilder: (key) => spec.label(key, appLocalizations),
        selectedOf: (_) => null,
        removeOnSelect: true,
        onSelected: (key) {
          if (!context.mounted) {
            return;
          }
          spec.target.update(
            ref,
            (state) => (
              model: spec.fieldOf(key).reset(state.model, spec.defaults),
              keys: {...state.keys, key},
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleQuickEdit(
    BuildContext context,
    WidgetRef ref,
    OverrideQuickEdit<K, M> quickEdit,
  ) {
    final state = spec.target.read(ref);
    final raw = quickEdit.overrideYaml(state.model, state.keys);
    final page = EditorPage(
      title: spec.title(context.appLocalizations),
      content: raw,
      schema: quickEdit.schema,
      readOnly: false,
      onPop: (_, _, content) =>
          _handleQuickEditPop(ref, quickEdit, content, raw),
    );
    return sheetNavigatorOf(context).push(
      context.isMobileView
          ? CommonRoute(builder: (_) => page)
          : CommonDesktopRoute(builder: (_) => page),
    );
  }

  Future<bool> _handleQuickEditPop(
    WidgetRef ref,
    OverrideQuickEdit<K, M> quickEdit,
    String content,
    String raw,
  ) async {
    if (content == raw) {
      return true;
    }
    try {
      spec.target.update(
        ref,
        (state) => readRelaxed(
          content,
          quickEdit.schema,
          (content) => quickEdit.applyOverrideYaml(state.model, content),
        ),
      );
      return true;
    } catch (error) {
      final res = await dialogs.showMessage(
        message: TextSpan(
          text:
              '${compactError(error)}\n\n'
              '${currentAppLocalizations.discardChanges}',
        ),
      );
      return res == true;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final spec = this.spec;
    final target = spec.target;
    final (:isEmpty, :canAdd) = ref.watch(
      target.select(
        (state) => (
          isEmpty: !spec.values.any(state.keys.contains),
          canAdd: spec.values.any((key) => !state.keys.contains(key)),
        ),
      ),
    );
    final addEntry = target.addEntry(appLocalizations);
    return CommonScaffold(
      title: spec.title(appLocalizations),
      iconActions: [
        if (!isEmpty)
          IconButtonData(
            glyph: AppGlyphs.addCircle,
            onPressed: canAdd ? () => _handleAdd(context, ref) : null,
            tooltip: addEntry,
          ),
        if (spec is OverrideQuickEdit<K, M>)
          IconButtonData(
            glyph: AppGlyphs.compose,
            onPressed: () => _handleQuickEdit(context, ref, spec),
            tooltip: appLocalizations.quickEdit,
          ),
      ],
      body: NullStatusSwitcher(
        isEmpty: isEmpty,
        nullStatus: NullStatus(
          label: appLocalizations.nullTip(target.entries(appLocalizations)),
          description: target.description(appLocalizations),
          illustration: spec.illustration,
          action: ElasticButton(
            child: FilledButton.tonalIcon(
              onPressed: () => _handleAdd(context, ref),
              icon: const GlyphIcon(AppGlyphs.addCircle, fill: 1),
              label: Text(addEntry),
            ),
          ),
        ),
        child: _OverrideList(spec: spec),
      ),
    );
  }
}

class _OverrideList<K extends OverrideKey, M> extends ConsumerWidget {
  const _OverrideList({required this.spec});

  final OverrideSpec<K, M> spec;

  String? _footerOf(List<K> keys, AppLocalizations appLocalizations) {
    final lines = [
      for (final key in keys) ?spec.description(key)?.call(appLocalizations),
    ];
    return lines.isEmpty ? null : lines.join('\n');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final keys = ref.watch(spec.target.select((state) => state.keys));
    final entries = spec.values.where(keys.contains);
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ).copyWith(top: context.contentTopPadding, bottom: 16),
      children: [
        if (spec.target.issues case final issues?)
          CustomIssuesBanner(issues: ref.watch(issues)),
        AnimatedEntries(
          children: [
            for (final (title, keys) in spec.sectionsOf(
              appLocalizations,
              entries,
            ))
              KeyedSubtree(
                key: ValueKey(title),
                child: generateAnimatedSection(
                  title: title,
                  footer: _footerOf(keys, appLocalizations),
                  items: [
                    for (final key in keys)
                      KeyedSubtree(
                        key: ValueKey(key),
                        child: spec
                            .fieldOf(key)
                            .build(
                              spec.target,
                              title: (l) => spec.label(key, l),
                              leading: _RemoveButton(
                                spec: spec,
                                overrideKey: key,
                              ),
                            ),
                      ),
                  ],
                ),
              ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 16.mAp),
          child: ListFooter(text: spec.target.description(appLocalizations)),
        ),
      ],
    );
  }
}

class _RemoveButton<K extends OverrideKey, M> extends ConsumerWidget {
  const _RemoveButton({required this.spec, required this.overrideKey});

  final OverrideSpec<K, M> spec;
  final K overrideKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EntryButton.remove(
      onPressed: () =>
          spec.updateKeys(ref, (keys) => {...keys}..remove(overrideKey)),
    );
  }
}
