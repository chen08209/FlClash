import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NetworkDetection extends StatefulWidget {
  const NetworkDetection({super.key});

  @override
  State<NetworkDetection> createState() => _NetworkDetectionState();
}

class _NetworkDetectionState extends State<NetworkDetection> {
  final networkDetectionState = ValueNotifier<NetworkDetectionState>(
    const NetworkDetectionState(
      isTesting: true,
      ipInfo: null,
    ),
  );
  bool? _preIsStart;
  Function? _checkIpDebounce;
  CancelToken? cancelToken;

  _checkIp() async {
    final appState = globalState.appController.appState;
    final isInit = appState.isInit;
    if (!isInit) return;
    final isStart = appState.isStart;
    if (_preIsStart == false && _preIsStart == isStart) return;
    networkDetectionState.value = networkDetectionState.value.copyWith(
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
      networkDetectionState.value = networkDetectionState.value.copyWith(
        isTesting: false,
        ipInfo: ipInfo,
      );
    } catch (_) {}
  }

  _checkIpContainer(Widget child) {
    return Selector<AppState, num>(
      selector: (_, appState) {
        return appState.checkIpNum;
      },
      builder: (_, checkIpNum, child) {
        if (_checkIpDebounce != null) {
          _checkIpDebounce!();
        }
        return child!;
      },
      child: child,
    );
  }

  @override
  void dispose() {
    super.dispose();
    networkDetectionState.dispose();
  }

  String countryCodeToEmoji(String countryCode) {
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
    _checkIpDebounce ??= debounce(_checkIp);
    return _checkIpContainer(
      ValueListenableBuilder<NetworkDetectionState>(
        valueListenable: networkDetectionState,
        builder: (_, state, __) {
          final ipInfo = state.ipInfo;
          final isTesting = state.isTesting;
          return CommonCard(
            onPressed: () {},
            child: Column(
              children: [
                Flexible(
                  flex: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.network_check,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Flexible(
                          flex: 1,
                          child: FadeBox(
                            child: isTesting
                                ? Text(
                                    appLocalizations.checking,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  )
                                : ipInfo != null
                                    ? Container(
                                        alignment: Alignment.centerLeft,
                                        height: globalState
                                            .measure.titleMediumHeight,
                                        child: Text(
                                          countryCodeToEmoji(
                                              ipInfo.countryCode),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontFamily: "Twemoji",
                                              ),
                                        ),
                                      )
                                    : Text(
                                        appLocalizations.checkError,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: globalState.measure.titleLargeHeight + 24 - 2,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(16).copyWith(top: 0),
                  child: FadeBox(
                    child: ipInfo != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                flex: 1,
                                child: TooltipText(
                                  text: Text(
                                    ipInfo.ip,
                                    style: context.textTheme.titleLarge
                                        ?.toSoftBold.toMinus,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : FadeBox(
                            child: isTesting == false && ipInfo == null
                                ? Text(
                                    "timeout",
                                    style: context.textTheme.titleLarge
                                        ?.copyWith(color: Colors.red)
                                        .toSoftBold
                                        .toMinus,
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
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
