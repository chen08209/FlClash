import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final _networkDetectionState = ValueNotifier<NetworkDetectionState>(
  const NetworkDetectionState(
    isTesting: true,
    ipInfo: null,
  ),
);

class NetworkDetection extends StatefulWidget {
  const NetworkDetection({super.key});

  @override
  State<NetworkDetection> createState() => _NetworkDetectionState();
}

class _NetworkDetectionState extends State<NetworkDetection> {
  bool? _preIsStart;
  Timer? _setTimeoutTimer;
  CancelToken? cancelToken;
  Completer? checkedCompleter;

  @override
  void initState() {
    super.initState();
  }

  _startCheck() async {
    await checkedCompleter?.future;
    if (cancelToken != null) {
      cancelToken!.cancel();
      cancelToken = null;
    }
    debouncer.call(
      DebounceTag.checkIp,
      _checkIp,
    );
  }

  _checkIp() async {
    final appState = globalState.appController.appState;
    final appFlowingState = globalState.appController.appFlowingState;
    final isInit = appState.isInit;
    if (!isInit) return;
    final isStart = appFlowingState.isStart;
    if (_preIsStart == false && _preIsStart == isStart) return;
    _clearSetTimeoutTimer();
    _networkDetectionState.value = _networkDetectionState.value.copyWith(
      isTesting: true,
      ipInfo: null,
    );
    _preIsStart = isStart;
    if (cancelToken != null) {
      cancelToken!.cancel();
      cancelToken = null;
    }
    cancelToken = CancelToken();
    try {
      final ipInfo = await request.checkIp(cancelToken: cancelToken);
      if (ipInfo != null) {
        checkedCompleter = Completer();
        checkedCompleter?.complete(
          Future.delayed(
            Duration(milliseconds: 3000),
          ),
        );
        _networkDetectionState.value = _networkDetectionState.value.copyWith(
          isTesting: false,
          ipInfo: ipInfo,
        );
        return;
      }
      _clearSetTimeoutTimer();
      _setTimeoutTimer = Timer(const Duration(milliseconds: 300), () {
        _networkDetectionState.value = _networkDetectionState.value.copyWith(
          isTesting: false,
          ipInfo: null,
        );
      });
    } catch (e) {
      if (e.toString() == "cancelled") {
        _networkDetectionState.value = _networkDetectionState.value.copyWith(
          isTesting: true,
          ipInfo: null,
        );
      }
    }
  }

  @override
  void dispose() {
    _clearSetTimeoutTimer();
    super.dispose();
  }

  _clearSetTimeoutTimer() {
    if (_setTimeoutTimer != null) {
      _setTimeoutTimer?.cancel();
      _setTimeoutTimer = null;
    }
  }

  _checkIpContainer(Widget child) {
    return Selector<AppState, num>(
      selector: (_, appState) {
        return appState.checkIpNum;
      },
      shouldRebuild: (prev, next) {
        if (prev != next) {
          _startCheck();
        }
        return prev != next;
      },
      builder: (_, checkIpNum, child) {
        return child!;
      },
      child: child,
    );
  }

  _countryCodeToEmoji(String countryCode) {
    final String code = countryCode.toUpperCase();
    if (code.length != 2) {
      return countryCode;
    }
    final int firstLetter = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(1),
      child: _checkIpContainer(
        ValueListenableBuilder<NetworkDetectionState>(
          valueListenable: _networkDetectionState,
          builder: (_, state, __) {
            final ipInfo = state.ipInfo;
            final isTesting = state.isTesting;
            return CommonCard(
              onPressed: () {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: globalState.measure.titleMediumHeight + 16,
                    padding: baseInfoEdgeInsets.copyWith(
                      bottom: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ipInfo != null
                            ? Text(
                                _countryCodeToEmoji(
                                  ipInfo.countryCode,
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.toLight
                                    .copyWith(
                                      fontFamily: FontFamily.twEmoji.value,
                                    ),
                              )
                            : Icon(
                                Icons.network_check,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        const SizedBox(
                          width: 8,
                        ),
                        Flexible(
                          flex: 1,
                          child: TooltipText(
                            text: Text(
                              appLocalizations.networkDetection,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: baseInfoEdgeInsets.copyWith(
                      top: 0,
                    ),
                    child: SizedBox(
                      height: globalState.measure.bodyMediumHeight + 2,
                      child: FadeBox(
                        child: ipInfo != null
                            ? TooltipText(
                                text: Text(
                                  ipInfo.ip,
                                  style: context.textTheme.bodyMedium?.toLight
                                      .adjustSize(1),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : FadeBox(
                                child: isTesting == false && ipInfo == null
                                    ? Text(
                                        "timeout",
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(color: Colors.red)
                                            .adjustSize(1),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : Container(
                                        padding: const EdgeInsets.all(2),
                                        child: const AspectRatio(
                                          aspectRatio: 1,
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                              ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
