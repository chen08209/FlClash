import 'package:material_ui/material_ui.dart';

class KeepScope extends StatefulWidget {
  final Widget child;

  const KeepScope({super.key, required this.child});

  @override
  State<KeepScope> createState() => _KeepContainerState();
}

class _KeepContainerState extends State<KeepScope>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
