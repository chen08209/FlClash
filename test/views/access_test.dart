import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/access.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

Package _package(
  String name, {
  String? label,
  bool system = false,
  bool internet = true,
  int lastUpdateTime = 0,
}) {
  return Package(
    packageName: name,
    label: label ?? name.split('.').last,
    system: system,
    internet: internet,
    lastUpdateTime: lastUpdateTime,
  );
}

final _packages = [
  _package('com.example.browser', label: 'Browser'),
  _package('com.example.chat', label: 'Chat'),
  _package('com.android.settings', label: 'Settings', system: true),
  _package('com.example.offline', label: 'Offline', internet: false),
];

class _TestSystemAction extends SystemAction {
  bool installedAppsPermissionGranted = true;
  bool grantOnRequest = true;
  int requestCount = 0;
  List<Package> grantedPackages = const [];

  @override
  Future<List<Package>> getPackages() async => ref.read(packagesProvider);

  @override
  Future<List<Package>> refreshPackages() async {
    ref.read(packagesProvider.notifier).value = grantedPackages;
    return ref.read(packagesProvider);
  }

  @override
  Future<bool> isInstalledAppsPermissionGranted() async =>
      installedAppsPermissionGranted;

  @override
  Future<bool> requestInstalledAppsPermission() async {
    requestCount++;
    installedAppsPermissionGranted = grantOnRequest;
    return grantOnRequest;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late _TestSystemAction systemAction;

  setUp(() {
    systemAction = _TestSystemAction();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        systemActionProvider.overrideWith(() => systemAction),
      ],
    );
    globalState.container = container;
    container.read(packagesProvider.notifier).value = _packages;
  });

  tearDown(() => container.dispose());

  void seedAccessControl(AccessControlProps props) {
    container.read(vpnSettingProvider.notifier).value = const VpnProps()
        .copyWith(accessControlProps: props);
  }

  Future<void> pumpAccessView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1400, 1400));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: AccessView()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 301));
  }

  Future<void> teardownView(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
  }

  group('visible package list', () {
    testWidgets('hides system and offline apps by default', (tester) async {
      seedAccessControl(const AccessControlProps(enable: true));

      await pumpAccessView(tester);

      expect(find.text('Browser'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Settings'), findsNothing);
      expect(find.text('Offline'), findsNothing);

      await teardownView(tester);
    });

    testWidgets('shows system apps once the filter is disabled', (
      tester,
    ) async {
      seedAccessControl(
        const AccessControlProps(enable: true, isFilterSystemApp: false),
      );

      await pumpAccessView(tester);

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Offline'), findsNothing);

      await teardownView(tester);
    });

    testWidgets('shows offline apps once the internet filter is disabled', (
      tester,
    ) async {
      seedAccessControl(
        const AccessControlProps(enable: true, isFilterNonInternetApp: false),
      );

      await pumpAccessView(tester);

      expect(find.text('Offline'), findsOneWidget);
      expect(find.text('Settings'), findsNothing);

      await teardownView(tester);
    });

    testWidgets('sorts by name when the name sort is selected', (tester) async {
      seedAccessControl(
        const AccessControlProps(enable: true, sort: AccessSortType.name),
      );

      await pumpAccessView(tester);

      final labels = tester
          .widgetList<PackageListItem>(find.byType(PackageListItem))
          .map((item) => item.package.label)
          .toList();
      expect(labels, ['Browser', 'Chat']);

      await teardownView(tester);
    });
  });

  group('search', () {
    testWidgets('filters by label and by package name', (tester) async {
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      container.read(queryProvider(QueryTag.access).notifier).value = 'chat';
      await tester.pump();
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Browser'), findsNothing);

      container.read(queryProvider(QueryTag.access).notifier).value =
          'com.example.browser';
      await tester.pump();
      expect(find.text('Browser'), findsOneWidget);
      expect(find.text('Chat'), findsNothing);

      await teardownView(tester);
    });
  });

  group('selection', () {
    testWidgets('tapping a package adds and removes it from the list', (
      tester,
    ) async {
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      await tester.tap(find.text('Browser'));
      await tester.pump();
      expect(container.read(accessControlStateProvider).currentList, [
        'com.example.browser',
      ]);

      await tester.tap(find.text('Browser'));
      await tester.pump();
      expect(container.read(accessControlStateProvider).currentList, isEmpty);

      await teardownView(tester);
    });

    testWidgets('the action button selects then clears every visible app', (
      tester,
    ) async {
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      await tester.tap(find.byType(FloatingActionButton).first);
      await tester.pump();
      expect(
        [...container.read(accessControlStateProvider).currentList]..sort(),
        ['com.example.browser', 'com.example.chat'],
      );

      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byType(FloatingActionButton).first);
      await tester.pump();
      expect(container.read(accessControlStateProvider).currentList, isEmpty);

      await teardownView(tester);
    });

    testWidgets('selection targets the accept list in accept mode', (
      tester,
    ) async {
      seedAccessControl(
        const AccessControlProps(
          enable: true,
          mode: AccessControlMode.acceptSelected,
        ),
      );
      await pumpAccessView(tester);

      await tester.tap(find.text('Chat'));
      await tester.pump();

      final state = container.read(accessControlStateProvider);
      expect(state.acceptList, ['com.example.chat']);
      expect(state.rejectList, isEmpty);

      await teardownView(tester);
    });
  });

  group('installed apps permission', () {
    testWidgets('prompts for the permission when the app list is empty', (
      tester,
    ) async {
      container.read(packagesProvider.notifier).value = [];
      systemAction.installedAppsPermissionGranted = false;
      seedAccessControl(const AccessControlProps(enable: true));

      await pumpAccessView(tester);

      expect(find.text('App list permission required'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Authorize'), findsOneWidget);
      expect(find.text('No data'), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);

      await teardownView(tester);
    });

    testWidgets('keeps the plain empty status once the permission is held', (
      tester,
    ) async {
      container.read(packagesProvider.notifier).value = [];
      seedAccessControl(const AccessControlProps(enable: true));

      await pumpAccessView(tester);

      expect(find.text('No data'), findsOneWidget);
      expect(find.text('App list permission required'), findsNothing);

      await teardownView(tester);
    });

    testWidgets('reloads the app list once the permission is granted', (
      tester,
    ) async {
      container.read(packagesProvider.notifier).value = [];
      systemAction.installedAppsPermissionGranted = false;
      systemAction.grantedPackages = _packages;
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Authorize'));
      await tester.pumpAndSettle();

      expect(systemAction.requestCount, 1);
      expect(find.text('App list permission required'), findsNothing);
      expect(find.text('Browser'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);

      await teardownView(tester);
    });

    testWidgets('offers system settings when the permission stays denied', (
      tester,
    ) async {
      container.read(packagesProvider.notifier).value = [];
      systemAction.installedAppsPermissionGranted = false;
      systemAction.grantOnRequest = false;
      seedAccessControl(const AccessControlProps(enable: true));
      await pumpAccessView(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Authorize'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextButton, 'Settings'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      await teardownView(tester);
    });
  });

  group('save', () {
    testWidgets('offers no save action while nothing has changed', (
      tester,
    ) async {
      seedAccessControl(const AccessControlProps(enable: true));

      await pumpAccessView(tester);

      expect(find.widgetWithText(FilledButton, 'Save'), findsNothing);

      await teardownView(tester);
    });

    testWidgets('drops hidden packages and sorts what it persists', (
      tester,
    ) async {
      seedAccessControl(
        const AccessControlProps(
          enable: true,
          rejectList: ['com.android.settings'],
        ),
      );
      await pumpAccessView(tester);

      await tester.tap(find.text('Chat'));
      await tester.pump();
      await tester.tap(find.text('Browser'));
      await tester.pump();

      final saveButton = find.widgetWithText(FilledButton, 'Save');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pump();

      final saved = container
          .read(vpnSettingProvider)
          .accessControlProps
          .rejectList;
      expect(saved, ['com.example.browser', 'com.example.chat']);

      await teardownView(tester);
    });
  });
}
