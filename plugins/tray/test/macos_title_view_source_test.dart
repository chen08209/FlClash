import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _resolveSource(String relativePath) {
  final direct = File(relativePath);
  if (direct.existsSync()) {
    return direct;
  }
  final inPlugin = File('plugins/tray/$relativePath');
  if (inPlugin.existsSync()) {
    return inPlugin;
  }
  return direct;
}

void main() {
  late String titleViewSource;
  late String statusItemSource;

  setUpAll(() {
    titleViewSource = _resolveSource(
      'macos/tray/Sources/tray/TrayTitleView.swift',
    ).readAsStringSync();
    statusItemSource = _resolveSource(
      'macos/tray/Sources/tray/TrayStatusItem.swift',
    ).readAsStringSync();
  });

  test('macOS tray title is self-drawn instead of using NSTextField', () {
    expect(titleViewSource, contains('final class TrayTitleView: NSView'));
    expect(titleViewSource, isNot(contains('NSTextField')));
  });

  test('macOS tray title centres its cap-height block, right-aligned', () {
    expect(titleViewSource, contains('override var isFlipped: Bool'));
    expect(titleViewSource, contains('(bounds.height - blockHeight) / 2'));
    expect(titleViewSource, contains('x: bounds.width - width'));
  });

  test('macOS tray title widens instead of clipping long speeds', () {
    expect(titleViewSource, contains('invalidateIntrinsicContentSize'));
    expect(titleViewSource, contains('max(TrayTitleView.width, textWidth)'));
    expect(
      statusItemSource,
      contains('greaterThanOrEqualToConstant: TrayTitleView.width'),
    );
  });

  test('macOS status item reports a missing status button', () {
    expect(statusItemSource, contains('init?('));
    expect(
      statusItemSource,
      contains('''
        guard let button = statusItem.button else {
            NSStatusBar.system.removeStatusItem(statusItem)
            return nil
        }'''),
    );
  });

  test('macOS status item only refits the button on visible change', () {
    expect(statusItemSource, contains('if contentView.setImage(image'));
    expect(statusItemSource, contains('if contentView.setTitle(title)'));
    expect(statusItemSource, contains('wasHidden != imageView.isHidden'));
  });

  test('macOS tray icon position reorders image and title views', () {
    expect(statusItemSource, contains('applyPosition'));
    expect(statusItemSource, contains('insertArrangedSubview'));
    expect(statusItemSource, contains('position == "trailing"'));
  });
}
