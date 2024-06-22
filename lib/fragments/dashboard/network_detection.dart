import 'package:country_flags/country_flags.dart';
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
  final ipInfoNotifier = ValueNotifier<IpInfo?>(null);
  final timeoutNotifier = ValueNotifier<bool>(false);
  bool? _preIsStart;
  CancelToken? cancelToken;
  Function? _checkIpDebounce;

  _checkIp(
    bool isInit,
    bool isStart,
  ) async {
    if (!isInit) return;
    timeoutNotifier.value = false;
    if (_preIsStart == false && _preIsStart == isStart) return;
    if (cancelToken != null) {
      cancelToken!.cancel();
      cancelToken = null;
    }
    ipInfoNotifier.value = null;
    final ipInfo = await request.checkIp(cancelToken);
    if (ipInfo == null) {
      timeoutNotifier.value = true;
      return;
    } else {
      timeoutNotifier.value = false;
    }
    _preIsStart = isStart;
    ipInfoNotifier.value = ipInfo;
  }

  _checkIpContainer(Widget child) {
    _checkIpDebounce = debounce(_checkIp);
    return Selector2<AppState, Config, CheckIpSelectorState>(
      selector: (_, appState, config) {
        return CheckIpSelectorState(
          isInit: appState.isInit,
          selectedMap: appState.selectedMap,
          isStart: appState.isStart,
        );
      },
      builder: (_, state, __) {
        if (_checkIpDebounce != null) {
          _checkIpDebounce!([state.isInit, state.isStart]);
        }
        return child;
      },
      child: child,
    );
  }

  @override
  void dispose() {
    super.dispose();
    ipInfoNotifier.dispose();
    timeoutNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _checkIpContainer(
      ValueListenableBuilder<IpInfo?>(
        valueListenable: ipInfoNotifier,
        builder: (_, ipInfo, __) {
          return CommonCard(
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
                            child: ipInfo != null
                                ? CountryFlag.fromCountryCode(
                                    ipInfo.countryCode,
                                    width: 24,
                                    height: 24,
                                  )
                                : ValueListenableBuilder(
                                    valueListenable: timeoutNotifier,
                                    builder: (_, timeout, __) {
                                      if (timeout) {
                                        return Text(
                                          appLocalizations.checkError,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      }
                                      return TooltipText(
                                        text: Text(
                                          appLocalizations.checking,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height:
                      globalState.appController.measure.titleLargeHeight + 24 - 1,
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
                        : ValueListenableBuilder(
                            valueListenable: timeoutNotifier,
                            builder: (_, timeout, __) {
                              if (timeout) {
                                return Text(
                                  "timeout",
                                  style: context.textTheme.titleLarge
                                      ?.copyWith(color: Colors.red)
                                      .toSoftBold.toMinus,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return Container(
                                padding: const EdgeInsets.all(2),
                                child: const AspectRatio(
                                  aspectRatio: 1,
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
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
