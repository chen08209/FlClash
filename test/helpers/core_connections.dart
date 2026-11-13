import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/models/models.dart';
import 'package:mocktail/mocktail.dart';

typedef ConnectionsPresenter<R> = R Function(List<TrackerInfo>);

void registerConnectionsPresenter<R>() {
  R fallback(List<TrackerInfo> _) => throw UnimplementedError();
  registerFallbackValue(fallback);
}

void whenConnections<R>(
  CoreHandlerInterface core,
  Future<List<TrackerInfo>> Function() read,
) {
  registerConnectionsPresenter<R>();
  when(() => core.getConnectionsWith<R>(any())).thenAnswer((invocation) async {
    final present =
        invocation.positionalArguments.single as ConnectionsPresenter<R>;
    return present(await read());
  });
}
