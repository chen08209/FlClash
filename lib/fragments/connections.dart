// import 'dart:async';
//
// import 'package:fl_clash/clash/core.dart';
// import 'package:fl_clash/models/models.dart';
// import 'package:fl_clash/plugins/app.dart';
// import 'package:fl_clash/state.dart';
// import 'package:fl_clash/widgets/widgets.dart';
// import 'package:flutter/material.dart';
//
// class ConnectionsFragment extends StatefulWidget {
//   const ConnectionsFragment({super.key});
//
//   @override
//   State<ConnectionsFragment> createState() => _ConnectionsFragmentState();
// }
//
// class _ConnectionsFragmentState extends State<ConnectionsFragment> {
//   final connectionsNotifier = ValueNotifier<List<Connection>>([]);
//   Map<String, String?> idPackageNameMap = {};
//
//   Timer? timer;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       _getConnections();
//       if (timer != null) {
//         timer?.cancel();
//         timer = null;
//       }
//       timer = Timer.periodic(const Duration(seconds: 3), (timer) {
//         if (mounted) {
//           _getConnections();
//         }
//       });
//     });
//   }
//
//   _getConnections() {
//     connectionsNotifier.value = clashCore
//         .getConnections();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     timer?.cancel();
//     timer = null;
//   }
//
//   Future<ImageProvider?> _getPackageIconWithConnection(
//       Connection connection) async {
//     final uid = connection.metadata.uid;
//     // if(globalState.packageNameMap[uid] == null){
//     //   globalState.packageNameMap[uid] = await app?.getPackageName(connection.metadata);
//     // }
//     final packageName = globalState.packageNameMap[uid];
//     if(packageName == null) return null;
//     return await app?.getPackageIcon(packageName);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<List<Connection>>(
//       valueListenable: connectionsNotifier,
//       builder: (_, List<Connection> connections, __) {
//         if (connections.isEmpty) {
//           return const NullStatus(
//             label: "未开启代理,或者没有连接数据",
//           );
//         }
//         return ListView.separated(
//           physics: const AlwaysScrollableScrollPhysics(),
//           itemBuilder: (_, index) {
//             final connection = connections[index];
//             return ListTile(
//               titleAlignment: ListTileTitleAlignment.top,
//               leading: Container(
//                 margin: const EdgeInsets.only(top: 4),
//                 width: 48,
//                 height: 48,
//                 child: FutureBuilder<ImageProvider?>(
//                   future: _getPackageIconWithConnection(connection),
//                   builder: (_, snapshot) {
//                     if (!snapshot.hasData && snapshot.data == null) {
//                       return Container();
//                     } else {
//                       return Image(
//                         image: snapshot.data!,
//                         gaplessPlayback: true,
//                         width: 48,
//                         height: 48,
//                       );
//                     }
//                   },
//                 ),
//               ),
//               contentPadding:
//                   const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               title: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(connection.metadata.host.isNotEmpty
//                       ? connection.metadata.host
//                       : connection.metadata.destinationIP),
//                   Padding(
//                     padding: const EdgeInsets.only(
//                       top: 12,
//                     ),
//                     child: Wrap(
//                       runSpacing: 8,
//                       spacing: 8,
//                       children: [
//                         for (final chain in connection.chains)
//                           CommonChip(
//                             label: chain,
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               trailing: IconButton(
//                 icon: const Icon(Icons.block),
//                 onPressed: () {},
//               ),
//             );
//           },
//           separatorBuilder: (BuildContext context, int index) {
//             return const Divider(
//               height: 0,
//             );
//           },
//           itemCount: connections.length,
//         );
//       },
//     );
//   }
// }
