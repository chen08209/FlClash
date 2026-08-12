import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/favorite_proxies.dart';
import 'package:fl_clash/views/proxies/card.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _favorite = FavoriteProxy(groupName: 'GLOBAL', proxyName: 'HK');
const _group = Group(
  name: 'GLOBAL',
  type: GroupType.Selector,
  testUrl: 'https://example.com',
  all: [Proxy(name: 'HK', type: 'ss')],
);

void main() {
  testWidgets('shows an empty-state instruction without favorites', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        const Profile(id: 1, autoUpdateDuration: defaultUpdateDuration),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Favorite proxies'), findsOneWidget);
    expect(
      find.text('Star proxies on the Proxies page to show them here.'),
      findsOneWidget,
    );
  });

  testWidgets('renders favorites with two and four responsive columns', (
    tester,
  ) async {
    const profile = Profile(
      id: 1,
      autoUpdateDuration: defaultUpdateDuration,
      favoriteProxies: [_favorite],
    );
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_buildApp(profile, groups: const [_group]));
    await tester.pumpAndSettle();

    expect(globalState.container.read(currentProfileProvider), profile);
    expect(globalState.container.read(groupsProvider), const [_group]);
    expect(globalState.container.read(favoriteProxiesProvider), const [
      _favorite,
    ]);
    expect(tester.widget<Grid>(find.byType(Grid)).crossAxisCount, 2);
    expect(find.text('GLOBAL'), findsOneWidget);
    expect(_findEmojiText('HK'), findsOneWidget);

    await tester.binding.setSurfaceSize(const Size(800, 800));
    await tester.pumpAndSettle();

    expect(tester.widget<Grid>(find.byType(Grid)).crossAxisCount, 4);
  });

  testWidgets('switches the exact favorite group and proxy on tap', (
    tester,
  ) async {
    const profile = Profile(
      id: 1,
      autoUpdateDuration: defaultUpdateDuration,
      favoriteProxies: [_favorite],
    );
    await tester.pumpWidget(_buildApp(profile, groups: const [_group]));
    await tester.pumpAndSettle();

    await tester.tap(_findEmojiText('HK'));
    await tester.pump();

    expect(globalState.container.read(currentProfileProvider)?.selectedMap, {
      'GLOBAL': 'HK',
    });
    final action = globalState.container.read(proxiesActionProvider.notifier);
    expect(action, isA<_TestProxiesAction>());
    expect((action as _TestProxiesAction).changedGroupName, 'GLOBAL');
    expect(action.changedProxyName, 'HK');
  });

  testWidgets('star button toggles a selectable proxy without switching it', (
    tester,
  ) async {
    const profile = Profile(id: 1, autoUpdateDuration: defaultUpdateDuration);
    await tester.pumpWidget(
      _buildApp(
        profile,
        groups: const [_group],
        child: const SizedBox(
          height: 140,
          child: ProxyCard(
            groupName: 'GLOBAL',
            testUrl: 'https://example.com',
            proxy: Proxy(name: 'HK', type: 'ss'),
            groupType: GroupType.Selector,
            type: ProxyCardType.shrink,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.star_border));
    await tester.pump();

    expect(
      globalState.container.read(currentProfileProvider)?.favoriteProxies,
      [_favorite],
    );
    final action = globalState.container.read(proxiesActionProvider.notifier);
    expect((action as _TestProxiesAction).changedGroupName, isNull);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}

Finder _findEmojiText(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is EmojiText && widget.text == text,
  );
}

Widget _buildApp(
  Profile profile, {
  List<Group> groups = const [],
  Widget child = const FavoriteProxies(),
}) {
  return ProviderScope(
    overrides: [
      currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
      profilesProvider.overrideWith(() => _TestProfiles([profile])),
      groupsProvider.overrideWithBuild((_, _) => groups),
      proxiesActionProvider.overrideWith(_TestProxiesAction.new),
    ],
    child: _TestApp(child: child),
  );
}

class _TestApp extends StatelessWidget {
  final Widget child;

  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalState.navigatorKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      builder: (context, child) {
        globalState.container = ProviderScope.containerOf(context);
        globalState.theme = CommonTheme.of(context, 1);
        globalState.measure = Measure.of(context, 1);
        return child!;
      },
      home: Scaffold(body: child),
    );
  }
}

class _TestProfiles extends Profiles {
  final List<Profile> initial;

  _TestProfiles(this.initial);

  @override
  List<Profile> build() => initial;

  @override
  void put(Profile profile) {
    final next = List<Profile>.from(state);
    final index = next.indexWhere((item) => item.id == profile.id);
    if (index == -1) {
      next.add(profile);
    } else {
      next[index] = profile;
    }
    state = next;
  }
}

class _TestProxiesAction extends ProxiesAction {
  String? changedGroupName;
  String? changedProxyName;

  @override
  void changeProxyDebounce(String groupName, String proxyName) {
    changedGroupName = groupName;
    changedProxyName = proxyName;
  }
}
