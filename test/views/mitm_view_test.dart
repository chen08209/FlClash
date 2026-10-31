import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/mitm_trust.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/list_item.dart';
import 'package:fl_clash/views/config/mitm.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prism_ui/prism_ui.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

class _FakeStore implements MitmTrustStore {
  _FakeStore(this.trust);

  MitmTrust trust;
  var checks = 0;
  final installed = <MitmCertificate>[];
  final removed = <MitmCertificate>[];

  @override
  Future<MitmTrustCheck> check(
    MitmCertificate ca,
    Future<String> Function() issueLeaf,
  ) async {
    checks++;
    return MitmTrustCheck(trust);
  }

  @override
  Future<MitmInstallOutcome> install(MitmCertificate ca) async {
    installed.add(ca);
    trust = MitmTrust.ready;
    return MitmInstallOutcome.installed;
  }

  @override
  Future<bool> remove(MitmCertificate ca) async {
    removed.add(ca);
    trust = MitmTrust.notInstalled;
    return true;
  }
}

final _certificate = MitmCertificate(
  pem: '-----BEGIN CERTIFICATE-----\n',
  fingerprint: 'AB:CD',
  subject: 'FlClash CA 0000ABCD',
  notBefore: DateTime.utc(2026, 10, 20, 12),
  notAfter: DateTime.utc(2036, 10, 22, 12),
);

final _renewed = _certificate.copyWith(
  fingerprint: 'EF:01',
  subject: 'FlClash CA 0000EF01',
);

void main() {
  late ProviderContainer container;
  late _MockCore core;

  setUpAll(() {
    registerFallbackValue(const MitmRules());
  });

  Mitm saved() => container.read(patchClashConfigProvider).mitm;

  Finder button(String label) => find.widgetWithText(TextButton, label);

  Future<void> pumpView(
    WidgetTester tester, {
    MitmCertificate? certificate,
    Mitm mitm = defaultMitm,
    MitmTrustStore? store,
    bool safeMode = false,
  }) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    core = _MockCore();
    when(() => core.getMitmCertificate()).thenAnswer((_) async => certificate);
    when(
      () => core.generateMitmCertificate(),
    ).thenAnswer((_) async => _certificate);
    when(() => core.validateMitm(any())).thenAnswer((invocation) async {
      final rules = invocation.positionalArguments.single as MitmRules;
      return {
        for (final list in MitmList.values)
          list: {
            for (final (index, line) in rules.linesOf(list).indexed)
              if (line.startsWith('bad')) index: 'unknown type',
          },
      };
    });
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        safeModeProvider.overrideWithValue(safeMode),
        mitmTrustStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.listen(patchClashConfigProvider, (_, _) {});
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1000, 2000));
    container.read(patchClashConfigProvider.notifier).value = PatchClashConfig(
      mitm: mitm,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: MitmView(isAndroid: false)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openCapture(WidgetTester tester) async {
    await tester.tap(find.text(currentAppLocalizations.httpCapture));
    await tester.pumpAndSettle();
  }

  Future<void> toggleEnable(WidgetTester tester) async {
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
  }

  testWidgets('capture says when no listed host leaves it nothing to record', (
    tester,
  ) async {
    await pumpView(
      tester,
      mitm: const Mitm(enable: true, capture: true, hostname: ['-a.example']),
    );
    await openCapture(tester);
    expect(
      find.text(currentAppLocalizations.httpCaptureNoHosts),
      findsOneWidget,
    );
  });

  testWidgets('capture keeps its description once a host is listed', (
    tester,
  ) async {
    await pumpView(
      tester,
      mitm: const Mitm(enable: true, capture: true, hostname: ['a.example']),
    );
    await openCapture(tester);
    expect(find.text(currentAppLocalizations.httpCaptureNoHosts), findsNothing);
    expect(find.text(currentAppLocalizations.httpCaptureDesc), findsOneWidget);
  });

  testWidgets('offers a certificate until one is generated', (tester) async {
    await pumpView(tester);

    expect(find.text(currentAppLocalizations.exportCertificate), findsNothing);
    await tester.tap(find.text(currentAppLocalizations.generateCertificate));
    await tester.pumpAndSettle();

    verify(() => core.generateMitmCertificate()).called(1);
    expect(find.text(_certificate.subject), findsOneWidget);
    expect(
      find.text(currentAppLocalizations.mitmTrustNotInstalled),
      findsOneWidget,
    );
    expect(
      find.text(currentAppLocalizations.exportCertificate),
      findsOneWidget,
    );

    await tester.tap(find.text(_certificate.subject));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(currentAppLocalizations.validUntil('2036-10-22')),
      findsOneWidget,
    );
  });

  testWidgets('turning on asks first and generates a missing certificate', (
    tester,
  ) async {
    await pumpView(tester);

    await toggleEnable(tester);
    expect(find.text(currentAppLocalizations.mitmEnableTip), findsOneWidget);
    await tester.tap(button(currentAppLocalizations.cancel));
    await tester.pumpAndSettle();
    expect(saved().enable, isFalse);
    verifyNever(() => core.generateMitmCertificate());

    await toggleEnable(tester);
    await tester.tap(button(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(saved().enable, isTrue);
    verify(() => core.generateMitmCertificate()).called(1);
  });

  testWidgets('turning on keeps the certificate there is', (tester) async {
    await pumpView(tester, certificate: _certificate);

    await toggleEnable(tester);
    await tester.tap(button(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(saved().enable, isTrue);
    verifyNever(() => core.generateMitmCertificate());
  });

  testWidgets('a certificate that fails to generate leaves it off', (
    tester,
  ) async {
    await pumpView(tester);
    when(() => core.generateMitmCertificate()).thenAnswer(
      (_) => Future.error(
        const CoreMethodException(code: 'core_error', message: 'disk full'),
      ),
    );

    await toggleEnable(tester);
    await tester.tap(button(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(saved().enable, isFalse);
    expect(find.textContaining('disk full'), findsOneWidget);
  });

  testWidgets('turning off asks nothing', (tester) async {
    await pumpView(
      tester,
      certificate: _certificate,
      mitm: const Mitm(enable: true),
    );

    await toggleEnable(tester);

    expect(saved().enable, isFalse);
    expect(find.text(currentAppLocalizations.mitmEnableTip), findsNothing);
  });

  Finder captureSwitch() => find.descendant(
    of: find.widgetWithText(ListItem, currentAppLocalizations.httpCapture),
    matching: find.byType(Switch),
  );

  testWidgets('capture waits for decryption to be on', (tester) async {
    await pumpView(tester, certificate: _certificate);

    expect(find.text(currentAppLocalizations.mitm), findsOneWidget);
    await openCapture(tester);
    expect(tester.widget<Switch>(captureSwitch()).onChanged, isNull);
  });

  testWidgets('capture is saved with the MITM settings', (tester) async {
    await pumpView(
      tester,
      certificate: _certificate,
      mitm: const Mitm(enable: true),
    );

    await openCapture(tester);
    await tester.tap(captureSwitch());
    await tester.pumpAndSettle();

    expect(saved().capture, isTrue);
  });

  testWidgets('capture limit shows the platform default until one is picked', (
    tester,
  ) async {
    await pumpView(
      tester,
      certificate: _certificate,
      mitm: const Mitm(enable: true),
    );

    await openCapture(tester);
    await tester.tap(find.text('2000'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5000'));
    await tester.pumpAndSettle();

    expect(saved().captureEntries, 5000);
    expect(find.text('5000'), findsOneWidget);
  });

  group('installing to the system', () {
    Finder install() => find.text(currentAppLocalizations.installCertificate);

    testWidgets('is offered where FlClash has a trust store', (tester) async {
      await pumpView(
        tester,
        certificate: _certificate,
        store: _FakeStore(MitmTrust.notInstalled),
      );

      expect(install(), findsOneWidget);
      expect(saved().trustedFingerprint, isNull);
    });

    testWidgets('is never offered in safe mode', (tester) async {
      await pumpView(
        tester,
        certificate: _certificate,
        store: _FakeStore(MitmTrust.notInstalled),
        safeMode: true,
      );

      expect(install(), findsNothing);
    });

    testWidgets('elsewhere leaves only the export', (tester) async {
      await pumpView(tester, certificate: _certificate);

      expect(install(), findsNothing);
      expect(
        find.text(currentAppLocalizations.exportCertificate),
        findsOneWidget,
      );
    });

    testWidgets('trusts a certificate the store holds untrusted', (
      tester,
    ) async {
      await pumpView(
        tester,
        certificate: _certificate,
        store: _FakeStore(MitmTrust.untrusted),
      );

      expect(install(), findsNothing);
      expect(
        find.text(currentAppLocalizations.trustCertificate),
        findsOneWidget,
      );
    });

    testWidgets('records the certificate once the store trusts it', (
      tester,
    ) async {
      final store = _FakeStore(MitmTrust.notInstalled);
      await pumpView(tester, certificate: _certificate, store: store);

      await tester.tap(install());
      await tester.pumpAndSettle();

      expect(store.installed, [_certificate]);
      expect(install(), findsNothing);
      expect(find.text(currentAppLocalizations.mitmTrustReady), findsOneWidget);
      expect(saved().trustedFingerprint, _certificate.fingerprint);
    });
  });

  testWidgets('a trusted certificate is decrypted with', (tester) async {
    await pumpView(
      tester,
      certificate: _certificate,
      store: _FakeStore(MitmTrust.ready),
    );

    expect(saved().trustedFingerprint, _certificate.fingerprint);
    final json = saved().coreJson(const MitmRules());
    expect(json['ca-fingerprint'], _certificate.fingerprint);
    expect(json['decrypt-tls'], isTrue);
  });

  testWidgets('regenerating swaps the trusted certificate', (tester) async {
    final store = _FakeStore(MitmTrust.ready);
    await pumpView(tester, certificate: _certificate, store: store);
    when(
      () => core.generateMitmCertificate(),
    ).thenAnswer((_) async => _renewed);

    await tester.tap(find.text(currentAppLocalizations.regenerateCertificate));
    await tester.pumpAndSettle();
    await tester.tap(button(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(store.removed, [_certificate]);
    expect(store.installed, [_renewed]);
    expect(find.text(_renewed.subject), findsOneWidget);
    expect(saved().trustedFingerprint, _renewed.fingerprint);
  });

  testWidgets('refreshes at once share one check', (tester) async {
    final store = _FakeStore(MitmTrust.ready);
    await pumpView(tester, certificate: _certificate, store: store);
    final before = store.checks;

    final trust = container.read(mitmTrustStateProvider.notifier);
    await Future.wait([trust.refresh(), trust.refresh()]);

    expect(store.checks, before + 1);
  });

  testWidgets('regenerating in safe mode leaves the trust store alone', (
    tester,
  ) async {
    final store = _FakeStore(MitmTrust.ready);
    await pumpView(
      tester,
      certificate: _certificate,
      store: store,
      safeMode: true,
    );
    when(
      () => core.generateMitmCertificate(),
    ).thenAnswer((_) async => _renewed);

    await tester.tap(find.text(currentAppLocalizations.regenerateCertificate));
    await tester.pumpAndSettle();
    await tester.tap(button(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(store.removed, isEmpty);
    expect(store.installed, isEmpty);
    expect(
      find.text(
        currentAppLocalizations.mitmOldCertificateLeftTip(_certificate.subject),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the hostname list counts and marks the lines the Core skips', (
    tester,
  ) async {
    await pumpView(tester, mitm: const Mitm(hostname: ['a.com', 'bad host']));

    expect(
      find.text(currentAppLocalizations.invalidOfCount(1, 2)),
      findsOneWidget,
    );
    expect(find.text(currentAppLocalizations.urlRewrite), findsNothing);
    await tester.tap(find.text(currentAppLocalizations.hostname));
    await tester.pumpAndSettle();

    expect(find.text('bad host'), findsOneWidget);
    expect(find.text('unknown type'), findsOneWidget);
  });

  testWidgets('a hostname entry takes one host', (tester) async {
    await pumpView(tester);

    await tester.tap(find.text(currentAppLocalizations.hostname));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(currentAppLocalizations.add));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(PopupMenu),
        matching: find.text(currentAppLocalizations.add),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'a.com, b.com');
    await tester.tap(button(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(
      find.text(
        currentAppLocalizations.singleValueTip(
          currentAppLocalizations.hostname,
        ),
      ),
      findsOneWidget,
    );
    expect(saved().hostname, isEmpty);
  });
}
