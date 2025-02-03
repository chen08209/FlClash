import 'package:flutter/cupertino.dart';

class CommonView extends StatefulWidget {
  final List<Widget> actions;

  const CommonView({
    super.key,
    required this.actions,
  });

  @override
  State<CommonView> createState() => _CommonViewState();
}

class _CommonViewState extends State<CommonView> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
