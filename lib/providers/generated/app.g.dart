// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../app.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RealTunEnable)
final realTunEnableProvider = RealTunEnableProvider._();

final class RealTunEnableProvider
    extends $NotifierProvider<RealTunEnable, bool> {
  RealTunEnableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'realTunEnableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$realTunEnableHash();

  @$internal
  @override
  RealTunEnable create() => RealTunEnable();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$realTunEnableHash() => r'f2c88f5031d1f97665c10f70121082c4f6d6c99d';

abstract class _$RealTunEnable extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Logs)
final logsProvider = LogsProvider._();

final class LogsProvider extends $NotifierProvider<Logs, FixedList<Log>> {
  LogsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logsHash();

  @$internal
  @override
  Logs create() => Logs();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FixedList<Log> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FixedList<Log>>(value),
    );
  }
}

String _$logsHash() => r'2f10830d8a103688a59afce45ab6c52a82f38ca2';

abstract class _$Logs extends $Notifier<FixedList<Log>> {
  FixedList<Log> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FixedList<Log>, FixedList<Log>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FixedList<Log>, FixedList<Log>>,
              FixedList<Log>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Requests)
final requestsProvider = RequestsProvider._();

final class RequestsProvider
    extends $NotifierProvider<Requests, FixedList<TrackerInfo>> {
  RequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'requestsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$requestsHash();

  @$internal
  @override
  Requests create() => Requests();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FixedList<TrackerInfo> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FixedList<TrackerInfo>>(value),
    );
  }
}

String _$requestsHash() => r'32e4f0141a66b27732f8156a55a6fb23d74cfc07';

abstract class _$Requests extends $Notifier<FixedList<TrackerInfo>> {
  FixedList<TrackerInfo> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<FixedList<TrackerInfo>, FixedList<TrackerInfo>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FixedList<TrackerInfo>, FixedList<TrackerInfo>>,
              FixedList<TrackerInfo>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Providers)
final providersProvider = ProvidersProvider._();

final class ProvidersProvider
    extends $NotifierProvider<Providers, List<ExternalProvider>> {
  ProvidersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providersHash();

  @$internal
  @override
  Providers create() => Providers();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ExternalProvider> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ExternalProvider>>(value),
    );
  }
}

String _$providersHash() => r'21b9ada05ede3e9097621e2e5b10800e40ba7098';

abstract class _$Providers extends $Notifier<List<ExternalProvider>> {
  List<ExternalProvider> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<List<ExternalProvider>, List<ExternalProvider>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ExternalProvider>, List<ExternalProvider>>,
              List<ExternalProvider>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Packages)
final packagesProvider = PackagesProvider._();

final class PackagesProvider
    extends $NotifierProvider<Packages, List<Package>> {
  PackagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packagesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packagesHash();

  @$internal
  @override
  Packages create() => Packages();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Package> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Package>>(value),
    );
  }
}

String _$packagesHash() => r'93c92438ed777ec4c3017b90c22f4ddd1c02e931';

abstract class _$Packages extends $Notifier<List<Package>> {
  List<Package> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Package>, List<Package>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Package>, List<Package>>,
              List<Package>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SystemBrightness)
final systemBrightnessProvider = SystemBrightnessProvider._();

final class SystemBrightnessProvider
    extends $NotifierProvider<SystemBrightness, Brightness> {
  SystemBrightnessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'systemBrightnessProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$systemBrightnessHash();

  @$internal
  @override
  SystemBrightness create() => SystemBrightness();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Brightness value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Brightness>(value),
    );
  }
}

String _$systemBrightnessHash() => r'5b8c93dc20f048b12cdad42b301afe8b9aa864cf';

abstract class _$SystemBrightness extends $Notifier<Brightness> {
  Brightness build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Brightness, Brightness>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Brightness, Brightness>,
              Brightness,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Traffics)
final trafficsProvider = TrafficsProvider._();

final class TrafficsProvider
    extends $NotifierProvider<Traffics, FixedList<Traffic>> {
  TrafficsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trafficsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trafficsHash();

  @$internal
  @override
  Traffics create() => Traffics();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FixedList<Traffic> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FixedList<Traffic>>(value),
    );
  }
}

String _$trafficsHash() => r'00b83d393175b51abcef277417fb3d9b70cc247f';

abstract class _$Traffics extends $Notifier<FixedList<Traffic>> {
  FixedList<Traffic> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FixedList<Traffic>, FixedList<Traffic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FixedList<Traffic>, FixedList<Traffic>>,
              FixedList<Traffic>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TotalTraffic)
final totalTrafficProvider = TotalTrafficProvider._();

final class TotalTrafficProvider
    extends $NotifierProvider<TotalTraffic, Traffic> {
  TotalTrafficProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalTrafficProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalTrafficHash();

  @$internal
  @override
  TotalTraffic create() => TotalTraffic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Traffic value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Traffic>(value),
    );
  }
}

String _$totalTrafficHash() => r'fc933692cd103acc8bcf02054a399659c08d9054';

abstract class _$TotalTraffic extends $Notifier<Traffic> {
  Traffic build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Traffic, Traffic>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Traffic, Traffic>,
              Traffic,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(LocalIp)
final localIpProvider = LocalIpProvider._();

final class LocalIpProvider extends $NotifierProvider<LocalIp, String?> {
  LocalIpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localIpProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localIpHash();

  @$internal
  @override
  LocalIp create() => LocalIp();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$localIpHash() => r'7daf4c498425db64db4e33b10c870d8fa10695d8';

abstract class _$LocalIp extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(RunTime)
final runTimeProvider = RunTimeProvider._();

final class RunTimeProvider extends $NotifierProvider<RunTime, int?> {
  RunTimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runTimeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runTimeHash();

  @$internal
  @override
  RunTime create() => RunTime();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$runTimeHash() => r'665a3a58487bb59aa54c3f797db0627986aa878f';

abstract class _$RunTime extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ViewSize)
final viewSizeProvider = ViewSizeProvider._();

final class ViewSizeProvider extends $NotifierProvider<ViewSize, Size> {
  ViewSizeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'viewSizeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$viewSizeHash();

  @$internal
  @override
  ViewSize create() => ViewSize();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Size value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Size>(value),
    );
  }
}

String _$viewSizeHash() => r'3f355412237dc1234cca0d97972ac2eef1eb4792';

abstract class _$ViewSize extends $Notifier<Size> {
  Size build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Size, Size>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Size, Size>,
              Size,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SideWidth)
final sideWidthProvider = SideWidthProvider._();

final class SideWidthProvider extends $NotifierProvider<SideWidth, double> {
  SideWidthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sideWidthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sideWidthHash();

  @$internal
  @override
  SideWidth create() => SideWidth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$sideWidthHash() => r'2f849d52dab271831bad68b07c1f90b5c18c0cc4';

abstract class _$SideWidth extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(viewWidth)
final viewWidthProvider = ViewWidthProvider._();

final class ViewWidthProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  ViewWidthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'viewWidthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$viewWidthHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return viewWidth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$viewWidthHash() => r'5ee8f1bdebe44760f7333f88127108f5ffd70214';

@ProviderFor(viewMode)
final viewModeProvider = ViewModeProvider._();

final class ViewModeProvider
    extends $FunctionalProvider<ViewMode, ViewMode, ViewMode>
    with $Provider<ViewMode> {
  ViewModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'viewModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$viewModeHash();

  @$internal
  @override
  $ProviderElement<ViewMode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ViewMode create(Ref ref) {
    return viewMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ViewMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ViewMode>(value),
    );
  }
}

String _$viewModeHash() => r'6822e9dc28c813afe1ed743feea464f0d33c805c';

@ProviderFor(isMobileView)
final isMobileViewProvider = IsMobileViewProvider._();

final class IsMobileViewProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsMobileViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isMobileViewProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isMobileViewHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isMobileView(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isMobileViewHash() => r'1d75bccb4f50ae206bf43b68df869a5d95e5ea5f';

@ProviderFor(viewHeight)
final viewHeightProvider = ViewHeightProvider._();

final class ViewHeightProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  ViewHeightProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'viewHeightProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$viewHeightHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return viewHeight(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$viewHeightHash() => r'dc3fc18337b5ce9fc953d994c380e8f1fa49f352';

@ProviderFor(Init)
final initProvider = InitProvider._();

final class InitProvider extends $NotifierProvider<Init, bool> {
  InitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initHash();

  @$internal
  @override
  Init create() => Init();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$initHash() => r'0fcded1ed3c62f2658898dee845455e412b171b1';

abstract class _$Init extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CurrentPageLabel)
final currentPageLabelProvider = CurrentPageLabelProvider._();

final class CurrentPageLabelProvider
    extends $NotifierProvider<CurrentPageLabel, PageLabel> {
  CurrentPageLabelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentPageLabelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentPageLabelHash();

  @$internal
  @override
  CurrentPageLabel create() => CurrentPageLabel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PageLabel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PageLabel>(value),
    );
  }
}

String _$currentPageLabelHash() => r'ccdbe5d0e0d2c324f74b3e2086d3e581740dd9bf';

abstract class _$CurrentPageLabel extends $Notifier<PageLabel> {
  PageLabel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PageLabel, PageLabel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PageLabel, PageLabel>,
              PageLabel,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SortNum)
final sortNumProvider = SortNumProvider._();

final class SortNumProvider extends $NotifierProvider<SortNum, int> {
  SortNumProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sortNumProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sortNumHash();

  @$internal
  @override
  SortNum create() => SortNum();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$sortNumHash() => r'6682f00d1f87cb17f294ad181ac96bf4dc6edb52';

abstract class _$SortNum extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CheckIpNum)
final checkIpNumProvider = CheckIpNumProvider._();

final class CheckIpNumProvider extends $NotifierProvider<CheckIpNum, int> {
  CheckIpNumProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkIpNumProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkIpNumHash();

  @$internal
  @override
  CheckIpNum create() => CheckIpNum();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$checkIpNumHash() => r'e66b46fae31f3683698dc55533fbdd240aff44fe';

abstract class _$CheckIpNum extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(BackBlock)
final backBlockProvider = BackBlockProvider._();

final class BackBlockProvider extends $NotifierProvider<BackBlock, bool> {
  BackBlockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backBlockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backBlockHash();

  @$internal
  @override
  BackBlock create() => BackBlock();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$backBlockHash() => r'c867df920425f9b063807ca758dff8d849ca069e';

abstract class _$BackBlock extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Version)
final versionProvider = VersionProvider._();

final class VersionProvider extends $NotifierProvider<Version, int> {
  VersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'versionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$versionHash();

  @$internal
  @override
  Version create() => Version();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$versionHash() => r'00b43faa4061121d30a0612ed275644a402ce3fa';

abstract class _$Version extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Groups)
final groupsProvider = GroupsProvider._();

final class GroupsProvider extends $NotifierProvider<Groups, List<Group>> {
  GroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupsHash();

  @$internal
  @override
  Groups create() => Groups();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Group> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Group>>(value),
    );
  }
}

String _$groupsHash() => r'180ede48880a239add201c111ae45b2a6d98f3a5';

abstract class _$Groups extends $Notifier<List<Group>> {
  List<Group> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Group>, List<Group>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Group>, List<Group>>,
              List<Group>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(DelayDataSource)
final delayDataSourceProvider = DelayDataSourceProvider._();

final class DelayDataSourceProvider
    extends $NotifierProvider<DelayDataSource, DelayMap> {
  DelayDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'delayDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$delayDataSourceHash();

  @$internal
  @override
  DelayDataSource create() => DelayDataSource();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DelayMap value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DelayMap>(value),
    );
  }
}

String _$delayDataSourceHash() => r'9737cf2d943cb9b5504a5ec8ace20b0a9380b197';

abstract class _$DelayDataSource extends $Notifier<DelayMap> {
  DelayMap build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DelayMap, DelayMap>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DelayMap, DelayMap>,
              DelayMap,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SystemUiOverlayStyleState)
final systemUiOverlayStyleStateProvider = SystemUiOverlayStyleStateProvider._();

final class SystemUiOverlayStyleStateProvider
    extends $NotifierProvider<SystemUiOverlayStyleState, SystemUiOverlayStyle> {
  SystemUiOverlayStyleStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'systemUiOverlayStyleStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$systemUiOverlayStyleStateHash();

  @$internal
  @override
  SystemUiOverlayStyleState create() => SystemUiOverlayStyleState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SystemUiOverlayStyle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SystemUiOverlayStyle>(value),
    );
  }
}

String _$systemUiOverlayStyleStateHash() =>
    r'e933e3b01fca397e084f75fab5f0be22f0a08257';

abstract class _$SystemUiOverlayStyleState
    extends $Notifier<SystemUiOverlayStyle> {
  SystemUiOverlayStyle build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SystemUiOverlayStyle, SystemUiOverlayStyle>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SystemUiOverlayStyle, SystemUiOverlayStyle>,
              SystemUiOverlayStyle,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(_CoreStatus)
final coreStatusProvider = _CoreStatusProvider._();

final class _CoreStatusProvider
    extends $NotifierProvider<_CoreStatus, CoreStatus> {
  _CoreStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coreStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_coreStatusHash();

  @$internal
  @override
  _CoreStatus create() => _CoreStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CoreStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoreStatus>(value),
    );
  }
}

String _$_coreStatusHash() => r'e2e7fe37f66b906877e678149d09c656993e1405';

abstract class _$CoreStatus extends $Notifier<CoreStatus> {
  CoreStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CoreStatus, CoreStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CoreStatus, CoreStatus>,
              CoreStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Query)
final queryProvider = QueryFamily._();

final class QueryProvider extends $NotifierProvider<Query, String> {
  QueryProvider._({
    required QueryFamily super.from,
    required QueryTag super.argument,
  }) : super(
         retry: null,
         name: r'queryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$queryHash();

  @override
  String toString() {
    return r'queryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Query create() => Query();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is QueryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$queryHash() => r'b6be53823f3351ee2bf1c0d147c0ccf5f31bb8b5';

final class QueryFamily extends $Family
    with $ClassFamilyOverride<Query, String, String, String, QueryTag> {
  QueryFamily._()
    : super(
        retry: null,
        name: r'queryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  QueryProvider call(QueryTag tag) =>
      QueryProvider._(argument: tag, from: this);

  @override
  String toString() => r'queryProvider';
}

abstract class _$Query extends $Notifier<String> {
  late final _$args = ref.$arg as QueryTag;
  QueryTag get tag => _$args;

  String build(QueryTag tag);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(Loading)
final loadingProvider = LoadingFamily._();

final class LoadingProvider extends $NotifierProvider<Loading, bool> {
  LoadingProvider._({
    required LoadingFamily super.from,
    required LoadingTag super.argument,
  }) : super(
         retry: null,
         name: r'loadingProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$loadingHash();

  @override
  String toString() {
    return r'loadingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Loading create() => Loading();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LoadingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$loadingHash() => r'f4c58da7e5869c3e114b76439f3169b31d2e5b71';

final class LoadingFamily extends $Family
    with $ClassFamilyOverride<Loading, bool, bool, bool, LoadingTag> {
  LoadingFamily._()
    : super(
        retry: null,
        name: r'loadingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  LoadingProvider call(LoadingTag tag) =>
      LoadingProvider._(argument: tag, from: this);

  @override
  String toString() => r'loadingProvider';
}

abstract class _$Loading extends $Notifier<bool> {
  late final _$args = ref.$arg as LoadingTag;
  LoadingTag get tag => _$args;

  bool build(LoadingTag tag);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(Items)
final itemsProvider = ItemsFamily._();

final class ItemsProvider extends $NotifierProvider<Items, Set<dynamic>> {
  ItemsProvider._({
    required ItemsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'itemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemsHash();

  @override
  String toString() {
    return r'itemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Items create() => Items();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<dynamic> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<dynamic>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemsHash() => r'e4d68c86d62dfa3ba7153954208891e4df4c4355';

final class ItemsFamily extends $Family
    with
        $ClassFamilyOverride<
          Items,
          Set<dynamic>,
          Set<dynamic>,
          Set<dynamic>,
          String
        > {
  ItemsFamily._()
    : super(
        retry: null,
        name: r'itemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ItemsProvider call(String key) => ItemsProvider._(argument: key, from: this);

  @override
  String toString() => r'itemsProvider';
}

abstract class _$Items extends $Notifier<Set<dynamic>> {
  late final _$args = ref.$arg as String;
  String get key => _$args;

  Set<dynamic> build(String key);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<dynamic>, Set<dynamic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<dynamic>, Set<dynamic>>,
              Set<dynamic>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(Item)
final itemProvider = ItemFamily._();

final class ItemProvider extends $NotifierProvider<Item, dynamic> {
  ItemProvider._({
    required ItemFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'itemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemHash();

  @override
  String toString() {
    return r'itemProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Item create() => Item();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(dynamic value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<dynamic>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ItemProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemHash() => r'bd46bf2e285d7171173ed7c46455ff4c39e80a46';

final class ItemFamily extends $Family
    with $ClassFamilyOverride<Item, dynamic, dynamic, dynamic, String> {
  ItemFamily._()
    : super(
        retry: null,
        name: r'itemProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ItemProvider call(String key) => ItemProvider._(argument: key, from: this);

  @override
  String toString() => r'itemProvider';
}

abstract class _$Item extends $Notifier<dynamic> {
  late final _$args = ref.$arg as String;
  String get key => _$args;

  dynamic build(String key);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<dynamic, dynamic>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<dynamic, dynamic>,
              dynamic,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(IsUpdating)
final isUpdatingProvider = IsUpdatingFamily._();

final class IsUpdatingProvider extends $NotifierProvider<IsUpdating, bool> {
  IsUpdatingProvider._({
    required IsUpdatingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isUpdatingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isUpdatingHash();

  @override
  String toString() {
    return r'isUpdatingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  IsUpdating create() => IsUpdating();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsUpdatingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isUpdatingHash() => r'934cc96cbf8cf6909d27867455a31bf3008470e6';

final class IsUpdatingFamily extends $Family
    with $ClassFamilyOverride<IsUpdating, bool, bool, bool, String> {
  IsUpdatingFamily._()
    : super(
        retry: null,
        name: r'isUpdatingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsUpdatingProvider call(String name) =>
      IsUpdatingProvider._(argument: name, from: this);

  @override
  String toString() => r'isUpdatingProvider';
}

abstract class _$IsUpdating extends $Notifier<bool> {
  late final _$args = ref.$arg as String;
  String get name => _$args;

  bool build(String name);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(NetworkDetection)
final networkDetectionProvider = NetworkDetectionProvider._();

final class NetworkDetectionProvider
    extends $NotifierProvider<NetworkDetection, NetworkDetectionState> {
  NetworkDetectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkDetectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkDetectionHash();

  @$internal
  @override
  NetworkDetection create() => NetworkDetection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkDetectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkDetectionState>(value),
    );
  }
}

String _$networkDetectionHash() => r'1cab20d67ec54321b4dbba9d971cd80e98542e23';

abstract class _$NetworkDetection extends $Notifier<NetworkDetectionState> {
  NetworkDetectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NetworkDetectionState, NetworkDetectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NetworkDetectionState, NetworkDetectionState>,
              NetworkDetectionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CurrentSSID)
final currentSSIDProvider = CurrentSSIDProvider._();

final class CurrentSSIDProvider
    extends $NotifierProvider<CurrentSSID, String?> {
  CurrentSSIDProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSSIDProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSSIDHash();

  @$internal
  @override
  CurrentSSID create() => CurrentSSID();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentSSIDHash() => r'287929b3e4d6658775012eb47f0d4f956ae31d0d';

abstract class _$CurrentSSID extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(BatteryOptimizationDisable)
final batteryOptimizationDisableProvider =
    BatteryOptimizationDisableProvider._();

final class BatteryOptimizationDisableProvider
    extends $NotifierProvider<BatteryOptimizationDisable, bool> {
  BatteryOptimizationDisableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'batteryOptimizationDisableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$batteryOptimizationDisableHash();

  @$internal
  @override
  BatteryOptimizationDisable create() => BatteryOptimizationDisable();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$batteryOptimizationDisableHash() =>
    r'a95e3e5500f685d44f61804ea280a6a73d639ac1';

abstract class _$BatteryOptimizationDisable extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(LocationPermissions)
final locationPermissionsProvider = LocationPermissionsProvider._();

final class LocationPermissionsProvider
    extends $NotifierProvider<LocationPermissions, WifiSsidPermission> {
  LocationPermissionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationPermissionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationPermissionsHash();

  @$internal
  @override
  LocationPermissions create() => LocationPermissions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WifiSsidPermission value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WifiSsidPermission>(value),
    );
  }
}

String _$locationPermissionsHash() =>
    r'0097088be7aab27f635eff31a7f88bc1067dfe34';

abstract class _$LocationPermissions extends $Notifier<WifiSsidPermission> {
  WifiSsidPermission build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WifiSsidPermission, WifiSsidPermission>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WifiSsidPermission, WifiSsidPermission>,
              WifiSsidPermission,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
