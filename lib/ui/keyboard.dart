import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

SingleActivator controlSingleActivator(LogicalKeyboardKey trigger) {
  final control = Platform.isMacOS ? false : true;
  return SingleActivator(trigger, control: control, meta: !control);
}
