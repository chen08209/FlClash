import 'package:fl_clash/views/connection/requests.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Counts builds under a hidden requests segment until the returned call.
int Function() countHiddenSegmentBuilds() {
  var built = 0;
  debugOnRebuildDirtyWidget = (element, _) {
    element.visitAncestorElements((ancestor) {
      final widget = ancestor.widget;
      if (widget is Offstage && widget.key is ValueKey<RequestsSegment>) {
        if (widget.offstage) {
          built++;
        }
        return false;
      }
      return true;
    });
  };
  addTearDown(() => debugOnRebuildDirtyWidget = null);
  return () {
    debugOnRebuildDirtyWidget = null;
    return built;
  };
}
