import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartButton extends StatefulWidget {
  const StartButton({super.key});

  @override
  State<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton>
    with SingleTickerProviderStateMixin {
  bool isStart = false;
  bool isInit = false;
  late AnimationController _controller;

  @override
  void initState() {
    isStart = globalState.appController.appState.isStart;
    _controller = AnimationController(
      vsync: this,
      value: isStart ? 1 : 0,
      duration: const Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  handleSwitchStart() {
    isStart = !isStart;
    updateController();
    updateSystemProxy();
  }

  updateController() {
    if (isStart) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  updateSystemProxy() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appController = globalState.appController;
      await appController.updateSystemProxy(isStart);
    });
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Selector2<AppState, Config, StartButtonSelectorState>(
      selector: (_, appState, config) => StartButtonSelectorState(
        isInit: appState.isInit,
        hasProfile: config.profiles.isNotEmpty,
      ),
      builder: (_, state, child) {
        if (!state.isInit || !state.hasProfile) {
          return Container();
        }
        final textWidth = globalState.appController.measure
                .computeTextSize(
                  Text(
                    other.getTimeDifference(
                      DateTime.now(),
                    ),
                    style:
                        Theme.of(context).textTheme.titleMedium?.toSoftBold(),
                  ),
                )
                .width +
            16;
        return AnimatedBuilder(
          animation: _controller.view,
          builder: (_, child) {
            return SizedBox(
              width: 56 + textWidth * _controller.value,
              height: 56,
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  handleSwitchStart();
                },
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      child: AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        progress: _controller,
                      ),
                    ),
                    Expanded(
                      child: ClipRect(
                        child: OverflowBox(
                          maxWidth: textWidth,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: child!,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: child,
        );
      },
      child: Selector<AppState, bool>(
        selector: (_, appState) => appState.runTime != null,
        builder: (_, isRun, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (isStart != isRun) {
              isStart = isRun;
              updateController();
            }
          });
          return child!;
        },
        child: Selector<AppState, int?>(
          selector: (_, appState) => appState.runTime,
          builder: (_, int? value, __) {
            final text = other.getTimeText(value);
            return Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.toSoftBold(),
            );
          },
        ),
      ),
    );
  }
}
