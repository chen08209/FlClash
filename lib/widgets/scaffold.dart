import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonScaffold extends StatefulWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const CommonScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.leading,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  CommonScaffold.open({
    Key? key,
    required Widget body,
    Widget? title,
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

  loadingRun(Future<void> Function() futureFunction) async {
    _loading.value = true;
    await futureFunction();
    _loading.value = false;
  }

  @override
  void didUpdateWidget(covariant CommonScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      _actions.value = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
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
                    title: widget.title,
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
