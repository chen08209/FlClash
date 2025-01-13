import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AndroidManager extends StatefulWidget {
  final Widget child;

  const AndroidManager({
    super.key,
    required this.child,
  });

  @override
  State<AndroidManager> createState() => _AndroidContainerState();
}

class _AndroidContainerState extends State<AndroidManager> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Widget _updateCoreState(Widget child) {
    return Selector2<Config, ClashConfig, CoreState>(
      selector: (_, config, clashConfig) => globalState.getCoreState(
        config,
        clashConfig,
      ),
      builder: (__, state, child) {
        clashLib?.setState(state);
        return child!;
      },
      child: child,
    );
  }

  Widget _excludeContainer(Widget child) {
    return Selector<Config, bool>(
      selector: (_, config) => config.appSetting.hidden,
      builder: (_, hidden, child) {
        app?.updateExcludeFromRecents(hidden);
        return child!;
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _updateCoreState(
      _excludeContainer(
        widget.child,
      ),
    );
  }
}
