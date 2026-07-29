import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart' as webview_windows;

class InnerBrowserPage extends StatefulWidget {
  final String url;

  const InnerBrowserPage({super.key, required this.url});

  @override
  State<InnerBrowserPage> createState() => _InnerBrowserPageState();
}

class _InnerBrowserPageState extends State<InnerBrowserPage> {
  WebViewController? _controller;
  webview_windows.WebviewController? _windowsController;
  final List<StreamSubscription> _windowsSubscriptions = [];
  late final TextEditingController _pathController;
  String _currentUrl = '';
  bool _loading = true;
  bool _canGoBack = false;
  bool _canGoForward = false;

  bool get _supportsWebView =>
      Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isMacOS ||
      Platform.isWindows;

  @override
  void initState() {
    super.initState();
    _currentUrl = _normalizeUrl(widget.url);
    _pathController = TextEditingController(text: _currentUrl);
    if (Platform.isWindows) {
      unawaited(_initWindowsWebView());
    } else if (_supportsWebView) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: _handlePageChanged,
            onPageFinished: _handlePageChanged,
            onUrlChange: (change) {
              final url = change.url;
              if (url != null) _handleUrlChanged(url);
            },
          ),
        )
        ..loadRequest(Uri.parse(_currentUrl));
    } else {
      _loading = false;
    }
  }

  @override
  void dispose() {
    for (final subscription in _windowsSubscriptions) {
      subscription.cancel();
    }
    unawaited(_windowsController?.dispose() ?? Future<void>.value());
    _pathController.dispose();
    super.dispose();
  }

  Future<void> _initWindowsWebView() async {
    final controller = webview_windows.WebviewController();
    _windowsController = controller;
    try {
      await controller.initialize();
      _windowsSubscriptions.add(
        controller.url.listen((url) {
          _handleUrlChanged(url);
        }),
      );
      _windowsSubscriptions.add(
        controller.title.listen((_) {
          _refreshState();
        }),
      );
      _windowsSubscriptions.add(
        controller.historyChanged.listen((event) {
          if (!mounted) return;
          setState(() {
            _canGoBack = event.canGoBack;
            _canGoForward = event.canGoForward;
          });
        }),
      );
      _windowsSubscriptions.add(
        controller.loadingState.listen((state) {
          if (!mounted) return;
          setState(() {
            _loading = state == webview_windows.LoadingState.loading;
          });
        }),
      );
      await controller.setBackgroundColor(Colors.transparent);
      await controller.setPopupWindowPolicy(
        webview_windows.WebviewPopupWindowPolicy.deny,
      );
      await controller.loadUrl(_currentUrl);
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      context.showNotifier(e.toString());
    }
  }

  String _normalizeUrl(String value) {
    final text = value.trim();
    if (text.startsWith('http://') || text.startsWith('https://')) return text;
    return 'https://$text';
  }

  Future<void> _refreshState() async {
    final controller = _controller;
    if (controller == null) return;
    final url = await controller.currentUrl();
    final canGoBack = await controller.canGoBack();
    final canGoForward = await controller.canGoForward();
    if (!mounted) return;
    setState(() {
      _canGoBack = canGoBack;
      _canGoForward = canGoForward;
      _loading = false;
      if (url != null) {
        _currentUrl = url;
        _pathController.text = url;
      }
    });
  }

  void _handleUrlChanged(String url) {
    if (!mounted) return;
    setState(() {
      _currentUrl = url;
      _pathController.text = url;
    });
  }

  Future<void> _handlePageChanged(String url) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _currentUrl = url;
      _pathController.text = url;
    });
    await _refreshState();
  }

  Future<void> _loadPath(String value) async {
    final url = _normalizeUrl(value);
    _currentUrl = url;
    _pathController.text = url;
    final controller = _controller;
    final windowsController = _windowsController;
    if (controller == null && windowsController == null) {
      await _openExternal();
      return;
    }
    if (controller != null) {
      await controller.loadRequest(Uri.parse(url));
    } else {
      await windowsController!.loadUrl(url);
    }
  }

  Future<void> _goBack() async {
    final controller = _controller;
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
      await _refreshState();
      return;
    }
    if (_windowsController != null && _canGoBack) {
      await _windowsController!.goBack();
    }
  }

  Future<void> _goForward() async {
    final controller = _controller;
    if (controller != null && await controller.canGoForward()) {
      await controller.goForward();
      await _refreshState();
      return;
    }
    if (_windowsController != null && _canGoForward) {
      await _windowsController!.goForward();
    }
  }

  Future<void> _reload() async {
    await _controller?.reload();
    await _windowsController?.reload();
  }

  Future<void> _openExternal() async {
    await launchUrl(
      Uri.parse(_currentUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _downloadCurrent() async {
    await BrowserDownloadManager.instance.start(_currentUrl);
    if (mounted) context.showNotifier('已加入下载');
  }

  void _showDownloads() {
    showExtend(context, builder: (_) => const BrowserDownloadsPage());
  }

  List<PopupMenuItemData> _menuItems() {
    return [
      PopupMenuItemData(
        icon: Icons.download_outlined,
        label: '下载当前链接',
        onPressed: _downloadCurrent,
      ),
      PopupMenuItemData(
        icon: Icons.download_done_outlined,
        label: '查看下载内容',
        onPressed: _showDownloads,
      ),
      PopupMenuItemData(
        icon: Icons.open_in_browser_outlined,
        label: '浏览器打开',
        onPressed: _openExternal,
      ),
    ];
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 8,
      title: Row(
        children: [
          IconButton(
            tooltip: '返回',
            onPressed: _canGoBack ? _goBack : null,
            icon: const Icon(Icons.arrow_back),
          ),
          IconButton(
            tooltip: '前进',
            onPressed: _canGoForward ? _goForward : null,
            icon: const Icon(Icons.arrow_forward),
          ),
          IconButton(
            tooltip: '刷新',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      actions: [
        CommonPopupBox(
          targetBuilder: (open) {
            return IconButton(
              tooltip: '更多',
              onPressed: open,
              icon: const Icon(Icons.more_vert),
            );
          },
          popup: CommonPopupMenu(items: _menuItems()),
        ),
      ],
      bottom: _loading
          ? const PreferredSize(
              preferredSize: Size.fromHeight(2),
              child: LinearProgressIndicator(minHeight: 2),
            )
          : null,
    );
  }

  Widget _buildBody() {
    final controller = _controller;
    if (controller != null) return WebViewWidget(controller: controller);
    final windowsController = _windowsController;
    if (windowsController != null) {
      if (!windowsController.value.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }
      return webview_windows.Webview(windowsController);
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.web_asset_off_outlined, size: 48),
            const SizedBox(height: 12),
            const Text('当前平台暂不支持内置 WebView'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _openExternal,
              icon: const Icon(Icons.open_in_browser),
              label: const Text('浏览器打开'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: SizedBox(
          height: 40,
          child: TextField(
            controller: _pathController,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            onSubmitted: _loadPath,
            decoration: const InputDecoration(
              isDense: true,
              prefixIcon: Icon(Icons.link),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          _buildPathBar(),
        ],
      ),
    );
  }
}

class BrowserDownloadsPage extends StatelessWidget {
  const BrowserDownloadsPage({super.key});

  String _statusText(BrowserDownloadItem item) {
    return switch (item.status) {
      BrowserDownloadStatus.queued => '等待中',
      BrowserDownloadStatus.downloading => '${item.speed.traffic.show}/s',
      BrowserDownloadStatus.paused => '已暂停',
      BrowserDownloadStatus.completed => '已完成',
      BrowserDownloadStatus.failed => item.error ?? '下载失败',
    };
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '下载内容',
      body: ValueListenableBuilder<List<BrowserDownloadItem>>(
        valueListenable: BrowserDownloadManager.instance.itemsNotifier,
        builder: (_, items, _) {
          if (items.isEmpty) {
            return const NullStatus(label: '暂无下载');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (_, index) {
              final item = items[index];
              return ListItem(
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: Text(
                  item.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '${item.received.traffic.show}'
                      '${item.total > 0 ? ' / ${item.total.traffic.show}' : ''}'
                      ' · ${_statusText(item)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(value: item.progress),
                  ],
                ),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    if (item.status == BrowserDownloadStatus.downloading)
                      IconButton(
                        onPressed: () {
                          BrowserDownloadManager.instance.pause(item.id);
                        },
                        icon: const Icon(Icons.pause),
                      )
                    else if (item.status != BrowserDownloadStatus.completed)
                      IconButton(
                        onPressed: () {
                          BrowserDownloadManager.instance.resume(item.id);
                        },
                        icon: const Icon(Icons.play_arrow),
                      ),
                    IconButton(
                      onPressed: () {
                        BrowserDownloadManager.instance.delete(item.id);
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
