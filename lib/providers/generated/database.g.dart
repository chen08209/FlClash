// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../database.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profilesStream)
const profilesStreamProvider = ProfilesStreamProvider._();

final class ProfilesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Profile>>,
          List<Profile>,
          Stream<List<Profile>>
        >
    with $FutureModifier<List<Profile>>, $StreamProvider<List<Profile>> {
  const ProfilesStreamProvider._()
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

String _$profilesStreamHash() => r'483907aa6c324209b5202369300a4a53230f83db';

@ProviderFor(addedRuleStream)
const addedRuleStreamProvider = AddedRuleStreamFamily._();

final class AddedRuleStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Rule>>,
          List<Rule>,
          Stream<List<Rule>>
        >
    with $FutureModifier<List<Rule>>, $StreamProvider<List<Rule>> {
  const AddedRuleStreamProvider._({
    required AddedRuleStreamFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'addedRuleStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addedRuleStreamHash();

  @override
  String toString() {
    return r'addedRuleStreamProvider'
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
    return addedRuleStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AddedRuleStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addedRuleStreamHash() => r'491968ce795e56d4516a95676fcf46d575b3495f';

final class AddedRuleStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Rule>>, int> {
  const AddedRuleStreamFamily._()
    : super(
        retry: null,
        name: r'addedRuleStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddedRuleStreamProvider call(int profileId) =>
      AddedRuleStreamProvider._(argument: profileId, from: this);

  @override
  String toString() => r'addedRuleStreamProvider';
}

@ProviderFor(Profiles)
const profilesProvider = ProfilesProvider._();

final class ProfilesProvider
    extends $NotifierProvider<Profiles, List<Profile>> {
  const ProfilesProvider._()
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

String _$profilesHash() => r'9ba0fedd671eab4aa809eb2ce7962f8a7a71665d';

abstract class _$Profiles extends $Notifier<List<Profile>> {
  List<Profile> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Profile>, List<Profile>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Profile>, List<Profile>>,
              List<Profile>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(Scripts)
const scriptsProvider = ScriptsProvider._();

final class ScriptsProvider
    extends $StreamNotifierProvider<Scripts, List<Script>> {
  const ScriptsProvider._()
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

String _$scriptsHash() => r'a784e9986eae864229a1035cc28ce4f3ec4644a0';

abstract class _$Scripts extends $StreamNotifier<List<Script>> {
  Stream<List<Script>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Script>>, List<Script>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Script>>, List<Script>>,
              AsyncValue<List<Script>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(GlobalRules)
const globalRulesProvider = GlobalRulesProvider._();

final class GlobalRulesProvider
    extends $StreamNotifierProvider<GlobalRules, List<Rule>> {
  const GlobalRulesProvider._()
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

String _$globalRulesHash() => r'3ed947f389649a86d5c6d78d8c02ba5b8d0f7119';

abstract class _$GlobalRules extends $StreamNotifier<List<Rule>> {
  Stream<List<Rule>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Rule>>, List<Rule>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Rule>>, List<Rule>>,
              AsyncValue<List<Rule>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ProfileAddedRules)
const profileAddedRulesProvider = ProfileAddedRulesFamily._();

final class ProfileAddedRulesProvider
    extends $StreamNotifierProvider<ProfileAddedRules, List<Rule>> {
  const ProfileAddedRulesProvider._({
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

String _$profileAddedRulesHash() => r'4155448335cf14a8928db6adf68e59572aa4ce47';

final class ProfileAddedRulesFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileAddedRules,
          AsyncValue<List<Rule>>,
          List<Rule>,
          Stream<List<Rule>>,
          int
        > {
  const ProfileAddedRulesFamily._()
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
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<Rule>>, List<Rule>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Rule>>, List<Rule>>,
              AsyncValue<List<Rule>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ProfileDisabledRuleIds)
const profileDisabledRuleIdsProvider = ProfileDisabledRuleIdsFamily._();

final class ProfileDisabledRuleIdsProvider
    extends $StreamNotifierProvider<ProfileDisabledRuleIds, List<int>> {
  const ProfileDisabledRuleIdsProvider._({
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
    r'22d6e68bcee55b42fbb909e7f66e5c7095935224';

final class ProfileDisabledRuleIdsFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileDisabledRuleIds,
          AsyncValue<List<int>>,
          List<int>,
          Stream<List<int>>,
          int
        > {
  const ProfileDisabledRuleIdsFamily._()
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
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<int>>, List<int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<int>>, List<int>>,
              AsyncValue<List<int>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
