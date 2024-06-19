import 'package:flutter/material.dart';

class CommonPopupMenuItem<T> {
  T action;
  String label;
  IconData? iconData;

  CommonPopupMenuItem({
    required this.action,
    required this.label,
    this.iconData,
  });
}

class CommonPopupMenu<T> extends StatefulWidget {
  final List<CommonPopupMenuItem> items;
  final PopupMenuItemSelected<T> onSelected;
  final T? selectedValue;
  final Widget? icon;

  const CommonPopupMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.icon,
  }) : selectedValue = null;

  const CommonPopupMenu.radio({
    super.key,
    required this.items,
    required this.onSelected,
    required T this.selectedValue,
    this.icon,
  });

  @override
  State<CommonPopupMenu<T>> createState() => _CommonPopupMenuState();
}

class _CommonPopupMenuState<T> extends State<CommonPopupMenu<T>> {
  late ValueNotifier<T?> groupValue;

  @override
  void initState() {
    super.initState();
    groupValue = ValueNotifier(widget.selectedValue);
  }

  handleSelect(T value) {
    if (widget.selectedValue != null) {
      this.groupValue.value = value;
    }
    widget.onSelected(value);
  }

  @override
  void dispose() {
    groupValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      icon: widget.icon,
      onSelected: handleSelect,
      itemBuilder: (_) {
        return [
          for (final item in widget.items)
            PopupMenuItem<T>(
              value: item.action,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        item.iconData != null
                            ? Flexible(
                                child: Container(
                                  margin: const EdgeInsets.only(right: 16),
                                  child: Icon(item.iconData),
                                ),
                              )
                            : Container(),
                        Flexible(
                          flex: 0,
                          child: SizedBox(
                            child: Text(
                              item.label,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.selectedValue != null)
                    Flexible(
                      flex: 0,
                      child: ValueListenableBuilder<T?>(
                        valueListenable: groupValue,
                        builder: (_, groupValue, __) {
                          return Radio<T>(
                            value: item.action,
                            groupValue: groupValue,
                            onChanged: (T? value) {
                              if (value != null) {
                                handleSelect(value);
                                Navigator.of(context).pop();
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
        ];
      },
    );
  }
}
