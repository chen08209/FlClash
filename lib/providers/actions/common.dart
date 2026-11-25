part of '../action.dart';

@Riverpod(keepAlive: true)
class CommonAction extends _$CommonAction {
  CoreController get _core => ref.read(coreHandlerProvider);
  StreamSubscription<TrafficSample>? _trafficSubscription;
  var _trafficFeed = TrafficFeed.off;
  CancelToken? _updateCancelToken;

  @override
  void build() {
    ref.onDispose(() => _trafficSubscription?.cancel());
    ref.listen(coreStatusProvider, (_, _) => _syncTrafficFeed());
    ref.listen(
      appSettingProvider.select((state) => state.onlyStatisticsProxy),
      (_, _) => _syncTrafficFeed(),
    );
  }

  void toggleRunning() {
    final running = !ref.read(isStartProvider);
    if (running && ref.read(coreStatusProvider) == CoreStatus.disconnected) {
      ref.read(setupActionProvider.notifier).resumeOnRestart();
      unawaited(
        globalState.safeRun(ref.read(coreActionProvider.notifier).restartCore),
      );
      return;
    }
    unawaited(
      globalState.safeRun(
        () => ref
            .read(setupActionProvider.notifier)
            .setRunning(
              running,
              initialize: running && !ref.read(initProvider),
            ),
      ),
    );
  }

  void updateSpeedStatistics() {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(showTrayTitle: !state.showTrayTitle));
  }

  void updateMonochromeTrayIcon() {
    ref
        .read(appSettingProvider.notifier)
        .update(
          (state) =>
              state.copyWith(monochromeTrayIcon: !state.monochromeTrayIcon),
        );
  }

  void updateMode() {
    ref.read(patchClashConfigProvider.notifier).update((state) {
      final index = Mode.values.indexWhere((item) => item == state.mode);
      if (index == -1) return state;
      final nextIndex = index + 1 > Mode.values.length - 1 ? 0 : index + 1;
      return state.copyWith(mode: Mode.values[nextIndex]);
    });
  }

  /// The subscription ends with [TrafficFeed.off], so a feed nobody shows
  /// costs the Core nothing.
  void setTrafficFeed(TrafficFeed feed) {
    if (_trafficFeed == feed) {
      return;
    }
    _trafficFeed = feed;
    _syncTrafficFeed();
  }

  void _syncTrafficFeed() {
    unawaited(_trafficSubscription?.cancel());
    _trafficSubscription = null;
    if (_trafficFeed == TrafficFeed.off ||
        ref.read(coreStatusProvider) != CoreStatus.connected) {
      return;
    }
    final onlyProxy = ref.read(
      appSettingProvider.select((state) => state.onlyStatisticsProxy),
    );
    _trafficSubscription = _core.api
        .watchTraffic(
          intervalMs: 1000,
          onlyProxy: onlyProxy,
          changesOnly: _trafficFeed == TrafficFeed.changesOnly,
        )
        .listen(
          (sample) {
            ref
                .read(trafficsProvider.notifier)
                .addTraffic(trafficOf(sample.up, sample.down));
            ref.read(totalTrafficProvider.notifier).value = trafficOf(
              sample.totalUp,
              sample.totalDown,
            );
          },
          onError: (Object error) => commonPrint.log(
            'traffic feed error: ${compactError(error)}',
            logLevel: coreFailureLogLevel(error),
          ),
        );
  }

  Future<bool> autoCheckUpdate() async {
    final setting = ref.read(appSettingProvider);
    if (!setting.autoCheckUpdate) return false;
    final Map<String, dynamic>? res;
    try {
      res = await request.checkForUpdate(setting.updateChannel);
    } catch (error) {
      commonPrint.log(
        'checkForUpdate failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return false;
    }
    await checkUpdateResultHandle(data: res);
    return res != null;
  }

  TextSpan _releaseSpan(BuildContext context, String tagName, String? body) {
    final version = parseReleaseChangelog(body);
    return TextSpan(
      text: '$tagName \n',
      style: AppTextStyle.title2.of(context),
      children: version == null
          ? [
              TextSpan(text: '\n', style: AppTextStyle.subheadline.of(context)),
              for (final submit in parseReleaseBody(body))
                TextSpan(
                  text: '- $submit \n',
                  style: AppTextStyle.subheadline.of(context),
                ),
            ]
          : _changelogSpans(context, version),
    );
  }

  List<TextSpan> _changelogSpans(
    BuildContext context,
    ChangelogVersion version,
  ) {
    return [
      for (final group in version.visibleGroups) ...[
        TextSpan(
          text:
              '\n${changelogGroupTitle(currentAppLocalizations, group.type)}\n',
          style: AppTextStyle.subheadline
              .of(context, emphasized: true)
              .copyWith(
                color: group.type == ChangelogType.breaking
                    ? context.colorScheme.error
                    : context.colorScheme.primary,
              ),
        ),
        for (final entry in group.entries)
          TextSpan(
            text: '• ${entry.text}\n',
            style: AppTextStyle.subheadline.of(context),
          ),
      ],
    ];
  }

  Future<void> checkUpdateResultHandle({
    Map<String, dynamic>? data,
    bool isUser = false,
  }) async {
    if (data != null) {
      final context = globalState.navigatorKey.currentContext!;
      final tag = data['tag_name'] as String;
      final asset = selfUpdateAsset;
      final res = await dialogs.showMessage(
        title: currentAppLocalizations.discoverNewVersion,
        message: _releaseSpan(context, tag, data['body'] as String?),
        confirmText: asset == null
            ? currentAppLocalizations.goDownload
            : currentAppLocalizations.update,
        cancelText: isUser ? null : currentAppLocalizations.noLongerRemind,
      );
      if (res == true) {
        if (asset == null) {
          _openReleasePage(tag);
        } else {
          unawaited(_downloadUpdate(tag, updateAssetName(tag, asset)));
        }
      } else if (!isUser && res == false) {
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(autoCheckUpdate: false));
      }
    } else if (isUser) {
      unawaited(
        dialogs.showAlert(
          title: currentAppLocalizations.checkUpdate,
          message: TextSpan(text: currentAppLocalizations.checkUpdateError),
        ),
      );
    }
  }

  void _openReleasePage(String tag) {
    unawaited(openReleasePage(tag));
  }

  /// Downloads the latest release for this build even when it is not newer.
  Future<void> testUpdateDownload() async {
    final asset = selfUpdateAsset;
    if (asset == null || ref.read(updateDownloadStateProvider) != null) {
      return;
    }
    final channel = ref.read(appSettingProvider).updateChannel;
    final release = await globalState.loadingRun(
      () => request.newestRelease(channel),
      title: currentAppLocalizations.updateDownloadTest,
      tag: LoadingTag.checkUpdate,
    );
    if (release == null) return;
    final tag = release['tag_name'] as String;
    await _downloadUpdate(tag, updateAssetName(tag, asset));
  }

  Future<void> _downloadUpdate(String tag, String name) async {
    final download = ref.read(updateDownloadStateProvider.notifier);
    if (download.value != null) return;
    final cancelToken = CancelToken();
    _updateCancelToken = cancelToken;
    download.value = UpdateDownloading(tag);
    dialogs.showBanner(currentAppLocalizations.updateDownloadStarted);
    try {
      final directory = await appPath.updateDirPath;
      await clearUpdateDownloads();
      await Directory(directory).create(recursive: true);
      var shown = 0;
      final path = await request.downloadVerifiedRelease(
        tag: tag,
        name: name,
        directory: directory,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          // Every chunk would otherwise rebuild the status on its own frame.
          final step = total > 0 ? total / 100 : 1 << 20;
          if (received - shown < step && received != total) return;
          shown = received;
          download.value = UpdateDownloading(
            tag,
            received: received,
            total: total,
          );
        },
      );
      final ready = switch (macosAppUpdate) {
        final macos? => await macos.stage(path, directory),
        null => path,
      };
      if (cancelToken.cancelError case final cancelled?) throw cancelled;
      download.value = UpdateReady(tag, ready);
      dialogs.showBanner(
        currentAppLocalizations.updateReadyTip,
        level: BannerLevel.success,
        onTap: () => unawaited(installUpdate()),
      );
    } catch (error) {
      download.value = null;
      await clearUpdateDownloads();
      if (error is DioException && CancelToken.isCancel(error)) {
        return;
      }
      if (error is ReleaseFileMissingException) {
        _openReleasePage(tag);
        dialogs.showBanner(currentAppLocalizations.updateFileMissing);
        return;
      }
      commonPrint.log(
        'Update download failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      await _showUpdateFailure(
        tag,
        userFacingErrorMessage(error, currentAppLocalizations),
      );
    } finally {
      if (identical(_updateCancelToken, cancelToken)) {
        _updateCancelToken = null;
      }
    }
  }

  void cancelUpdateDownload() {
    _updateCancelToken?.cancel();
  }

  Future<void> discardUpdate() async {
    if (ref.read(updateDownloadStateProvider) is! UpdateReady) return;
    ref.read(updateDownloadStateProvider.notifier).value = null;
    await clearUpdateDownloads();
  }

  Future<void> installUpdate() async {
    final download = ref.read(updateDownloadStateProvider);
    if (download is! UpdateReady) return;
    if (system.isAndroid) {
      ref.read(updateDownloadStateProvider.notifier).value = null;
      final status = await app?.installPackage(download.path);
      await clearUpdateDownloads();
      if (status != null && packageInstallFailed(status)) {
        await _showUpdateFailure(
          download.tag,
          currentAppLocalizations.updateInstallFailed,
        );
      }
      return;
    }
    if (macosAppUpdate case final macos?) {
      await _installMacosUpdate(macos, download);
      return;
    }
    final started = windows?.runas(download.path, windowsUpdateArguments(pid));
    if (started == true) {
      await ref.read(systemActionProvider.notifier).handleExit();
    } else if (started == false) {
      await _showUpdateFailure(
        download.tag,
        currentAppLocalizations.updateInstallFailed,
      );
    }
  }

  Future<void> _installMacosUpdate(
    MacosAppUpdate macos,
    UpdateReady download,
  ) async {
    try {
      final started = await macos.install(
        staged: download.path,
        tag: download.tag,
        marker: await macosInstallFailurePath,
      );
      if (!started) return;
    } catch (error) {
      commonPrint.log(
        'Update install failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      await _showUpdateFailure(
        download.tag,
        currentAppLocalizations.updateInstallFailed,
      );
      return;
    }
    await ref.read(systemActionProvider.notifier).handleExit();
  }

  /// Clears what an earlier update left behind and reports a macOS install
  /// that could not finish after the app quit.
  Future<void> settleUpdateDownloads() async {
    final failure = system.isMacOS
        ? await takeMacosInstallFailure(await macosInstallFailurePath)
        : null;
    await clearUpdateDownloads();
    if (failure == null) return;
    commonPrint.log(
      'Update install failed: ${failure.reason}',
      logLevel: LogLevel.warning,
    );
    await _showUpdateFailure(
      failure.tag,
      currentAppLocalizations.updateInstallFailed,
    );
  }

  Future<void> _showUpdateFailure(String tag, String message) async {
    final res = await dialogs.showMessage(
      title: currentAppLocalizations.updateFailed,
      message: TextSpan(text: message),
      confirmText: currentAppLocalizations.goDownload,
    );
    if (res == true) {
      _openReleasePage(tag);
    }
  }
}
