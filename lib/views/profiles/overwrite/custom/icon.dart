import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _IconEditStateNotifier<T> extends ChangeNotifier {
  _IconEditStateNotifier({
    required TickerProvider vsync,
    required Duration duration,
    T? initialValue,
  }) : _value = initialValue {
    _controller = AnimationController(vsync: vsync, duration: duration);
    _layout = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack),
    );
    _controller.addListener(notifyListeners);
  }

  late final AnimationController _controller;
  late final CurvedAnimation _layout;
  late final CurvedAnimation _opacity;
  late final CurvedAnimation _scale;

  T? _value;

  double get layoutFactor => _layout.value;

  double get opacity => _opacity.value;

  double get scale => _scale.value;

  T? get value => _value;

  void setValue(T? newValue) {
    if (newValue == null) {
      _controller.reverse().then((_) {
        _value = null;
        notifyListeners();
      });
    } else {
      _value = newValue;
      notifyListeners();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(notifyListeners);
    _controller.dispose();
    super.dispose();
  }
}

class IconEditView extends ConsumerStatefulWidget {
  final String? value;

  const IconEditView(this.value, {super.key});

  @override
  ConsumerState<IconEditView> createState() => _IconEditViewState();
}

class _IconEditViewState extends ConsumerState<IconEditView>
    with TickerProviderStateMixin {
  late final TextEditingController _srcController;
  late final ValueNotifier<List<IconRecord>> _recordsNotifier;
  StreamSubscription? _streamSubscription;
  late final _IconEditStateNotifier<File?> _state;

  @override
  void initState() {
    super.initState();
    _srcController = TextEditingController(text: widget.value);
    _recordsNotifier = ValueNotifier([]);
    _state = _IconEditStateNotifier<File?>(
      vsync: this,
      duration: commonDuration * 2,
    );
    _handleInputRealChange();
  }

  Future<void> _handleInputChange() async {
    debouncer.call('_IconEditDialogState_search', () {
      _handleInputRealChange();
    });
  }

  void _handleInputRealChange() {
    _handleUpdateIconRecords();
    _getImageFormCache();
  }

  Future<void> _handleUpdateIconRecords() async {
    _recordsNotifier.value = [];
    final text = _srcController.text;
    final res = await database.iconRecordsDao.query(text);
    if (mounted) {
      _recordsNotifier.value = res;
    }
  }

  void _getImageFormCache() {
    final text = _srcController.text;
    _streamSubscription?.cancel();
    _state.setValue(null);
    if (text.isEmpty || !text.isUrl) return;
    _streamSubscription = DefaultCacheManager().getFileStream(text).listen((
      data,
    ) {
      if (mounted && data is FileInfo) {
        _state.setValue(data.file);
      }
    });
  }

  @override
  void dispose() {
    _recordsNotifier.dispose();
    _state.dispose();
    _streamSubscription?.cancel();
    _srcController.dispose();
    super.dispose();
  }

  Widget _buildItem({
    required BuildContext context,
    required IconRecord record,
    required int index,
    required int total,
    required VoidCallback onPressed,
    bool isSelected = false,
  }) {
    final position = ItemPosition.get(index, total);
    return ItemPositionProvider(
      position: position,
      child: DecorationListItem(
        onPressed: onPressed,
        minVerticalPadding: 12,
        leading: SizedBox.square(
          dimension: 28,
          child: IconTheme.merge(
            data: const IconThemeData(size: 28),
            child: CommonTargetIcon(src: record.url),
          ),
        ),
        title: TooltipText(
          text: Text(record.url, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        isSelected: isSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final dimension = globalState.measure.bodyLargeHeight + 28;
    final isBottomSheet =
        SheetProvider.of(context)?.type == SheetType.bottomSheet;
    final height = isBottomSheet
        ? globalState.container.read(viewSizeProvider).height * 0.5
        : double.maxFinite;
    return AdaptiveSheetScaffold(
      backAction: () {
        Navigator.of(context).pop(_srcController.text);
      },
      title: appLocalizations.icon,
      body: SizedBox(
        height: height,
        child: ValueListenableBuilder(
          valueListenable: _recordsNotifier,
          builder: (_, records, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: dimension,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ListenableBuilder(
                          listenable: _state,
                          builder: (_, _) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  widthFactor: _state.layoutFactor,
                                  alignment: Alignment.centerLeft,
                                  child: Opacity(
                                    opacity: _state.opacity.clamp(0, 1.0),
                                    child: Transform.scale(
                                      scale: 0.5 + (0.5 * _state.scale),
                                      child: SizedBox.square(
                                        dimension: dimension,
                                        child: _state.value != null
                                            ? CommonCard(
                                                type: CommonCardType.filled,
                                                radius: 20,
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                child: CommonImage(
                                                  isSvg:
                                                      _srcController.text.isSvg,
                                                  data: _state.value!,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12 * _state.layoutFactor),
                              ],
                            );
                          },
                        ),
                        Flexible(
                          child: CommonCard(
                            radius: 20,
                            type: CommonCardType.filled,
                            child: ListTile(
                              minTileHeight: dimension,
                              title: TextField(
                                controller: _srcController,
                                keyboardType: TextInputType.url,
                                inputFormatters: TextInputLimits.limit(
                                  TextInputLimits.iconUrl,
                                ),
                                onChanged: (_) {
                                  _handleInputChange();
                                },
                                decoration: InputDecoration.collapsed(
                                  border: const NoInputBorder(),
                                  hintText: appLocalizations.iconUrl,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (records.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InfoHeader(
                      info: Info(label: appLocalizations.iconRecords),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return _buildItem(
                          isSelected: false,
                          context: context,
                          index: index,
                          record: record,
                          total: records.length,
                          onPressed: () {
                            _srcController.text = record.url;
                            Navigator.of(context).pop(_srcController.text);
                          },
                        );
                      },
                      itemCount: records.length,
                    ),
                  ),
                ] else
                  Expanded(
                    child: NullStatus(label: appLocalizations.noRecords),
                  ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
