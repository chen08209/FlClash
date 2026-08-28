part of '../action.dart';

@Riverpod(keepAlive: true)
class ThemeAction extends _$ThemeAction {
  @override
  void build() {}

  void updateBrightness() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(systemBrightnessProvider.notifier).value =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
    });
  }

  void updateViewSize(Size size) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ref.read(viewSizeProvider);
      if (current == size) {
        return;
      }
      ref.read(viewSizeProvider.notifier).value = size;
    });
  }
}
