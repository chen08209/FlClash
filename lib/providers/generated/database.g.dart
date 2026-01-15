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

@ProviderFor(scriptsStream)
const scriptsStreamProvider = ScriptsStreamProvider._();

final class ScriptsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Script>>,
          List<Script>,
          Stream<List<Script>>
        >
    with $FutureModifier<List<Script>>, $StreamProvider<List<Script>> {
  const ScriptsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scriptsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scriptsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Script>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Script>> create(Ref ref) {
    return scriptsStream(ref);
  }
}

String _$scriptsStreamHash() => r'51ce8ca517b26ceba3539ff32ddbf75fc6ac276e';

@ProviderFor(rulesStream)
const rulesStreamProvider = RulesStreamProvider._();

final class RulesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Rule>>,
          List<Rule>,
          Stream<List<Rule>>
        >
    with $FutureModifier<List<Rule>>, $StreamProvider<List<Rule>> {
  const RulesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rulesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rulesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Rule>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Rule>> create(Ref ref) {
    return rulesStream(ref);
  }
}

String _$rulesStreamHash() => r'2a8ad5a820460de584ad78e6cd72dc5d7c22fac8';

@ProviderFor(globalRulesStream)
const globalRulesStreamProvider = GlobalRulesStreamProvider._();

final class GlobalRulesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Rule>>,
          List<Rule>,
          Stream<List<Rule>>
        >
    with $FutureModifier<List<Rule>>, $StreamProvider<List<Rule>> {
  const GlobalRulesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'globalRulesStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$globalRulesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Rule>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Rule>> create(Ref ref) {
    return globalRulesStream(ref);
  }
}

String _$globalRulesStreamHash() => r'5f8cf7d59390358a8b4725e6a6120e9129cb9393';

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
        isAutoDispose: true,
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

String _$profilesHash() => r'9c213e9ef58883c8d9d88ace7d42f5c85eec3bd6';

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

final class ScriptsProvider extends $NotifierProvider<Scripts, List<Script>> {
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Script> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Script>>(value),
    );
  }
}

String _$scriptsHash() => r'22ddfa49b1ff3cbb71792b74e42faaed91bdd7bc';

abstract class _$Scripts extends $Notifier<List<Script>> {
  List<Script> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Script>, List<Script>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Script>, List<Script>>,
              List<Script>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(GlobalRules)
const globalRulesProvider = GlobalRulesProvider._();

final class GlobalRulesProvider
    extends $NotifierProvider<GlobalRules, List<Rule>> {
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Rule> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Rule>>(value),
    );
  }
}

String _$globalRulesHash() => r'36c277ca7cfceafd5e308b96d413d682a131c978';

abstract class _$GlobalRules extends $Notifier<List<Rule>> {
  List<Rule> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Rule>, List<Rule>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Rule>, List<Rule>>,
              List<Rule>,
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

String _$profileAddedRulesHash() => r'12b37659e19b0faa0f6800a1b35a731098fa53d0';

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
    r'3a11dc5f24884fb7cf96c234e1028d156b68100f';

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
