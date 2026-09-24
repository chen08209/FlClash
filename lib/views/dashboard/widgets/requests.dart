import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/views/connection/requests.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

import 'feed_card.dart';

class RequestsCard extends StatelessWidget {
  const RequestsCard({super.key});

  void _openRequests(BuildContext context) {
    showSnapSheet(
      context,
      initialScrollOffset: double.maxFinite,
      builder: (_, controller) => RequestsView(scrollController: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FeedCard(
      label: PageLabel.requests.label,
      glyph: AppGlyphs.requests,
      onPressed: () => _openRequests(context),
      child: ThrottledFeedCount(provider: requestCountProvider),
    );
  }
}
