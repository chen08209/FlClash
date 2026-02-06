part of 'overwrite.dart';

class _CustomContent extends ConsumerWidget {
  final int profileId;

  const _CustomContent(this.profileId);

  void _handleUseDefault() async {
    final res = await appController.getProfileWithId(profileId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Column(
            children: [
              InfoHeader(
                info: Info(label: '自定义'),
                actions: [
                  CommonMinFilledButtonTheme(
                    child: FilledButton.tonal(
                      onPressed: _handleUseDefault,
                      child: Text('使用默认配置'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 8)),
        _CustomProxyGroups(profileId),
        // SliverToBoxAdapter(child: SizedBox(height: 8)),
        // SliverToBoxAdapter(
        //   child: Padding(
        //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        //     child: CommonCard(
        //       radius: 18,
        //       child: ListTile(
        //         minTileHeight: 0,
        //         minVerticalPadding: 0,
        //         titleTextStyle: context.textTheme.bodyMedium?.toJetBrainsMono,
        //         contentPadding: const EdgeInsets.symmetric(
        //           horizontal: 16,
        //           vertical: 16,
        //         ),
        //         title: Row(
        //           crossAxisAlignment: CrossAxisAlignment.center,
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Flexible(
        //               child: Text('自定义规则', style: context.textTheme.bodyLarge),
        //             ),
        //             Icon(Icons.arrow_forward_ios, size: 18),
        //           ],
        //         ),
        //       ),
        //       onPressed: () {},
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

class _CustomProxyGroups extends ConsumerStatefulWidget {
  final int profileId;

  const _CustomProxyGroups(this.profileId);

  @override
  ConsumerState createState() => _CustomProxyGroupsState();
}

class _CustomProxyGroupsState extends ConsumerState<_CustomProxyGroups> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Wrap(
          children: [
            CommonCard(
              padding: EdgeInsets.all(16),
              onPressed: () {},
              child: Icon(Icons.add, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}
