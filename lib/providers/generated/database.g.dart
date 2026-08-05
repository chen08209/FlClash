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

@ProviderFor(customRulesCount)
final customRulesCountProvider = CustomRulesCountFamily._();

final class CustomRulesCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  CustomRulesCountProvider._({
    required CustomRulesCountFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'customRulesCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customRulesCountHash();

  @override
  String toString() {
    return r'customRulesCountProvider'
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
    return customRulesCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomRulesCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customRulesCountHash() => r'a3ff7941bcbb2696ba48c82b9310d81d7238536f';

final class CustomRulesCountFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, int> {
  CustomRulesCountFamily._()
    : super(
        retry: null,
        name: r'customRulesCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomRulesCountProvider call(int profileId) =>
      CustomRulesCountProvider._(argument: profileId, from: this);

  @override
  String toString() => r'customRulesCountProvider';
}

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

String _$profilesHash() => r'610b51558ceaf0dc12795756e9bd8e4f73880e22';

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

String _$scriptsHash() => r'363611e5787ec107459446f305e35dada3e07cad';

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

String _$globalRulesHash() => r'209223171050c7d26de48537f8ff4f14d6fe5b1d';

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

@ProviderFor(ProfileAddedRules)
final profileAddedRulesProvider = ProfileAddedRulesFamily._();

final class ProfileAddedRulesProvider
    extends $StreamNotifierProvider<ProfileAddedRules, List<Rule>> {
  ProfileAddedRulesProvider._({
    required ProfileAddedRulesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'profileAddedRulesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileAddedRulesHash();

  @override
  String toString() {
    return r'profileAddedRulesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileAddedRules create() => ProfileAddedRules();

  @override
  bool operator ==(Object other) {
    return other is ProfileAddedRulesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileAddedRulesHash() => r'eae5aef723d5fa858c35a530bca21aa0f80f00ad';

final class ProfileAddedRulesFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileAddedRules,
          AsyncValue<List<Rule>>,
          List<Rule>,
          Stream<List<Rule>>,
          int
        > {
  ProfileAddedRulesFamily._()
    : super(
        retry: null,
        name: r'profileAddedRulesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileAddedRulesProvider call(int profileId) =>
      ProfileAddedRulesProvider._(argument: profileId, from: this);

  @override
  String toString() => r'profileAddedRulesProvider';
}

abstract class _$ProfileAddedRules extends $StreamNotifier<List<Rule>> {
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

@ProviderFor(ProfileCustomRules)
final profileCustomRulesProvider = ProfileCustomRulesFamily._();

final class ProfileCustomRulesProvider
    extends $StreamNotifierProvider<ProfileCustomRules, List<Rule>> {
  ProfileCustomRulesProvider._({
    required ProfileCustomRulesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'profileCustomRulesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileCustomRulesHash();

  @override
  String toString() {
    return r'profileCustomRulesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileCustomRules create() => ProfileCustomRules();

  @override
  bool operator ==(Object other) {
    return other is ProfileCustomRulesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileCustomRulesHash() =>
    r'89a8547b746e4c4ff0b1f5ac2dd0b573d1e5892e';

final class ProfileCustomRulesFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileCustomRules,
          AsyncValue<List<Rule>>,
          List<Rule>,
          Stream<List<Rule>>,
          int
        > {
  ProfileCustomRulesFamily._()
    : super(
        retry: null,
        name: r'profileCustomRulesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileCustomRulesProvider call(int profileId) =>
      ProfileCustomRulesProvider._(argument: profileId, from: this);

  @override
  String toString() => r'profileCustomRulesProvider';
}

abstract class _$ProfileCustomRules extends $StreamNotifier<List<Rule>> {
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

String _$proxyGroupsHash() => r'78aa494f41c48600612d1376e1f4a931e8a21aef';

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
    r'8fdd7dc5c5ff51e7d9474c0351887073e3f8d468';

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
