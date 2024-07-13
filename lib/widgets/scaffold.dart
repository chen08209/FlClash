import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/common/system.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonScaffold extends StatefulWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const CommonScaffold({
    super.key,
    required this.body,
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
          leading: SizedBox(
            height: kToolbarHeight,
            child: IconButton(
              icon: const BackButtonIcon(),
              onPressed: () {
                onBack();
              },
            ),
          ),
        );

  @override
  State<CommonScaffold> createState() => CommonScaffoldState();
}

class CommonScaffoldState extends State<CommonScaffold> {
  final ValueNotifier<List<Widget>> _actions = ValueNotifier([]);
  final ValueNotifier<bool> _loading = ValueNotifier(false);

  set actions(List<Widget> actions) {
    if (_actions.value != actions) {
      _actions.value = actions;
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
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CommonScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      _actions.value = [];
    }
  }

  _platformContainer({required Widget child}) {
    if (system.isDesktop) {
      return child;
    }
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _platformContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ValueListenableBuilder(
                valueListenable: _actions,
                builder: (_, actions, __) {
                  return AppBar(
                    automaticallyImplyLeading: widget.automaticallyImplyLeading,
                    leading: widget.leading,
                    title: Text(widget.title),
                    actions: actions.isNotEmpty ? actions : widget.actions,
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
        body: widget.body,
        bottomNavigationBar: widget.bottomNavigationBar,
      ),
    );
  }
}

class AppIcon extends StatelessWidget {
  const AppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      width: 30,
      height: 30,
      child: const CircleAvatar(
        foregroundImage: AssetImage("assets/images/launch_icon.png"),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
