import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/mitm_trust.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/list_item.dart';
import 'package:fl_clash/views/config/advanced.dart';
import 'package:fl_clash/views/config/mitm.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prism_ui/prism_ui.dart';

import '../helpers/core_mocks.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _FakeStore implements MitmTrustStore {
  _FakeStore(
    this.trust, {
    this.installTrust = MitmTrust.ready,
    this.installError,
    this.removeOutcome = MitmRemoveOutcome.removed,
    this.removeError,
  });

  MitmTrust trust;
  final MitmTrust installTrust;
  final Exception? installError;
  final MitmRemoveOutcome removeOutcome;
  final Exception? removeError;
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
    trust = installTrust;
    if (installError case final error?) {
      throw error;
    }
    return MitmInstallOutcome.installed;
  }

  @override
  Future<MitmRemoveOutcome> remove(MitmCertificate ca) async {
    removed.add(ca);
    if (removeError case final error?) {
      throw error;
    }
    if (removeOutcome == MitmRemoveOutcome.removed) {
      trust = MitmTrust.notInstalled;
    }
    return removeOutcome;
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
  late CoreMocks mocks;

  setUpAll(() {
    registerFallbackValue(<String, Object?>{});
  });

  Mitm saved() => container.read(patchClashConfigProvider).mitm;

  Finder button(String label) => find.widgetWithText(TextButton, label);

  Future<void> pumpView(
    WidgetTester tester, {
    MitmCertificate? certificate,
    Mitm mitm = defaultMitm,
    MitmTrustStore? store,
    bool safeMode = false,
    Widget view = const MitmOptionsView(isAndroid: false),
  }) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    mocks = coreMocks();
    when(
      () => mocks.api.mitmCertificate(),
    ).thenAnswer((_) async => certificate?.toJson());
    when(
      () => mocks.api.generateMitmCertificate(),
    ).thenAnswer((_) async => _certificate.toJson());
    when(() => mocks.api.validateMitm(any())).thenAnswer((invocation) async {
      final config = invocation.positionalArguments.single as Map;
      return {
        'issues': {
          for (final list in MitmList.values)
            list.key: [
              for (final (index, line)
                  in (config[list.key] as List).cast<String>().indexed)
                if (line.startsWith('bad'))
                  {'index': index, 'message': 'unknown type'},
            ],
        },
      };
    });
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        coreHandlerProvider.overrideWithValue(mocks.controller),
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
        child: TestApp(child: view),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> toggleEnable(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(
          ListItem,
          currentAppLocalizations.httpsDecryption,
        ),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('offers a certificate until one is generated', (tester) async {
    await pumpView(tester);

    expect(
      find.text(currentAppLocalizations.regenerateCertificate),
      findsNothing,
    );
    await tester.tap(find.text(currentAppLocalizations.generateCertificate));
    await tester.pumpAndSettle();

    verify(() => mocks.api.generateMitmCertificate()).called(1);
    expect(find.text(_certificate.subject), findsOneWidget);
    expect(
      find.text(currentAppLocalizations.mitmTrustNotInstalled),
      findsOneWidget,
    );
    expect(
      find.text(currentAppLocalizations.regenerateCertificate),
      findsOneWidget,
    );
  });

  for (final isAndroid in [true, false]) {
    testWidgets(
      'the MITM group ${isAndroid ? 'says' : 'does not say'} what root adds '
      '${isAndroid ? 'on' : 'off'} Android',
      (tester) async {
        await pumpView(tester, view: AdvancedConfigView(isAndroid: isAndroid));

        expect(
          find.text(currentAppLocalizations.mitmAndroidRootDesc),
          isAndroid ? findsOneWidget : findsNothing,
        );
      },
    );
  }

  testWidgets('turning on asks first and generates a missing certificate', (
    tester,
  ) async {
    await pumpView(tester, view: const AdvancedConfigView());

    await toggleEnable(tester);
    expect(find.text(currentAppLocalizations.mitmEnableTip), findsOneWidget);
    await tester.tap(button(currentAppLocalizations.cancel));
    await tester.pumpAndSettle();
    expect(saved().enable, isFalse);
    verifyNever(() => mocks.api.generateMitmCertificate());

    await toggleEnable(tester);
    await tester.tap(button(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(saved().enable, isTrue);
    verify(() => mocks.api.generateMitmCertificate()).called(1);
  });

  testWidgets('turning on keeps the certificate there is', (tester) async {
    await pumpView(
      tester,
      certificate: _certificate,
      view: const AdvancedConfigView(),
    );

    await toggleEnable(tester);
    await tester.tap(button(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    expect(saved().enable, isTrue);
    verifyNever(() => mocks.api.generateMitmCertificate());
  });

  testWidgets('a certificate that fails to generate leaves it off', (
    tester,
  ) async {
    await pumpView(tester, view: const AdvancedConfigView());
    when(() => mocks.api.generateMitmCertificate()).thenAnswer(
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
      view: const AdvancedConfigView(),
    );

    await toggleEnable(tester);

    expect(saved().enable, isFalse);
    expect(find.text(currentAppLocalizations.mitmEnableTip), findsNothing);
  });

  testWidgets('the advanced page lists MITM and opens the rest from options', (
    tester,
  ) async {
    await pumpView(
      tester,
      certificate: _certificate,
      view: const AdvancedConfigView(),
    );

    for (final label in [
      currentAppLocalizations.httpsDecryption,
      currentAppLocalizations.mitmModules,
      currentAppLocalizations.hostname,
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text(currentAppLocalizations.httpCapture), findsNothing);

    await tester.tap(find.text(currentAppLocalizations.options));
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.httpCapture), findsNothing);
    expect(find.text(_certificate.subject), findsOneWidget);
  });

  group('the certificate row', () {
    Finder row() => find.text(_certificate.subject);

    GlyphIcon statusGlyph(WidgetTester tester) => tester.widget<GlyphIcon>(
      find.descendant(
        of: find.widgetWithText(ListItem, _certificate.subject),
        matching: find.byType(GlyphIcon),
      ),
    );

    Color successColor(WidgetTester tester) =>
        tester.element(row()).colorScheme.success;

    testWidgets('refreshes trust after a partial installation fails', (
      tester,
    ) async {
      final store = _FakeStore(
        MitmTrust.notInstalled,
        installTrust: MitmTrust.untrusted,
        installError: const MessageException('certutil missing'),
      );
      await pumpView(tester, certificate: _certificate, store: store);

      await tester.tap(row());
      await tester.pumpAndSettle();

      expect(store.installed, [_certificate]);
      expect(find.text('certutil missing'), findsOneWidget);
      expect(
        find.text(currentAppLocalizations.mitmTrustUntrusted),
        findsOneWidget,
      );
      expect(saved().trustedFingerprint, isNull);
    });

    testWidgets('installs on tap where FlClash has a trust store', (
      tester,
    ) async {
      final store = _FakeStore(MitmTrust.notInstalled);
      await pumpView(tester, certificate: _certificate, store: store);
      expect(statusGlyph(tester).color, isNot(successColor(tester)));
      expect(saved().trustedFingerprint, isNull);

      await tester.tap(row());
      await tester.pumpAndSettle();

      expect(store.installed, [_certificate]);
      expect(find.text(currentAppLocalizations.mitmTrustReady), findsOneWidget);
      expect(statusGlyph(tester).color, successColor(tester));
      expect(saved().trustedFingerprint, _certificate.fingerprint);
    });

    testWidgets('trusts a certificate the store holds untrusted', (
      tester,
    ) async {
      final store = _FakeStore(MitmTrust.untrusted);
      await pumpView(tester, certificate: _certificate, store: store);

      await tester.tap(row());
      await tester.pumpAndSettle();

      expect(store.installed, [_certificate]);
    });

    testWidgets('never installs in safe mode', (tester) async {
      final store = _FakeStore(MitmTrust.notInstalled);
      await pumpView(
        tester,
        certificate: _certificate,
        store: store,
        safeMode: true,
      );

      await tester.tap(row());
      await tester.pumpAndSettle();

      expect(store.installed, isEmpty);
    });

    testWidgets('shows a trusted certificate on tap', (tester) async {
      final store = _FakeStore(MitmTrust.ready);
      await pumpView(tester, certificate: _certificate, store: store);

      await tester.tap(row());
      await tester.pumpAndSettle();

      expect(store.installed, isEmpty);
      expect(
        find.textContaining(currentAppLocalizations.validUntil('2036-10-22')),
        findsOneWidget,
      );
    });

    Finder removeButton() => button(currentAppLocalizations.removeCertificate);

    Future<void> openDetails(WidgetTester tester) async {
      await tester.tap(row());
      await tester.pumpAndSettle();
    }

    Future<void> removeFromDetails(WidgetTester tester) async {
      await openDetails(tester);
      await tester.tap(removeButton());
      await tester.pumpAndSettle();
    }

    testWidgets('offers removal beside close for a trusted certificate', (
      tester,
    ) async {
      final store = _FakeStore(MitmTrust.ready);
      await pumpView(tester, certificate: _certificate, store: store);

      await openDetails(tester);

      expect(button(currentAppLocalizations.close), findsOneWidget);
      expect(removeButton(), findsOneWidget);
      expect(
        tester.widget<AlertDialog>(find.byType(AlertDialog)).destructive,
        isTrue,
      );
      await tester.tap(button(currentAppLocalizations.close));
      await tester.pumpAndSettle();
      expect(store.removed, isEmpty);
    });

    testWidgets('offers no removal while the trust is unknown', (tester) async {
      await pumpView(
        tester,
        certificate: _certificate,
        store: _FakeStore(MitmTrust.notGenerated),
      );

      await openDetails(tester);

      expect(removeButton(), findsNothing);
    });

    testWidgets('offers no removal in safe mode', (tester) async {
      await pumpView(
        tester,
        certificate: _certificate,
        store: _FakeStore(MitmTrust.ready),
        safeMode: true,
      );

      await tester.tap(row());
      await tester.pumpAndSettle();

      expect(removeButton(), findsNothing);
    });

    testWidgets('removing takes it out of the store and keeps the CA', (
      tester,
    ) async {
      final store = _FakeStore(MitmTrust.ready);
      await pumpView(tester, certificate: _certificate, store: store);

      await removeFromDetails(tester);

      expect(store.removed, [_certificate]);
      expect(
        find.text(currentAppLocalizations.mitmTrustNotInstalled),
        findsOneWidget,
      );
      expect(
        find.text(currentAppLocalizations.removeCertificateSuccess),
        findsOneWidget,
      );
      expect(saved().trustedFingerprint, isNull);
      verifyNever(() => mocks.api.generateMitmCertificate());

      await tester.tap(row());
      await tester.pumpAndSettle();
      expect(store.installed, [_certificate]);
    });

    testWidgets('a cancelled system prompt leaves the certificate trusted', (
      tester,
    ) async {
      final store = _FakeStore(
        MitmTrust.ready,
        removeError: const ProcessException('certutil', [], '', 1),
      );
      await pumpView(tester, certificate: _certificate, store: store);

      await removeFromDetails(tester);

      expect(
        find.text(currentAppLocalizations.mitmSystemStoreRemoveFailed),
        findsOneWidget,
      );
      expect(find.textContaining('certutil'), findsNothing);
      expect(find.text(currentAppLocalizations.mitmTrustReady), findsOneWidget);
      expect(saved().trustedFingerprint, _certificate.fingerprint);
    });

    testWidgets('sends a user certificate to the system settings', (
      tester,
    ) async {
      final store = _FakeStore(
        MitmTrust.ready,
        removeOutcome: MitmRemoveOutcome.userStore,
      );
      await pumpView(
        tester,
        certificate: _certificate,
        store: store,
        view: const MitmOptionsView(isAndroid: true),
      );

      await removeFromDetails(tester);

      expect(
        find.text(currentAppLocalizations.mitmRemoveInSettings),
        findsOneWidget,
      );
      expect(
        find.text(
          currentAppLocalizations.mitmRemoveUserCertificateTip(
            _certificate.subject,
          ),
        ),
        findsOneWidget,
      );
      expect(button(currentAppLocalizations.cancel), findsOneWidget);
      expect(button(currentAppLocalizations.openSettings), findsOneWidget);
      expect(find.text(currentAppLocalizations.mitmTrustReady), findsOneWidget);
    });

    testWidgets('says a system certificate needs root to be removed', (
      tester,
    ) async {
      final store = _FakeStore(
        MitmTrust.ready,
        removeOutcome: MitmRemoveOutcome.needsRoot,
      );
      await pumpView(
        tester,
        certificate: _certificate,
        store: store,
        view: const MitmOptionsView(isAndroid: true),
      );

      await removeFromDetails(tester);

      expect(
        find.text(currentAppLocalizations.mitmCannotRemove),
        findsOneWidget,
      );
      expect(
        find.text(currentAppLocalizations.mitmRemoveSystemCertificateTip),
        findsOneWidget,
      );
      expect(button(currentAppLocalizations.openSettings), findsNothing);
      expect(find.text(currentAppLocalizations.mitmTrustReady), findsOneWidget);
    });

    testWidgets('exports from its menu', (tester) async {
      await pumpView(tester, certificate: _certificate);

      await tester.longPress(row());
      await tester.pumpAndSettle();

      expect(
        find.text(currentAppLocalizations.exportCertificate),
        findsOneWidget,
      );
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
      () => mocks.api.generateMitmCertificate(),
    ).thenAnswer((_) async => _renewed.toJson());

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
      () => mocks.api.generateMitmCertificate(),
    ).thenAnswer((_) async => _renewed.toJson());

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
    await pumpView(
      tester,
      mitm: const Mitm(hostname: ['a.test', 'bad host']),
      view: const AdvancedConfigView(),
    );

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
    await pumpView(tester, view: const AdvancedConfigView());

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
    await tester.enterText(find.byType(TextFormField), 'a.test, b.test');
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
