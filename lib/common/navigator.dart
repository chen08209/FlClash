import 'package:flutter/material.dart';

class BaseNavigator {
  static Future<T?> push<T>(BuildContext context, Widget child) async {
    return await Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (context) => child,
      ),
    );
  }
}
