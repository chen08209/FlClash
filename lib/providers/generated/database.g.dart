// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../database.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profilesStream)
final profilesStreamProvider = ProfilesStreamProvider._();

final class ProfilesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Profile>>,
          List<Profile>,
          Stream<List<Profile>>
        >
    with $FutureModifier<List<Profile>>, $StreamProvider<List<Profile>> {
  ProfilesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profilesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profilesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Profile>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Profile>> create(Ref ref) {
    return profilesStream(ref);
  }
}

String _$profilesStreamHash() => r'ea944e081294567f0f63286e95e4e66cdc650383';

@ProviderFor(addedRulesStream)
final addedRulesStreamProvider = AddedRulesStreamFamily._();

final class AddedRulesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Rule>>,
          List<Rule>,
          Stream<List<Rule>>
        >
    with $FutureModifier<List<Rule>>, $StreamProvider<List<Rule>> {
  AddedRulesStreamProvider._({
    required AddedRulesStreamFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'addedRulesStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addedRulesStreamHash();

  @override
  String toString() {
    return r'addedRulesStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Rule>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Rule>> create(Ref ref) {
    final argument = this.argument as int;
    return addedRulesStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AddedRulesStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addedRulesStreamHash() => r'5d37e4f080094a44c2f6f84dda60d6796f4b3c99';

final class AddedRulesStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Rule>>, int> {
  AddedRulesStreamFamily._()
    : super(
        retry: null,
        name: r'addedRulesStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddedRulesStreamProvider call(int profileId) =>
      AddedRulesStreamProvider._(argument: profileId, from: this);

  @override
  String toString() => r'addedRulesStreamProvider';
}

@ProviderFor(customGroupNames)
final customGroupNamesProvider = CustomGroupNamesProvider._();

final class CustomGroupNamesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          Stream<Set<String>>
        >
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  CustomGroupNamesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customGroupNamesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customGroupNamesHash();

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    return customGroupNames(ref);
  }
}

String _$customGroupNamesHash() => r'9d3d1a6b57aeee7b4cf34afd20e28336484a5de7';

@ProviderFor(proxyGroupsCount)
final proxyGroupsCountProvider = ProxyGroupsCountFamily._();

final class ProxyGroupsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  ProxyGroupsCountProvider._({
    required ProxyGroupsCountFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'proxyGroupsCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$proxyGroupsCountHash();

  @override
  String toString() {
    return r'proxyGroupsCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as int;
    return proxyGroupsCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProxyGroupsCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$proxyGroupsCountHash() => r'9bf90fc25a9ae3b9ab7aa0784d4e47786f4c4d52';

final class ProxyGroupsCountFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, int> {
  ProxyGroupsCountFamily._()
    : super(
        retry: null,
        name: r'proxyGroupsCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProxyGroupsCountProvider call(int profileId) =>
      ProxyGroupsCountProvider._(argument: profileId, from: this);

  @override
  String toString() => r'proxyGroupsCountProvider';
}

@ProviderFor(Profiles)
final profilesProvider = ProfilesProvider._();

final class ProfilesProvider
    extends $NotifierProvider<Profiles, List<Profile>> {
  ProfilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profilesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profilesHash();

  @$internal
  @override
  Profiles create() => Profiles();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Profile> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Profile>>(value),
    );
  }
}

String _$profilesHash() => r'60f47803bd141627e5354018339d13704b00d31e';

abstract class _$Profiles extends $Notifier<List<Profile>> {
  List<Profile> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Profile>, List<Profile>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Profile>, List<Profile>>,
              List<Profile>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Scripts)
final scriptsProvider = ScriptsProvider._();

final class ScriptsProvider
    extends $StreamNotifierProvider<Scripts, List<Script>> {
  ScriptsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scriptsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scriptsHash();

  @$internal
  @override
  Scripts create() => Scripts();
}

String _$scriptsHash() => r'f88f4a2c9960c884fbc2317f754f0f968340ade2';

abstract class _$Scripts extends $StreamNotifier<List<Script>> {
  Stream<List<Script>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Script>>, List<Script>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Script>>, List<Script>>,
              AsyncValue<List<Script>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ClashProviders)
final clashProvidersProvider = ClashProvidersProvider._();

final class ClashProvidersProvider
    extends $StreamNotifierProvider<ClashProviders, List<ClashProvider>> {
  ClashProvidersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clashProvidersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clashProvidersHash();

  @$internal
  @override
  ClashProviders create() => ClashProviders();
}

String _$clashProvidersHash() => r'00588fa9c7300d3319d97d61962e898d29497188';

abstract class _$ClashProviders extends $StreamNotifier<List<ClashProvider>> {
  Stream<List<ClashProvider>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ClashProvider>>, List<ClashProvider>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ClashProvider>>, List<ClashProvider>>,
              AsyncValue<List<ClashProvider>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(IconSets)
final iconSetsProvider = IconSetsProvider._();

final class IconSetsProvider
    extends $StreamNotifierProvider<IconSets, List<IconSet>> {
  IconSetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'iconSetsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$iconSetsHash();

  @$internal
  @override
  IconSets create() => IconSets();
}

String _$iconSetsHash() => r'fe06735ac9d8c8968278e163a3fcd5a3c0deb1d9';

abstract class _$IconSets extends $StreamNotifier<List<IconSet>> {
  Stream<List<IconSet>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<IconSet>>, List<IconSet>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<IconSet>>, List<IconSet>>,
              AsyncValue<List<IconSet>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(script)
final scriptProvider = ScriptFamily._();

final class ScriptProvider
    extends $FunctionalProvider<AsyncValue<Script?>, Script?, FutureOr<Script?>>
    with $FutureModifier<Script?>, $FutureProvider<Script?> {
  ScriptProvider._({
    required ScriptFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'scriptProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$scriptHash();

  @override
  String toString() {
    return r'scriptProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Script?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Script?> create(Ref ref) {
    final argument = this.argument as int?;
    return script(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ScriptProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$scriptHash() => r'c97b48d58cef1bc928cdcfc1b292fd84ef515593';

final class ScriptFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Script?>, int?> {
  ScriptFamily._()
    : super(
        retry: null,
        name: r'scriptProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ScriptProvider call(int? scriptId) =>
      ScriptProvider._(argument: scriptId, from: this);

  @override
  String toString() => r'scriptProvider';
}

@ProviderFor(GlobalRules)
final globalRulesProvider = GlobalRulesProvider._();

final class GlobalRulesProvider
    extends $StreamNotifierProvider<GlobalRules, List<Rule>> {
  GlobalRulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'globalRulesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$globalRulesHash();

  @$internal
  @override
  GlobalRules create() => GlobalRules();
}

String _$globalRulesHash() => r'bde720c56b4914d6fc0190be3a80594840b21e47';

abstract class _$GlobalRules extends $StreamNotifier<List<Rule>> {
  Stream<List<Rule>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Rule>>, List<Rule>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Rule>>, List<Rule>>,
              AsyncValue<List<Rule>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// What the standard extension adds to a profile, or a custom profile's rules.

@ProviderFor(ProfileRules)
final profileRulesProvider = ProfileRulesFamily._();

/// What the standard extension adds to a profile, or a custom profile's rules.
final class ProfileRulesProvider
    extends $StreamNotifierProvider<ProfileRules, List<Rule>> {
  /// What the standard extension adds to a profile, or a custom profile's rules.
  ProfileRulesProvider._({
    required ProfileRulesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'profileRulesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileRulesHash();

  @override
  String toString() {
    return r'profileRulesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileRules create() => ProfileRules();

  @override
  bool operator ==(Object other) {
    return other is ProfileRulesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileRulesHash() => r'25bf8e4d02ca185036a27c951da9ca6b32422dc6';

/// What the standard extension adds to a profile, or a custom profile's rules.

final class ProfileRulesFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileRules,
          AsyncValue<List<Rule>>,
          List<Rule>,
          Stream<List<Rule>>,
          int
        > {
  ProfileRulesFamily._()
    : super(
        retry: null,
        name: r'profileRulesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What the standard extension adds to a profile, or a custom profile's rules.

  ProfileRulesProvider call(int profileId) =>
      ProfileRulesProvider._(argument: profileId, from: this);

  @override
  String toString() => r'profileRulesProvider';
}

/// What the standard extension adds to a profile, or a custom profile's rules.

abstract class _$ProfileRules extends $StreamNotifier<List<Rule>> {
  late final _$args = ref.$arg as int;
  int get profileId => _$args;

  Stream<List<Rule>> build(int profileId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Rule>>, List<Rule>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Rule>>, List<Rule>>,
              AsyncValue<List<Rule>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(ProxyGroups)
final proxyGroupsProvider = ProxyGroupsFamily._();

final class ProxyGroupsProvider
    extends $StreamNotifierProvider<ProxyGroups, List<ProxyGroup>> {
  ProxyGroupsProvider._({
    required ProxyGroupsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'proxyGroupsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$proxyGroupsHash();

  @override
  String toString() {
    return r'proxyGroupsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProxyGroups create() => ProxyGroups();

  @override
  bool operator ==(Object other) {
    return other is ProxyGroupsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$proxyGroupsHash() => r'4bf2d9e4c3c1e56fa03b91fbef29c898f6f2b052';

final class ProxyGroupsFamily extends $Family
    with
        $ClassFamilyOverride<
          ProxyGroups,
          AsyncValue<List<ProxyGroup>>,
          List<ProxyGroup>,
          Stream<List<ProxyGroup>>,
          int
        > {
  ProxyGroupsFamily._()
    : super(
        retry: null,
        name: r'proxyGroupsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProxyGroupsProvider call(int profileId) =>
      ProxyGroupsProvider._(argument: profileId, from: this);

  @override
  String toString() => r'proxyGroupsProvider';
}

abstract class _$ProxyGroups extends $StreamNotifier<List<ProxyGroup>> {
  late final _$args = ref.$arg as int;
  int get profileId => _$args;

  Stream<List<ProxyGroup>> build(int profileId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ProxyGroup>>, List<ProxyGroup>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ProxyGroup>>, List<ProxyGroup>>,
              AsyncValue<List<ProxyGroup>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(CustomProxies)
final customProxiesProvider = CustomProxiesProvider._();

final class CustomProxiesProvider
    extends $StreamNotifierProvider<CustomProxies, List<CustomProxy>> {
  CustomProxiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customProxiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customProxiesHash();

  @$internal
  @override
  CustomProxies create() => CustomProxies();
}

String _$customProxiesHash() => r'77e62a3276ffd7ca1d05f656199049570fb0c73a';

abstract class _$CustomProxies extends $StreamNotifier<List<CustomProxy>> {
  Stream<List<CustomProxy>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<CustomProxy>>, List<CustomProxy>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CustomProxy>>, List<CustomProxy>>,
              AsyncValue<List<CustomProxy>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ProxyDialers)
final proxyDialersProvider = ProxyDialersFamily._();

final class ProxyDialersProvider
    extends $StreamNotifierProvider<ProxyDialers, Map<int, String>> {
  ProxyDialersProvider._({
    required ProxyDialersFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'proxyDialersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$proxyDialersHash();

  @override
  String toString() {
    return r'proxyDialersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProxyDialers create() => ProxyDialers();

  @override
  bool operator ==(Object other) {
    return other is ProxyDialersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$proxyDialersHash() => r'ac852d78257e7fd6a4203a9e41904b2f63a9a19f';

final class ProxyDialersFamily extends $Family
    with
        $ClassFamilyOverride<
          ProxyDialers,
          AsyncValue<Map<int, String>>,
          Map<int, String>,
          Stream<Map<int, String>>,
          int
        > {
  ProxyDialersFamily._()
    : super(
        retry: null,
        name: r'proxyDialersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProxyDialersProvider call(int profileId) =>
      ProxyDialersProvider._(argument: profileId, from: this);

  @override
  String toString() => r'proxyDialersProvider';
}

abstract class _$ProxyDialers extends $StreamNotifier<Map<int, String>> {
  late final _$args = ref.$arg as int;
  int get profileId => _$args;

  Stream<Map<int, String>> build(int profileId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Map<int, String>>, Map<int, String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Map<int, String>>, Map<int, String>>,
              AsyncValue<Map<int, String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(ProfileDisabledRuleIds)
final profileDisabledRuleIdsProvider = ProfileDisabledRuleIdsFamily._();

final class ProfileDisabledRuleIdsProvider
    extends $StreamNotifierProvider<ProfileDisabledRuleIds, List<int>> {
  ProfileDisabledRuleIdsProvider._({
    required ProfileDisabledRuleIdsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'profileDisabledRuleIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileDisabledRuleIdsHash();

  @override
  String toString() {
    return r'profileDisabledRuleIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileDisabledRuleIds create() => ProfileDisabledRuleIds();

  @override
  bool operator ==(Object other) {
    return other is ProfileDisabledRuleIdsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileDisabledRuleIdsHash() =>
    r'e18d42c510b21493b28a73e88b2cbc91622d17a9';

final class ProfileDisabledRuleIdsFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileDisabledRuleIds,
          AsyncValue<List<int>>,
          List<int>,
          Stream<List<int>>,
          int
        > {
  ProfileDisabledRuleIdsFamily._()
    : super(
        retry: null,
        name: r'profileDisabledRuleIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileDisabledRuleIdsProvider call(int profileId) =>
      ProfileDisabledRuleIdsProvider._(argument: profileId, from: this);

  @override
  String toString() => r'profileDisabledRuleIdsProvider';
}

abstract class _$ProfileDisabledRuleIds extends $StreamNotifier<List<int>> {
  late final _$args = ref.$arg as int;
  int get profileId => _$args;

  Stream<List<int>> build(int profileId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<int>>, List<int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<int>>, List<int>>,
              AsyncValue<List<int>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
