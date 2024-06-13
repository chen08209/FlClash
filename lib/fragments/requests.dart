import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

class RequestFragment extends StatefulWidget {
  const RequestFragment({super.key});

  @override
  State<RequestFragment> createState() => _RequestFragmentState();
}

class _RequestFragmentState extends State<RequestFragment> {
  final requestsNotifier = ValueNotifier<List<Connection>>([]);
  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: false,
  );

  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = globalState.appController.appState;
      requestsNotifier.value = List<Connection>.from(appState.requests);
      if (timer != null) {
        timer?.cancel();
        timer = null;
      }
      timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
        final requests = List<Connection>.from(appState.requests);
        if (!const ListEquality<Connection>().equals(
          requestsNotifier.value,
          requests,
        )) {
          requestsNotifier.value = requests;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    _scrollController.dispose();
    timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Connection>>(
      valueListenable: requestsNotifier,
      builder: (_, List<Connection> connections, __) {
        if (connections.isEmpty) {
          return NullStatus(
            label: appLocalizations.nullRequestsDesc,
          );
        }
        connections = connections.reversed.toList();
        return ListView.separated(
          controller: _scrollController,
          itemBuilder: (_, index) {
            final connection = connections[index];
            return RequestItem(
              key: Key(connection.id),
              connection: connection,
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              height: 0,
            );
          },
          itemCount: connections.length,
        );
      },
    );
  }
}

class RequestItem extends StatelessWidget {
  final Connection connection;

  const RequestItem({
    super.key,
    required this.connection,
  });

  Future<ImageProvider?> _getPackageIcon(Connection connection) async {
    return await app?.getPackageIcon(connection.metadata.process);
  }

  String _getRequestText(Metadata metadata) {
    var text = "${metadata.network}:://";
    final ips = [
      metadata.host,
      metadata.destinationIP,
    ].where((ip) => ip.isNotEmpty);
    text += ips.join("/");
    text += ":${metadata.destinationPort}";
    return text;
  }

  String _getSourceText(Connection connection) {
    final metadata = connection.metadata;
    if (metadata.process.isEmpty) {
      return connection.start.lastUpdateTimeDesc;
    }
    return "${metadata.process} · ${connection.start.lastUpdateTimeDesc}";
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      titleAlignment: ListTileTitleAlignment.top,
      leading: Platform.isAndroid
          ? Container(
              margin: const EdgeInsets.only(top: 4),
              width: 48,
              height: 48,
              child: FutureBuilder<ImageProvider?>(
                future: _getPackageIcon(connection),
                builder: (_, snapshot) {
                  if (!snapshot.hasData && snapshot.data == null) {
                    return Container();
                  } else {
                    return Image(
                      image: snapshot.data!,
                      gaplessPlayback: true,
                      width: 48,
                      height: 48,
                    );
                  }
                },
              ),
            )
          : null,
      title: Text(
        _getRequestText(connection.metadata),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 12,
          ),
          Text(
            _getSourceText(connection),
          ),
          const SizedBox(
            height: 12,
          ),
          Wrap(
            runSpacing: 8,
            spacing: 8,
            children: [
              for (final chain in connection.chains)
                CommonChip(
                  label: chain,
                ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }
}
