import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/fade_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonScaffold extends StatefulWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? sideNavigationBar;
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const CommonScaffold({
    super.key,
    required this.body,
    this.sideNavigationBar,
    this.bottomNavigationBar,
    this.leading,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  CommonScaffold.open({
    Key? key,
    required Widget body,
    required String title,
    required Function onBack,
  }) : this(
          key: key,
          body: body,
          title: title,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: () {
              onBack();
            },
          ),
        );

  @override
  State<CommonScaffold> createState() => CommonScaffoldState();
}

class CommonScaffoldState extends State<CommonScaffold> {
  final ValueNotifier<List<Widget>> _actions = ValueNotifier([]);
  final ValueNotifier<Widget?> _floatingActionButton = ValueNotifier(null);
  final ValueNotifier<bool> _loading = ValueNotifier(false);

  set actions(List<Widget> actions) {
    if (_actions.value != actions) {
      _actions.value = actions;
    }
  }

  set floatingActionButton(Widget? floatingActionButton) {
    if (_floatingActionButton.value != floatingActionButton) {
      _floatingActionButton.value = floatingActionButton;
    }
  }

  Future<T?> loadingRun<T>(
    Future<T> Function() futureFunction, {
    String? title,
  }) async {
    _loading.value = true;
    try {
      final res = await futureFunction();
      _loading.value = false;
      return res;
    } catch (e) {
      globalState.showMessage(
        title: title ?? appLocalizations.tip,
        message: TextSpan(
          text: e.toString(),
        ),
      );
      _loading.value = false;
      return null;
    }
  }

  @override
  void dispose() {
    _actions.dispose();
    _floatingActionButton.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CommonScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      _actions.value = [];
      _floatingActionButton.value = null;
    }
  }

  Widget? get _sideNavigationBar => widget.sideNavigationBar;

  Widget get body => SafeArea(child: widget.body);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ValueListenableBuilder<List<Widget>>(
              valueListenable: _actions,
              builder: (_, actions, __) {
                final realActions =
                actions.isNotEmpty ? actions : widget.actions ?? [];
                return AppBar(
                  centerTitle: false,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness:
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark,
                    systemNavigationBarIconBrightness:
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark,
                    systemNavigationBarColor: widget.bottomNavigationBar != null
                        ? context.colorScheme.surfaceContainer
                        : context.colorScheme.surface,
                    systemNavigationBarDividerColor: Colors.transparent,
                  ),
                  automaticallyImplyLeading: widget.automaticallyImplyLeading,
                  leading: widget.leading,
                  title: Text(widget.title),
                  actions: [
                    ...realActions.separated(
                      SizedBox(
                        width: 4,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    )
                  ],
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: _loading,
              builder: (_, value, __) {
                return value == true
                    ? const LinearProgressIndicator()
                    : Container();
              },
            ),
          ],
        ),
      ),
      body: body,
      floatingActionButton: ValueListenableBuilder<Widget?>(
        valueListenable: _floatingActionButton,
        builder: (_, value, __) {
          return FadeScaleBox(
            child: value ?? SizedBox(),
          );
        },
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
    return _sideNavigationBar != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sideNavigationBar!,
              Expanded(
                flex: 1,
                child: Material(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: scaffold,
                  ),
                ),
              ),
            ],
          )
        : scaffold;
  }
}
