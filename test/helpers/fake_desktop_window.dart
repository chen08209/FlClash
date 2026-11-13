import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rust_api/window.dart';

/// Records every window call as a [MethodCall] and answers queries through
/// [responder]; a query it leaves unanswered reads as false.
class FakeDesktopWindow extends DesktopWindow {
  FakeDesktopWindow([this.responder]);

  Object? Function(MethodCall call)? responder;

  final List<MethodCall> calls = <MethodCall>[];

  List<String> get methods => calls.map((call) => call.method).toList();

  /// Makes this the window every caller drives until the test ends.
  FakeDesktopWindow install() {
    final previous = DesktopWindow.instance;
    DesktopWindow.instance = this;
    addTearDown(() => DesktopWindow.instance = previous);
    return this;
  }

  void emit(WindowEvent event) => dispatch(event);

  Object? _record(String method, [Map<String, Object?>? arguments]) {
    final call = MethodCall(method, arguments);
    calls.add(call);
    return responder?.call(call);
  }

  Future<void> _call(String method, [Map<String, Object?>? arguments]) async {
    _record(method, arguments);
  }

  Future<bool> _query(String method, [Map<String, Object?>? arguments]) async {
    return _record(method, arguments) as bool? ?? false;
  }

  @override
  Future<void> ensureInitialized() => _call('ensureInitialized');

  @override
  Future<void> show() => _call('show');

  @override
  Future<void> hide() => _call('hide');

  @override
  Future<bool> isVisible() => _query('isVisible');

  @override
  Future<void> focus() => _call('focus');

  @override
  Future<void> close() => _call('close');

  @override
  Future<void> setPreventClose(bool value) {
    return _call('setPreventClose', {'value': value});
  }

  @override
  Future<bool> isMaximized() => _query('isMaximized');

  @override
  Future<void> maximize() => _call('maximize');

  @override
  Future<void> unmaximize() => _call('unmaximize');

  @override
  Future<bool> isMinimized() => _query('isMinimized');

  @override
  Future<void> minimize() => _call('minimize');

  @override
  Future<bool> isFullScreen() => _query('isFullScreen');

  @override
  Future<void> setFullScreen(bool value) {
    return _call('setFullScreen', {'value': value});
  }

  @override
  Future<Rect> getBounds() async {
    return _record('getBounds') as Rect? ?? Rect.zero;
  }

  @override
  Future<void> setBounds({Offset? position, Size? size}) {
    final arguments = <String, Object?>{
      'x': position?.dx,
      'y': position?.dy,
      'width': size?.width,
      'height': size?.height,
    }..removeWhere((_, value) => value == null);
    return _call('setBounds', arguments);
  }

  @override
  Future<List<DesktopDisplay>> getDisplays() async {
    return _record('getDisplays') as List<DesktopDisplay>? ?? const [];
  }

  @override
  Future<Offset> getCursorPosition() async {
    return _record('getCursorPosition') as Offset? ?? Offset.zero;
  }

  @override
  Future<bool> isPositionSupported() => _query('isPositionSupported');

  @override
  Future<void> setMinimumSize(Size size) {
    return _call('setMinimumSize', {
      'width': size.width,
      'height': size.height,
    });
  }

  @override
  Future<bool> isAlwaysOnTop() => _query('isAlwaysOnTop');

  @override
  Future<void> setAlwaysOnTop(bool value) {
    return _call('setAlwaysOnTop', {'value': value});
  }

  @override
  Future<void> setTitleBarStyle(TitleBarStyle style) {
    return _call('setTitleBarStyle', {'style': style.name});
  }

  @override
  Future<void> setSkipTaskbar(bool value) {
    return _call('setSkipTaskbar', {'value': value});
  }

  @override
  Future<void> setRoundedCorners(bool value) {
    return _call('setRoundedCorners', {'value': value});
  }

  @override
  Future<bool> isEffectSupported(WindowEffect effect) {
    return _query('isEffectSupported', {'effect': effect.name});
  }

  @override
  Future<void> setEffect(
    WindowEffect effect, {
    Color? tint,
    Brightness? brightness,
  }) {
    return _call('setEffect', {
      'effect': effect.name,
      'tint': tint?.toARGB32(),
      'brightness': brightness?.name,
    });
  }

  @override
  Future<void> startDragging() => _call('startDragging');
}
