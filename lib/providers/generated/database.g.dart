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

@ProviderFor(profileDisabledRuleIdsStream)
const profileDisabledRuleIdsStreamProvider =
    ProfileDisabledRuleIdsStreamFamily._();

final class ProfileDisabledRuleIdsStreamProvider
    extends
        $FunctionalProvider<AsyncValue<List<int>>, List<int>, Stream<List<int>>>
    with $FutureModifier<List<int>>, $StreamProvider<List<int>> {
  const ProfileDisabledRuleIdsStreamProvider._({
    required ProfileDisabledRuleIdsStreamFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'profileDisabledRuleIdsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileDisabledRuleIdsStreamHash();

  @override
  String toString() {
    return r'profileDisabledRuleIdsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<int>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<int>> create(Ref ref) {
    final argument = this.argument as int;
    return profileDisabledRuleIdsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileDisabledRuleIdsStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileDisabledRuleIdsStreamHash() =>
    r'6369c5b911976f13e41ef5e4990aeb18e30a0109';

final class ProfileDisabledRuleIdsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<int>>, int> {
  const ProfileDisabledRuleIdsStreamFamily._()
    : super(
        retry: null,
        name: r'profileDisabledRuleIdsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileDisabledRuleIdsStreamProvider call(int profileId) =>
      ProfileDisabledRuleIdsStreamProvider._(argument: profileId, from: this);

  @override
  String toString() => r'profileDisabledRuleIdsStreamProvider';
}

@ProviderFor(profileAddedRulesStream)
const profileAddedRulesStreamProvider = ProfileAddedRulesStreamFamily._();

final class ProfileAddedRulesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Rule>>,
          List<Rule>,
          Stream<List<Rule>>
        >
    with $FutureModifier<List<Rule>>, $StreamProvider<List<Rule>> {
  const ProfileAddedRulesStreamProvider._({
    required ProfileAddedRulesStreamFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'profileAddedRulesStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileAddedRulesStreamHash();

  @override
  String toString() {
    return r'profileAddedRulesStreamProvider'
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
    return profileAddedRulesStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileAddedRulesStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileAddedRulesStreamHash() =>
    r'ca86a4761c0927d288f78da68c2e3d969b70e36d';

final class ProfileAddedRulesStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Rule>>, int> {
  const ProfileAddedRulesStreamFamily._()
    : super(
        retry: null,
        name: r'profileAddedRulesStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileAddedRulesStreamProvider call(int profileId) =>
      ProfileAddedRulesStreamProvider._(argument: profileId, from: this);

  @override
  String toString() => r'profileAddedRulesStreamProvider';
}

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

String _$profilesHash() => r'30d4d86bc2cdee4d9235e0b501179646a230bc3f';

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

String _$scriptsHash() => r'9b930cb778f2752f02a7e10b1b2ed724e6ab12d1';

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

String _$globalRulesHash() => r'dea3bc322b76519eeda5dd6a9da955b6de5315b6';

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
